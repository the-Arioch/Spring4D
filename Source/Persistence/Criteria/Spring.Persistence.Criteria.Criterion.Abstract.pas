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

unit Spring.Persistence.Criteria.Criterion.Abstract;

interface

uses
  Spring.Collections,
  Spring.Persistence.Criteria.Interfaces,
  Spring.Persistence.SQL.Commands,
  Spring.Persistence.SQL.Interfaces,
  Spring.Persistence.SQL.Params,
  Spring.Persistence.SQL.Types;

type
  TAbstractCriterion = class(TInterfacedObject, ICriterion)
  private
    fEntityClass: TClass;
    procedure SetEntityClass(value: TClass);
    function GetEntityClass: TClass;
  protected
    function GetCriterionTable(const command: TDMLCommand): TSQLTable; overload; virtual;
    function GetCriterionTable(const command: TDMLCommand;
      const table: TSQLTable): TSQLTable; overload; virtual;
    function GetMatchMode: TMatchMode; virtual;
    function GetWhereOperator: TWhereOperator; virtual;
    function ToSqlString(const params: IList<TDBParam>;
      const command: TDMLCommand; const generator: ISQLGenerator;
      addToCommand: Boolean): string; virtual;
  end;

implementation


{$REGION 'TAbstractCriterion'}

function TAbstractCriterion.GetCriterionTable(const command: TDMLCommand): TSQLTable;
begin
  if command is TSelectCommand then
    Result := TSelectCommand(command).FindTable(fEntityClass)
  else
    Result := command.Table;
end;

function TAbstractCriterion.GetCriterionTable(const command: TDMLCommand;
  const table: TSQLTable): TSQLTable;
begin
  if command is TSelectCommand then
    Result := TSelectCommand(command).FindCorrespondingTable(table)
  else
    Result := table;
end;

function TAbstractCriterion.GetEntityClass: TClass;
begin
  Result := fEntityClass;
end;

function TAbstractCriterion.GetMatchMode: TMatchMode;
begin
  Result := mmExact;
end;

function TAbstractCriterion.GetWhereOperator: TWhereOperator;
begin
  Result := woEqual;
end;

procedure TAbstractCriterion.SetEntityClass(value: TClass);
begin
  fEntityClass := value;
end;

function TAbstractCriterion.ToSqlString(const params: IList<TDBParam>;
  const command: TDMLCommand; const generator: ISQLGenerator;
  addToCommand: Boolean): string;
begin
  Result := '';
end;

end.