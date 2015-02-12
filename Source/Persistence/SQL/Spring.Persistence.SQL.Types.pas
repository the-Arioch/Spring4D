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

unit Spring.Persistence.SQL.Types;

interface

uses
  Spring.Collections,
  Spring.Persistence.Mapping.Attributes,
  TypInfo;

const
  CRLF = #13#10;

type
  /// <summary>
  ///   Represents Database table.
  /// </summary>
  TSQLTable = class
  private
    FName: string;
    FSchema: string;
    FDescription: string;
    FAlias: string;
    function GetAlias: string;
    procedure SetName(const Value: string);
    function GetName: string;
  public
    class function CreateFromClass(AEntityClass: TClass): TSQLTable;

    function SchemaExists: Boolean;

    function GetNameWithoutSchema: string;
    function GetFullTableName: string;

    procedure SetFromAttribute(AAttribute: TableAttribute);

    property Alias: string read GetAlias write FAlias;
    property Description: string read FDescription write FDescription;
    property Name: string read GetName write SetName;
    property Schema: string read FSchema write FSchema;
  end;

  /// <summary>
  ///   Represents field of the database table.
  /// </summary>
  ISQLField = interface
    ['{2316102E-61A3-4454-A7B2-18090C384882}']
    function GetFieldname: string;
    function GetFullFieldname(const AEscapeChar: Char): string;
    function GetTable: TSQLTable;
    function GetAlias: string;
    procedure SetAlias(const Value: string);
    property Alias: string read GetAlias write SetAlias;
    property Fieldname: string read GetFieldname;
    property Table: TSQLTable read GetTable;
  end;

  /// <summary>
  ///   Represents field of the database table.
  /// </summary>
  TSQLField = class(TInterfacedObject, ISQLField)
  private
    FTable: TSQLTable;
    FFieldname: string;
    FAlias: string;
    FColumn: ColumnAttribute;
    function GetFieldname: string;
    function GetTable: TSQLTable;
    function GetAlias: string;
    procedure SetAlias(const Value: string);
  public
    constructor Create(const AFieldname: string; ATable: TSQLTable); virtual;
    destructor Destroy; override;

    function GetFullFieldname(const AEscapeChar: Char): string; virtual;
    function GetEscapedName(const AName: string; const AEscapeChar: Char): string; virtual;
    function GetEscapedFieldname(const AEscapeChar: Char): string; virtual;

    property Alias: string read GetAlias write SetAlias;
    property Column: ColumnAttribute read FColumn write FColumn;
    property Fieldname: string read GetFieldname write FFieldname;
    property Table: TSQLTable read GetTable write FTable;
  end;

  TSQLParamField = class(TSQLField)
  private
    FParamName: string;
  public
    constructor Create(const AFieldname: string; ATable: TSQLTable;
       AColumn: ColumnAttribute; const AParamName: string); reintroduce; virtual;

    property ParamName: string read FParamName write FParamName;
  end;

  /// <summary>
  ///   Represents field of the database table which is used in <c>select</c>
  ///   statements.
  /// </summary>
  TSQLSelectField = class(TSQLField)

  end;

  TSQLInsertField = class(TSQLParamField);

  TSQLUpdateField = class(TSQLParamField);


  /// <summary>
  ///   Represents field of the database table which is used in <c>create table</c>
  ///    statements.
  /// </summary>
  TSQLCreateField = class(TSQLField)
  private
    FIsPrimaryKey: Boolean;
    FIsIdentity: Boolean;
    FTypeKindInfo: PTypeInfo;
    FLength: Integer;
    FScale: Integer;
    FProperties: TColumnProperties;
    FDescription: string;
    FPrecision: Integer;
    FColumnAttribute: ColumnAttribute;
  public
    procedure SetFromAttribute(AColumnAttr: ColumnAttribute); virtual;
    function Clone: TSQLCreateField;

    property Description: string read FDescription;
    property IsPrimaryKey: Boolean read FIsPrimaryKey;
    property IsIdentity: Boolean read FIsIdentity;
    property TypeKindInfo: PTypeInfo read FTypeKindInfo write FTypeKindInfo;
    property Length: Integer read FLength;
    property Precision: Integer read FPrecision;
    property Scale: Integer read FScale;
    property Properties: TColumnProperties read FProperties;
  end;

  /// <summary>
  ///   Represents foreign key field of the database table.
  /// </summary>
  TSQLForeignKeyField = class(TSQLField)
  private
    FReferencedColumnName: string;
    FConstraints: TForeignStrategies;
    FReferencedTableName: string;
    function GetForeignKeyName: string;
  public
    constructor Create(const AFieldname: string; ATable: TSQLTable
      ; const AReferencedColumnName, AReferencedTableName: string; AConstraints: TForeignStrategies); reintroduce; overload;

    function GetConstraintsAsString: string;

    property ForeignKeyName: string read GetForeignKeyName;
    property ReferencedColumnName: string read FReferencedColumnName write FReferencedColumnName;
    property ReferencedTableName: string read FReferencedTableName write FReferencedTableName;
    property Constraints: TForeignStrategies read FConstraints write FConstraints;
  end;

  TMatchMode = (mmExact, mmStart, mmEnd, mmAnywhere);

  TWhereOperator = (woEqual = 0, woNotEqual, woMore, woLess, woLike, woNotLike,
    woMoreOrEqual, woLessOrEqual, woIn, woNotIn, woIsNull, woIsNotNull, woOr,
    woOrEnd, woAnd, woAndEnd, woNot, woNotEnd, woBetween, woJunction);

  TStartOperators = set of TWhereOperator;

  TEndOperators = set of TWhereOperator;

const
  WhereOpNames: array[TWhereOperator] of string = (
    {woEqual =} '=', {woNotEqual =} '<>', {woMore = }'>', {woLess = }'<', {woLike = }'LIKE', {woNotLike = }'NOT LIKE',
    {woMoreOrEqual = }'>=', {woLessOrEqual = }'<=', {woIn = }'IN', {woNotIn = }'NOT IN', {woIsNull} 'IS NULL', {woIsNotNull} 'IS NOT NULL'
    ,{woOr}'OR', {woOrEnd}'', {woAnd} 'AND', {woAndEnd}'', {woNot}'NOT', {woNotEnd}'',{woBetween}'BETWEEN', {woJunction} ''
    );

  StartOperators: TStartOperators = [woOr, woAnd, woNot];

  EndOperators: TEndOperators = [woOrEnd, woAndEnd, woNotEnd];

  StartEndOperators = [woOr, woOrEnd, woAnd, woAndEnd, woNot, woNotEnd];

type
  /// <summary>
  ///   Represents field of the database table which is used in <c>where</c>
  ///   clause.
  /// </summary>
  TSQLWhereField = class(TSQLParamField)
  private
    FWhereOperator: TWhereOperator;
    FMatchMode: TMatchMode;
    FLeftSQL: string;
    FRightSQL: string;
    FParamName2: string;
  public
    constructor Create(const AFieldname: string; ATable: TSQLTable); reintroduce; overload;
    constructor Create(const ALeftSQL, ARightSQL: string); reintroduce; overload;

    function ToSQLString(const AEscapeChar: Char): string; virtual;

    property MatchMode: TMatchMode read FMatchMode write FMatchMode;
    property WhereOperator: TWhereOperator read FWhereOperator write FWhereOperator;
    property LeftSQL: string read FLeftSQL write FLeftSQL;
    property RightSQL: string read FRightSQL write FRightSQL;
    property ParamName2: string read FParamName2 write FParamName2;
  end;

  /// <summary>
  ///   Represents field of the database table which is used in <c>where</c>
  ///   clause.
  /// </summary>
  TSQLWherePropertyField = class(TSQLWhereField)
  private
    FOtherTable: TSQLTable;
  public
    constructor Create(const ALeftPropertyName, ARightPropertyName: string; ALeftTable, ARightTable: TSQLTable); overload;

    function GetFullLeftFieldname: string; virtual;
    function GetFullRightFieldname: string; virtual;

    function ToSQLString(const AEscapeChar: Char): string; override;

    property OtherTable: TSQLTable read FOtherTable write FOtherTable;
  end;

  /// <summary>
  ///   Represents field of the database table which is used in <c>group by</c>
  ///   clause.
  /// </summary>
  TSQLGroupByField = class(TSQLField)
  end;

  TSortingDirection = (stAscending, stDescending);

  /// <summary>
  ///   Represents field of the database table which is used in <c>order by</c>
  ///   clause.
  /// </summary>
  TSQLOrderByField = class(TSQLField)
  private
    fSortingDirection: TSortingDirection;
  public
    constructor Create(const AFieldname: string; ATable: TSQLTable); override;

    function GetFullOrderByFieldname(const AEscapeChar: Char): string;

    property SortingDirection: TSortingDirection read fSortingDirection write fSortingDirection;
  end;

  TSQLJoinType = (jtInner, jtLeft);

  /// <summary>
  ///   Represents <c>join</c> segment.
  /// </summary>
  TSQLJoinSegment = class
  private
    FPKField: ISQLField;
    FFKField: ISQLField;
  public
    constructor Create(const APKField: ISQLField; const AFKField: ISQLField); virtual;

    property PKField: ISQLField read FPKField write FPKField;
    property FKField: ISQLField read FFKField write FFKField;
  end;


  /// <summary>
  ///   Represents <c>join</c> of database tables.
  /// </summary>
  TSQLJoin = class
  private
    FJoinType: TSQLJoinType;
    FSegments: IList<TSQLJoinSegment>;
  public
    constructor Create(const AJoinType: TSQLJoinType); virtual;
    destructor Destroy; override;

    class function GetJoinTypeAsString(const AJoinType: TSQLJoinType): string;

    property JoinType: TSQLJoinType read FJoinType write FJoinType;
    property Segments: IList<TSQLJoinSegment> read FSegments write FSegments;
  end;

  /// <summary>
  ///   Static class which is used to generate table aliases.
  /// </summary>
  TSQLAliasGenerator = class
  private
    class var FAliases: IDictionary<string,string>;
    class var FCharIndex: Byte;
  public
    class constructor Create;
    class destructor Destroy;

    class function AliasExists(const ATable: TSQLTable): Boolean;
    class function GetAlias(const ATable: TSQLTable): string;
  end;

  function GetMatchModeString(AMatchMode: TMatchMode; const APattern: string): string;
  function GetEndOperator(AStartOperator: TWhereOperator): TWhereOperator;

implementation

uses
  SysUtils,
  StrUtils,
  Spring.Persistence.Core.EntityCache,
  Spring.Persistence.Core.Exceptions;

function GetMatchModeString(AMatchMode: TMatchMode; const APattern: string): string;
const
  MATCH_CHAR = '%';
begin
  case AMatchMode of
    mmExact: Result := APattern;
    mmStart: Result := APattern + MATCH_CHAR;
    mmEnd: Result := MATCH_CHAR + APattern;
    mmAnywhere: Result := MATCH_CHAR + APattern + MATCH_CHAR;
  end;
  Result := QuotedStr(Result);
end;

function GetEndOperator(AStartOperator: TWhereOperator): TWhereOperator;
begin
  Result := AStartOperator;
  case AStartOperator of
    woOr: Result := woOrEnd;
    woAnd: Result := woAndEnd;
    woNot: Result := woNotEnd;
  end;
end;



{ TSQLTable }

class function TSQLTable.CreateFromClass(AEntityClass: TClass): TSQLTable;
var
  LEntityData: TEntityData;
begin
  if AEntityClass = nil then
    Exit(nil);

  LEntityData := TEntityCache.Get(AEntityClass);
  if not LEntityData.IsTableEntity then
    raise ETableNotSpecified.CreateFmt('Entity ("%s") is not a table', [AEntityClass.ClassName]);

  Result := TSQLTable.Create;
  Result.SetFromAttribute(LEntityData.EntityTable);
end;

function TSQLTable.GetAlias: string;
begin
  if (FAlias = '') then
  begin
    FAlias := TSQLAliasGenerator.GetAlias(Self);
  end;

  Result := FAlias;
end;

function TSQLTable.GetFullTableName: string;
begin
  Result := Name + ' ' + Alias;
end;

function TSQLTable.GetName: string;
begin
  Result := '';
  if SchemaExists then
    Result := Schema + '.';

  Result := Result + FName;
end;

function TSQLTable.GetNameWithoutSchema: string;
begin
  Result := FName;
end;

function TSQLTable.SchemaExists: Boolean;
begin
  Result := (FSchema <> '');
end;

procedure TSQLTable.SetFromAttribute(AAttribute: TableAttribute);
begin
  Name := AAttribute.TableName;
  Schema := AAttribute.Schema;
end;

procedure TSQLTable.SetName(const Value: string);
begin
  if Value <> FName then
  begin
    FName := Value;
  end;
end;

{ TSQLField }

constructor TSQLField.Create(const AFieldname: string; ATable: TSQLTable);
begin
  inherited Create;
  FFieldname := AFieldname;
  FTable := ATable;
  FAlias := '';
end;

destructor TSQLField.Destroy;
begin
  inherited Destroy;
end;

function TSQLField.GetAlias: string;
begin
  Result := FAlias;
end;

function TSQLField.GetEscapedFieldname(const AEscapeChar: Char): string;
var
  LPos: Integer;
  LFieldname, LAliasName: string;
begin
  LPos := PosEx(' ', FFieldname);
  if LPos > 1 then
  begin
    //escape all words including alias name
    LFieldname := GetEscapedName(Copy(FFieldname, 1, LPos - 1), AEscapeChar);
    LAliasName := Copy(FFieldname, LPos, Length(FFieldname));
    Result := LFieldname + LAliasName;
  end
  else
    Result := GetEscapedName(FFieldname, AEscapeChar);
end;

function TSQLField.GetEscapedName(const AName: string; const AEscapeChar: Char): string;
begin
  Result := AnsiQuotedStr(AName, AEscapeChar);
end;

function TSQLField.GetFieldname: string;
begin
  Result := FFieldname;
end;

function TSQLField.GetFullFieldname(const AEscapeChar: Char): string;
begin
  if (FAlias <> '') then
    Result := FAlias
  else
    Result := Table.Alias + '.' + GetEscapedFieldname(AEscapeChar);
end;

function TSQLField.GetTable: TSQLTable;
begin
  Result := FTable;
end;

procedure TSQLField.SetAlias(const Value: string);
begin
  FAlias := Value;
end;

{ TSQLJoin }

constructor TSQLJoin.Create(const AJoinType: TSQLJoinType);
begin
  inherited Create;
  FJoinType := AJoinType;
  FSegments := TCollections.CreateObjectList<TSQLJoinSegment>;
end;

destructor TSQLJoin.Destroy;
begin
  inherited Destroy;
end;

class function TSQLJoin.GetJoinTypeAsString(const AJoinType: TSQLJoinType): string;
begin
  Result := '';
  case AJoinType of
    jtInner: Result := 'INNER JOIN';
    jtLeft: Result := 'LEFT OUTER JOIN'
    else
      raise EUnknownJoinType.Create('Unknown join type: ' + GetEnumName(TypeInfo(TSQLJoinType), Ord(AJoinType)));
  end;
end;

{ TSQLJoinSegment }

constructor TSQLJoinSegment.Create(const APKField, AFKField: ISQLField);
begin
  inherited Create;
  FPKField := APKField;
  FFKField := AFKField;
end;

{ TSQLAliasGenerator }

class function TSQLAliasGenerator.AliasExists(const ATable: TSQLTable): Boolean;
begin
  Result := FAliases.ContainsKey(ATable.Name);
end;

class constructor TSQLAliasGenerator.Create;
begin
  FAliases := TCollections.CreateDictionary<string,string>(100);
  FCharIndex := 65;
end;

class destructor TSQLAliasGenerator.Destroy;
begin
  FAliases := nil;
  inherited;
end;

class function TSQLAliasGenerator.GetAlias(const ATable: TSQLTable): string;
begin
  if not AliasExists(ATable) then
  begin
    Result := Chr(FCharIndex);
    FAliases.Add(ATable.Name, Result);
    Inc(FCharIndex);
  end
  else
  begin
    Result := FAliases[ATable.Name];
  end;
end;

{ TSQLOrderField }

constructor TSQLOrderByField.Create(const AFieldname: string; ATable: TSQLTable);
begin
  inherited Create(AFieldname, ATable);
  fSortingDirection := stAscending;
end;

function TSQLOrderByField.GetFullOrderByFieldname(const AEscapeChar: Char): string;
begin
  Result := GetFullFieldname(AEscapeChar);

  case fSortingDirection of
    stAscending:  Result := Result + ' ASC' ;
    stDescending: Result := Result + ' DESC';
  end;
end;

{ TSQLWhereField }

constructor TSQLWhereField.Create(const AFieldname: string; ATable: TSQLTable);
begin
  inherited Create(AFieldname, ATable, nil, ':' + AFieldname);
  FWhereOperator := woEqual;
  FMatchMode := mmExact;
end;

constructor TSQLWhereField.Create(const ALeftSQL, ARightSQL: string);
begin
  Create('', nil);
  FWhereOperator := woOr;
  FMatchMode := mmExact;
  FLeftSQL := ALeftSQL;
  FRightSQL := ARightSQL;
end;

function TSQLWhereField.ToSQLString(const AEscapeChar: Char): string;
begin
  case WhereOperator of
    woIsNull, woIsNotNull: Result := GetFullFieldname(AEscapeChar) + ' ' + WhereOpNames[WhereOperator];
    woLike, woNotLike, woIn, woNotIn: Result := GetFullFieldname(AEscapeChar);
    woOr, woAnd: Result := Format('(%s %s %s)', [FLeftSQL, WhereOpNames[WhereOperator], FRightSQL]);
    woNot: Result := Format('%s (%s)', [WhereOpNames[WhereOperator], FLeftSQL]);
    woOrEnd, woAndEnd, woNotEnd: Result := '';
    woJunction: Result := Format('(%s)', [FLeftSQL]);
    woBetween: Result := Format('(%s %s %s AND %s)', [GetFullFieldname(AEscapeChar), WhereOpNames[WhereOperator], ParamName, ParamName2]);
  else
    Result := GetFullFieldname(AEscapeChar) + ' ' + WhereOpNames[WhereOperator] + ' ' + ParamName + ' ';
  end;
end;

{ TSQLCreateField }

function TSQLCreateField.Clone: TSQLCreateField;
begin
  Result := TSQLCreateField.Create(FFieldname, FTable);
  Result.SetFromAttribute(FColumnAttribute);
end;

procedure TSQLCreateField.SetFromAttribute(AColumnAttr: ColumnAttribute);
begin
  Assert(Assigned(AColumnAttr));
  FColumnAttribute := AColumnAttr;
  FProperties := AColumnAttr.Properties;
  FLength := AColumnAttr.Length;
  FScale := AColumnAttr.Scale;
  FDescription := AColumnAttr.Description;
  FPrecision := AColumnAttr.Precision;
  FIsIdentity := AColumnAttr.IsIdentity;
  if FIsIdentity then
    FIsPrimaryKey := FIsIdentity
  else
    FIsPrimaryKey := cpPrimaryKey in AColumnAttr.Properties;
  FTypeKindInfo := AColumnAttr.MemberType;
end;

{ TSQLForeignKeyField }

constructor TSQLForeignKeyField.Create(const AFieldname: string; ATable: TSQLTable; const AReferencedColumnName,
  AReferencedTableName: string; AConstraints: TForeignStrategies);
begin
  inherited Create(AFieldname, ATable);
  FReferencedColumnName := AReferencedColumnName;
  FReferencedTableName := AReferencedTableName;
  FConstraints := AConstraints;
end;

function TSQLForeignKeyField.GetConstraintsAsString: string;
var
  LConstraint: TForeignStrategy;
begin
  Result := '';

  for LConstraint in FConstraints do
  begin
    if LConstraint in FConstraints then
    begin
      case LConstraint of
        fsOnDeleteSetNull: Result := Result + ' ON DELETE SET NULL';
        fsOnDeleteSetDefault: Result := Result + ' ON DELETE SET DEFAULT';
        fsOnDeleteCascade: Result := Result + ' ON DELETE CASCADE';
        fsOnDeleteNoAction: Result := Result + ' ON DELETE NO ACTION';
        fsOnUpdateSetNull: Result := Result + ' ON UPDATE SET NULL';
        fsOnUpdateSetDefault: Result := Result + ' ON UPDATE SET DEFAULT';
        fsOnUpdateCascade: Result := Result + ' ON UPDATE CASCADE';
        fsOnUpdateNoAction: Result := Result + ' ON UPDATE NO ACTION';
      end;
    end;
  end;
end;

function TSQLForeignKeyField.GetForeignKeyName: string;
begin
  Result := Format('FK_%0:s_%1:s', [Table.GetNameWithoutSchema, Fieldname]);
end;

{ TSQLWherePropertyField }

constructor TSQLWherePropertyField.Create(const ALeftPropertyName, ARightPropertyName: string; ALeftTable,
  ARightTable: TSQLTable);
begin
  inherited Create(ALeftPropertyName, ARightPropertyName);
  Table := ALeftTable;
  FOtherTable := ARightTable;
end;

function TSQLWherePropertyField.GetFullLeftFieldname: string;
begin
  Result := Table.Alias + '.' + LeftSQL;
end;

function TSQLWherePropertyField.GetFullRightFieldname: string;
begin
  Result := FOtherTable.Alias + '.' + RightSQL;
end;

function TSQLWherePropertyField.ToSQLString(const AEscapeChar: Char): string;
begin
  Result := Format('%s %s %s', [GetFullLeftFieldname, WhereOpNames[WhereOperator], GetFullRightFieldname]);
end;

{ TSQLParamField }

constructor TSQLParamField.Create(const AFieldname: string; ATable: TSQLTable;
  AColumn: ColumnAttribute; const AParamName: string);
begin
  inherited Create(AFieldname, ATable);
  Column := AColumn;
  ParamName := AParamName;
end;

end.