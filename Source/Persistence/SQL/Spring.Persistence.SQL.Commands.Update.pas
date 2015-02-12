{***************************************************************************}
{                                                                           }
{           Spring Framework for Delphi                                     }
{                                                                           }
{           Copyright (c) 2009-2014 Spring4D Team                           }
{                                                                           }
{           http://www.spring4d.org                                         }
{                                                                           }
{***************************************************************************}
{                                                                           }
{  Licensed under the Apache License, Version 2.0 (the "License");          }
{  you may not use this file except in compliance with the License.         }
{  You may obtain a copy of the License at                                  }
{                                                                           }
{      http://www.apache.org/licenses/LICENSE-2.0                           }
{                                                                           }
{  Unless required by applicable law or agreed to in writing, software      }
{  distributed under the License is distributed on an "AS IS" BASIS,        }
{  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. }
{  See the License for the specific language governing permissions and      }
{  limitations under the License.                                           }
{                                                                           }
{***************************************************************************}

{$I Spring.inc}

unit Spring.Persistence.SQL.Commands.Update;

interface

uses
  Spring.Collections,
  Spring.Persistence.Core.EntityMap,
  Spring.Persistence.Core.Interfaces,
  Spring.Persistence.Mapping.Attributes,
  Spring.Persistence.SQL.Commands,
  Spring.Persistence.SQL.Commands.Abstract,
  Spring.Persistence.SQL.Interfaces,
  Spring.Persistence.SQL.Types;

type
  /// <summary>
  ///   Responsible for building and executing <c>update</c> statements.
  /// </summary>
  TUpdateExecutor = class(TAbstractCommandExecutor, IUpdateCommand)
  private
    fTable: TSQLTable;
    fCommand: TUpdateCommand;
    fColumns: IList<ColumnAttribute>;
    fEntityMap: TEntityMap;
  protected
    function GetCommand: TDMLCommand; override;
    function TryIncrementVersionFor(const entity: TObject): Boolean; virtual;
    function HasChangedVersionColumnOnly: Boolean;
  public
    constructor Create(const connection: IDBConnection; const entityMap: TEntityMap); reintroduce;
    destructor Destroy; override;

    procedure Build(entityClass: TClass); override;
    procedure BuildParams(const entity: TObject); override;
    procedure Execute(const entity: TObject);
  end;

implementation

uses
  Spring,
  Spring.Persistence.Core.Exceptions,
  Spring.Persistence.Core.Utils,
  Spring.Persistence.SQL.Params,
  Spring.Reflection;


{$REGION 'TUpdateCommand'}

constructor TUpdateExecutor.Create(const connection: IDBConnection;
  const entityMap: TEntityMap);
begin
  inherited Create(connection);
  fTable := TSQLTable.Create;
  fColumns := TCollections.CreateList<ColumnAttribute>;
  fCommand := TUpdateCommand.Create(fTable);
  fEntityMap := entityMap;
end;

destructor TUpdateExecutor.Destroy;
begin
  fTable.Free;
  fCommand.Free;
  inherited Destroy;
end;

procedure TUpdateExecutor.Execute(const entity: TObject);
var
  statement: IDBStatement;
  sqlStatement: string;
begin
  Assert(Assigned(entity));

  if EntityData.HasVersionColumn and not TryIncrementVersionFor(entity) then
    raise EORMOptimisticLockException.Create(entity);

  statement := Connection.CreateStatement;

  fColumns.Clear;
  if fEntityMap.IsMapped(entity) then
  begin
    fColumns := fEntityMap.GetChangedMembers(entity, EntityData);
    if HasChangedVersionColumnOnly then
      Exit;
  end
  else
    fColumns.AddRange(EntityData.Columns);

  fCommand.SetCommandFieldsFromColumns(fColumns);

  if not fCommand.UpdateFields.Any then
    Exit;

  fCommand.Entity := entity;
  sqlStatement := Generator.GenerateUpdate(fCommand);
  if (sqlStatement = '') then
    raise EORMCannotGenerateQueryStatement.Create(entity);

  statement.SetSQLCommand(sqlStatement);
  BuildParams(entity);
  statement.SetParams(SQLParameters);
  statement.Execute;
end;

function TUpdateExecutor.GetCommand: TDMLCommand;
begin
  Result := fCommand;
end;

function TUpdateExecutor.HasChangedVersionColumnOnly: Boolean;
begin
  Result := (fColumns.Count = 1) and (fColumns.First.IsVersionColumn);
end;

function TUpdateExecutor.TryIncrementVersionFor(const entity: TObject): Boolean;
var
  statement: IDBStatement;
  version, primaryKey: TValue;
  query: Variant;
  metadata: TQueryMetadata;
begin
  statement := Connection.CreateStatement;
  version := EntityData.VersionColumn.RttiMember.GetValue(entity);
  primaryKey := EntityData.PrimaryKeyColumn.RttiMember.GetValue(entity);
  query := Generator.GetUpdateVersionFieldQuery(fCommand, EntityData.VersionColumn,
    TUtils.AsVariant(version), TUtils.AsVariant(primaryKey));
  metadata.QueryOperation := ctUpdateVersion;
  metadata.TableName := fCommand.Table.Name;
  statement.SetQuery(metadata, query);

  Result := statement.Execute > 0;
  if Result then
    EntityData.VersionColumn.RttiMember.SetValue(entity, version.AsInteger + 1);
end;

procedure TUpdateExecutor.Build(entityClass: TClass);
begin
  inherited Build(entityClass);

  if not EntityData.IsTableEntity then
    raise ETableNotSpecified.CreateFmt('Table not specified for class "%S"', [entityClass.ClassName]);

  fTable.SetFromAttribute(EntityData.EntityTable);
  fCommand.PrimaryKeyColumn := EntityData.PrimaryKeyColumn;
end;

procedure TUpdateExecutor.BuildParams(const entity: TObject);
var
  param: TDBParam;
  field: TSQLParamfield;
begin
  inherited BuildParams(entity);

  for field in fCommand.UpdateFields do
  begin
    param := CreateParam(entity, field);
    SQLParameters.Add(param);
  end;

  for field in fCommand.WhereFields do
  begin
    param := CreateParam(entity, field);
    SQLParameters.Add(param);
  end;
end;

{$ENDREGION}


end.