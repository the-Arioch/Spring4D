unit TestAdaptersMongoDB;

interface

uses
  TestFramework,
  Rtti,
  SysUtils,
  bsonDoc,
  MongoBson,
  MongoDB,
  mongoId,
  Spring.Collections,
  Spring.Persistence.Adapters.MongoDB,
  Spring.Persistence.Core.Interfaces,
  Spring.Persistence.Core.Base,
  Spring.Persistence.Core.Repository.MongoDB,
  Spring.Persistence.Core.Repository.Proxy,
  Spring.Persistence.Core.Session.MongoDB,
  Spring.Persistence.Mapping.Attributes,
  Spring.Persistence.SQL.Interfaces,
  Spring.Persistence.SQL.Params;

type
  [Table('MongoTest', 'UnitTests')]
  TMongoEntity = class
  private
    FId: Int64;
    FKey: Int64;
    FName: string;
  public
    [Column('KEY')]
    property Key: Int64 read FKey write FKey;

    [Column('_id', [cpNotNull, cpPrimaryKey])]
    property Id: Int64 read FId write FId;

    [Column]
    property Name: string read FName write FName;
  end;

  [Table('AutoId', 'UnitTests')]
  TMongoAutogeneratedIdModel = class
  private
    FName: string;
    FId: Variant;
    FKey: TMongoEntity;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    [Column]
    property Name: string read FName write FName;

    [Column('_id', [cpPrimaryKey])] [AutoGenerated]
    property Id: Variant read FId write FId;
    [Column('KEY')]
    property Key: TMongoEntity read FKey write FKey;
  end;

  TPerson = class
  private
    FName: string;
  public
    constructor Create; overload; virtual;
    constructor Create(const AName: string); overload; virtual;

    [Column]
    property Name: string read FName write FName;
  end;

  [Table('AutoId', 'UnitTests')]
  TMongoSubArrayModel = class(TMongoAutogeneratedIdModel)
  private
    FPersons: IList<TPerson>;
    FVersion: Integer;
  public
    constructor Create; override;
    [Column]
    property Persons: IList<TPerson> read FPersons write FPersons;

    [Version]
    property Version: Integer read FVersion write FVersion;
  end;

  [Table('AutoId', 'UnitTests')]
  TMongoSubSimpleArrayModel = class(TMongoAutogeneratedIdModel)
  private
    FAges: IList<Integer>;
  public
    constructor Create; override;
    [Column]
    property Ages: IList<Integer> read FAges write FAges;
  end;

  TBaseMongoTest = class(TTestCase)
  private
    FConnection: TMongoDBConnection;
    FQuery: TMongoDBQuery;
    function GetKeyValue(const AValue: Variant): Variant;
  public
    procedure SetUp; override;
    procedure TearDown; override;

    property Connection: TMongoDBConnection read FConnection;
    property Query: TMongoDBQuery read FQuery write FQuery;
  end;

  TMongoResultSetAdapterTest = class(TBaseMongoTest)
  private
    FMongoResultSetAdapter: TMongoResultSetAdapter;
  protected
    procedure FetchValue(const AValue: Variant);
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestIsEmpty;
    procedure TestIsEmpty_False;
    procedure TestNext;
    procedure TestGetFieldValue;
    procedure TestGetFieldValue1;
    procedure TestGetFieldCount;
    procedure TestGetFieldName;
  end;

  TMongoStatementAdapterTest = class(TBaseMongoTest)
  private
    FMongoStatementAdapter: TMongoStatementAdapter;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestSetSQLCommand;
    procedure TestSetParams;
    procedure TestExecute;
    procedure TestExecuteQuery;
  end;

  TMongoConnectionAdapterTest = class(TTestCase)
  private
    FConnection: TMongoDBConnection;
    FMongoConnectionAdapter: TMongoConnectionAdapter;
  protected
    class constructor Create;
  public
    class var
      DirMongoDB: string;

    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestConnect;
    procedure TestDisconnect;
    procedure TestIsConnected;
    procedure TestCreateStatement;
    procedure TestBeginTransaction;
    procedure TestGetQueryLanguage;
  end;

  TMongoSessionTest = class(TTestCase)
  private
    FConnection: IDBConnection;
    FMongoConnection: TMongoDBConnection;
    FManager: TMongoDBSession;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure First;
    procedure FindAll;
    procedure Save_Update_Delete;
    procedure Page;
    procedure AutogenerateId;
    procedure SubObjectArray;
    procedure SubSimpleArray;
    procedure RawQuery;
    procedure BulkInsert;
    procedure FindAndModify;
    procedure Versioning;
    procedure SimpleCriteria_Eq;
    procedure SimpleCriteria_In;
    procedure SimpleCriteria_Null;
    procedure SimpleCriteria_Between;
    procedure SimpleCriteria_Or;
    procedure SimpleCriteria_OrderBy;
    procedure SimpleCriteria_Like;
    procedure SimpleCriteria_Not;
    {$IFDEF PERFORMANCE_TESTS}
    procedure Performance;
    {$ENDIF}
  end;

  TMongoRepositoryTest = class(TTestCase)
  private
    FConnection: IDBConnection;
    FMongoConnection: TMongoDBConnection;
    FSession: TMongoDBSession;
    FRepository: IPagedRepository<TMongoEntity, Integer>;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure InsertList;
    procedure Query;
  end;

  ICustomerRepository = interface(IPagedRepository<TMongoEntity, Integer>)
    ['{DE23725D-8E4D-45FB-92C0-1FE4A8531C1C}']

    [Query('{"_id": 1}')]
    function CustomQuery: IList<TMongoEntity>;

    [Query('{"_id": 1}')]
    function CustomQueryReturnObject: TMongoEntity;

    [Query('{"_id": :0}')]
    function CustomQueryWithArgumentReturnObject(AId: Integer): TMongoEntity;

    [Query('{"Name": :0}')]
    function CustomQueryWithStringArgumentReturnObject(AKey: string): TMongoEntity;
  end;

  TMongoProxyRepositoryTest = class(TBaseMongoTest)
  private
    FDBConnection: IDBConnection;
    FSession: TMongoDBSession;
    FProxyRepository: ICustomerRepository;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure DefaultMethod_Count;
    procedure DefaultMethod_FindWhere;
    procedure DefaultMethod_FindWhere_Expression;
    procedure DefaultMethod_FindOne;
    procedure DefaultMethod_FindAll;
    procedure DefaultMethod_Exists;
    procedure DefaultMethod_Insert;
    procedure DefaultMethod_InsertList;
    procedure DefaultMethod_Save;
    procedure DefaultMethod_SaveList;
    procedure DefaultMethod_SaveCascade;
    procedure DefaultMethod_Delete;
    procedure DefaultMethod_DeleteList;
    procedure DefaultMethod_Query;
    procedure DefaultMethod_Execute;
    procedure CustomMethod;
    procedure CustomMethod_ReturnObject;
    procedure CustomMethodWithArgument_ReturnObject;
    procedure CustomMethodWithStringArgument_ReturnObject;
  end;

implementation

uses
  Diagnostics,
  Forms,
  Messages,
  ShellAPI,
  Variants,
  Windows,
  Spring.Persistence.Core.ConnectionFactory,
  Spring.Persistence.Core.Exceptions,
  Spring.Persistence.Core.Session,
  Spring.Persistence.Criteria.Interfaces,
  Spring.Persistence.Criteria.Properties,
  Spring.Persistence.Criteria.Restrictions,
  Spring.Persistence.SQL.Generators.MongoDB;

const
  CT_KEY = 'KEY';
  NAME_COLLECTION = 'UnitTests.MongoTest';

procedure InsertObject(AConnection: TMongoDBConnection; const keyValue: Variant; AID: Integer = 1; AName: string = '');
begin
  AConnection.Insert(NAME_COLLECTION, BSON([CT_KEY, keyValue, '_id', AID, 'Name', AName]));
end;

procedure RemoveObject(AConnection: TMongoDBConnection; const AValue: Variant);
begin
  AConnection.remove(NAME_COLLECTION, BSON(['_id', 1]))
end;


{$REGION 'TMongoResultSetAdapterTest'}

procedure TMongoResultSetAdapterTest.FetchValue(const AValue: Variant);
var
  LDoc: IBSONDocument;
begin
  LDoc := BSON([CT_KEY, AValue]);
  FMongoResultSetAdapter.Document := LDoc;
  FQuery.query := FMongoResultSetAdapter.Document;
//  FQuery.Query(NAME_COLLECTION, FMongoResultSetAdapter.Document);
  FMongoResultSetAdapter.Next;
end;

procedure TMongoResultSetAdapterTest.SetUp;
begin
  inherited;
  FMongoResultSetAdapter := TMongoResultSetAdapter.Create(Query, nil);
end;

procedure TMongoResultSetAdapterTest.TearDown;
begin
  FMongoResultSetAdapter.Free;
  FQuery := nil;
  inherited;
end;

procedure TMongoResultSetAdapterTest.TestIsEmpty;
begin
  Connection.find(NAME_COLLECTION, Query) ;
  CheckTrue(FMongoResultSetAdapter.IsEmpty);
end;

procedure TMongoResultSetAdapterTest.TestIsEmpty_False;
begin
  InsertObject(Connection, 10);
  Connection.find(NAME_COLLECTION, Query);
  CheckFalse(FMongoResultSetAdapter.IsEmpty);
end;

procedure TMongoResultSetAdapterTest.TestNext;
begin
  CheckTrue(FMongoResultSetAdapter.Next);
end;

procedure TMongoResultSetAdapterTest.TestGetFieldValue;
var
  ReturnValue: Variant;
  iValue: Integer;
begin
  iValue := Random(1000000);
  InsertObject(FConnection, iValue);
  try
    FetchValue(iValue);
    ReturnValue := FMongoResultSetAdapter.GetFieldValue(0);
    CheckEquals(iValue, Integer(ReturnValue));
  finally
    RemoveObject(FConnection, iValue);
  end;
end;

procedure TMongoResultSetAdapterTest.TestGetFieldValue1;
var
  ReturnValue: Variant;
  iValue: Integer;
begin
  iValue := Random(1000000);
  InsertObject(FConnection, iValue);
  try
    FetchValue(iValue);
    ReturnValue := FMongoResultSetAdapter.GetFieldValue(CT_KEY);
    CheckEquals(iValue, Integer(ReturnValue));
  finally
    RemoveObject(FConnection, iValue);
  end;
end;

procedure TMongoResultSetAdapterTest.TestGetFieldCount;
var
  ReturnValue: Integer;
  iValue: Integer;
begin
  ReturnValue := FMongoResultSetAdapter.GetFieldCount;
  CheckEquals(0, ReturnValue);
  iValue := Random(1000000);
  InsertObject(FConnection, iValue);
  try
    FetchValue(iValue);
    ReturnValue := FMongoResultSetAdapter.GetFieldCount;
    CheckEquals(1, ReturnValue);
  finally
    RemoveObject(FConnection, iValue);
  end;
end;

procedure TMongoResultSetAdapterTest.TestGetFieldName;
var
  ReturnValue: string;
  iValue: Integer;
begin
  iValue := Random(1000000);
  InsertObject(FConnection, iValue);
  try
    FetchValue(iValue);
    ReturnValue := FMongoResultSetAdapter.GetFieldName(0);
    CheckEqualsString(CT_KEY, ReturnValue);
  finally
    RemoveObject(FConnection, iValue);
  end;
end;

{$ENDREGION}


{$REGION 'TMongoStatementAdapterTest'}

procedure TMongoStatementAdapterTest.SetUp;
begin
  inherited;
  FMongoStatementAdapter := TMongoStatementAdapter.Create(Query, nil);
end;

procedure TMongoStatementAdapterTest.TearDown;
begin
  FMongoStatementAdapter.Free;
  FMongoStatementAdapter := nil;
  Connection.Free;
end;

procedure TMongoStatementAdapterTest.TestSetSQLCommand;
var
  LJson: string;
  LResult: Variant;
begin
  LJson := 'I[UnitTests.MongoTest]{"KEY": 1}';
  FMongoStatementAdapter.SetSQLCommand(LJson);
  FMongoStatementAdapter.Execute;

  LResult := GetKeyValue(1);
  CheckEquals(1, LResult);
end;

procedure TMongoStatementAdapterTest.TestSetParams;
begin
  // TODO: Setup method call parameters
 // FMongoStatementAdapter.SetParams(Params);
  // TODO: Validate method results
end;

procedure TMongoStatementAdapterTest.TestExecute;
var
  LJson: string;
  LResult: Variant;
begin
  LJson := 'I[UnitTests.MongoTest]{"KEY": 1}';
  FMongoStatementAdapter.SetSQLCommand(LJson);
  FMongoStatementAdapter.Execute;

  LResult := GetKeyValue(1);
  CheckEquals(1, LResult);
end;

procedure TMongoStatementAdapterTest.TestExecuteQuery;
var
  LJson: string;
  LResult: Variant;
  LResultset: IDBResultset;
begin
  LJson := 'I[UnitTests.MongoTest]{"KEY": 1}';
  FMongoStatementAdapter.SetSQLCommand(LJson);
  LResultset := FMongoStatementAdapter.ExecuteQuery;
  LResult := LResultset.GetFieldValue(0);
  CheckEquals(1, LResult);
end;

{$ENDREGION}


{$REGION 'TMongoConnectionAdapterTest'}

class constructor TMongoConnectionAdapterTest.Create;
begin
  DirMongoDB := 'D:\Downloads\Programming\General\NoSQL\mongodb-win32-i386-2.6.1\bin\';
end;

procedure TMongoConnectionAdapterTest.SetUp;
begin
  inherited;
  FConnection := TMongoDBConnection.Create('localhost');
  FConnection.Connected := True;
  FMongoConnectionAdapter := TMongoConnectionAdapter.Create(FConnection);
end;

procedure TMongoConnectionAdapterTest.TearDown;
begin
  FMongoConnectionAdapter.Free;
  FMongoConnectionAdapter := nil;
  FConnection.Free;
  inherited;
end;

procedure TMongoConnectionAdapterTest.TestConnect;
begin
  FMongoConnectionAdapter.Connect;
  CheckTrue(FMongoConnectionAdapter.IsConnected);
end;

procedure TMongoConnectionAdapterTest.TestDisconnect;
begin
  FMongoConnectionAdapter.Connect;
  CheckTrue(FMongoConnectionAdapter.IsConnected);
  FMongoConnectionAdapter.Disconnect;
  CheckFalse(FMongoConnectionAdapter.IsConnected);
end;

procedure TMongoConnectionAdapterTest.TestIsConnected;
begin
  FMongoConnectionAdapter.Connect;
  CheckTrue(FMongoConnectionAdapter.IsConnected);
  FMongoConnectionAdapter.Disconnect;
  CheckFalse(FMongoConnectionAdapter.IsConnected);
end;

procedure TMongoConnectionAdapterTest.TestCreateStatement;
var
  LStatement: IDBStatement;
begin
  LStatement := FMongoConnectionAdapter.CreateStatement;
  CheckTrue(Assigned(LStatement));
  LStatement := nil;
end;

procedure TMongoConnectionAdapterTest.TestBeginTransaction;
var
  LTran: IDBTransaction;
begin
  LTran := FMongoConnectionAdapter.BeginTransaction;
  CheckTrue(Assigned(LTran));
end;

procedure TMongoConnectionAdapterTest.TestGetQueryLanguage;
begin
  CheckEquals(qlMongoDB, FMongoConnectionAdapter.QueryLanguage);
end;

{$ENDREGION}


{$REGION 'TBaseMongoTest'}

function TBaseMongoTest.GetKeyValue(const AValue: Variant): Variant;
var
  LDoc, LFound: IBSONDocument;
begin
  LDoc := BSON([CT_KEY, AValue]);
  LFound := FConnection.findOne(NAME_COLLECTION, LDoc);
  if Assigned(LFound) then
    Result := LFound.value(CT_KEY);
end;

procedure TBaseMongoTest.SetUp;
begin
  inherited;
  FConnection := TMongoDBConnection.Create('localhost');
  FConnection.Connected := True;
  FQuery := TMongoDBQuery.Create(FConnection);
  FConnection.drop(NAME_COLLECTION); //delete all
end;

procedure TBaseMongoTest.TearDown;
begin
  FQuery.Free;
  FConnection.Free;
  inherited;
end;

{$ENDREGION}


{$REGION 'TMongoSessionTest'}

procedure TMongoSessionTest.AutogenerateId;
var
  LModel: TMongoAutogeneratedIdModel;
  LModelSaved: TMongoAutogeneratedIdModel;
begin
  LModel := TMongoAutogeneratedIdModel.Create;
  LModelSaved := nil;
  try
    LModel.Name := 'Autogenerated';
    LModel.Key := TMongoEntity.Create;
    LModel.Key.Key := 999;
    CheckTrue(VarIsEmpty(LModel.Id));
    FManager.Save(LModel);
    CheckFalse(VarIsEmpty(LModel.Id));


    LModelSaved := FManager.FindOne<TMongoAutogeneratedIdModel>(TValue.FromVariant(LModel.Id));
    CheckFalse(VarIsEmpty(LModelSaved.Id));
    CheckEquals('Autogenerated', LModelSaved.Name);
    CheckEquals(999, LModelSaved.Key.Key);
  finally
    LModel.Free;
    LModelSaved.Free;
  end;
end;

procedure TMongoSessionTest.SubObjectArray;
var
  LModel, LModelSaved: TMongoSubArrayModel;
begin
  LModel := TMongoSubArrayModel.Create;
  LModel.Name := 'SubArrayTest';
  LModel.Persons.Add(TPerson.Create('Foo'));
  LModel.Persons.Add(TPerson.Create('Bar'));

  FManager.Save(LModel);
  LModelSaved := FManager.FindOne<TMongoSubArrayModel>(TValue.FromVariant(LModel.Id));
  CheckEquals(2, LModelSaved.Persons.Count);
  CheckEquals('Foo', LModelSaved.Persons.First.Name);
  CheckEquals('Bar', LModelSaved.Persons.Last.Name);
  LModel.Free;
  LModelSaved.Free;
end;

procedure TMongoSessionTest.SubSimpleArray;
var
  LModel, LModelSaved: TMongoSubSimpleArrayModel;
begin
  LModel := TMongoSubSimpleArrayModel.Create;
  LModel.Name := 'SubArrayTest';
  LModel.Ages.Add(123);
  LModel.Ages.Add(999);

  FManager.Save(LModel);
  LModelSaved := FManager.FindOne<TMongoSubSimpleArrayModel>(TValue.FromVariant(LModel.Id));
  CheckEquals(2, LModelSaved.Ages.Count);
  CheckEquals(123, LModelSaved.Ages.First);
  CheckEquals(999, LModelSaved.Ages.Last);
  LModel.Free;
  LModelSaved.Free;
end;

procedure TMongoSessionTest.BulkInsert;
var
  LKeys: IList<TMongoAutogeneratedIdModel>;
  LKey: TMongoAutogeneratedIdModel;
  i, iSize: Integer;
  sw: TStopwatch;
begin
  LKeys := TCollections.CreateList<TMongoAutogeneratedIdModel>(True);
  {$IFDEF PERFORMANCE_TESTS}
  iSize := 10000;
  {$ELSE}
  iSize := 10;
  {$ENDIF}
  sw :=TStopwatch.StartNew;
  for i := 1 to iSize do
  begin
    LKey := TMongoAutogeneratedIdModel.Create;
    LKey.Name := 'Name ' + IntToStr(i);
    LKeys.Add(LKey);
  end;

  FManager.BulkInsert<TMongoAutogeneratedIdModel>(LKeys);
  sw.Stop;
  LKeys := FManager.FindAll<TMongoAutogeneratedIdModel>;
  CheckEquals(iSize, LKeys.Count);
  Status(Format('Bulk insert of %d entities in %d ms', [iSize, sw.ElapsedMilliseconds]));
end;

procedure TMongoSessionTest.FindAndModify;
var
  LResultDoc, LDoc: IBsonDocument;
  LIter: IDBResultset;
  LValue: Variant;
  LIntf: IInterface;
  i: Integer;
begin
  LResultDoc := FMongoConnection.findAndModify('UnitTests.AutoId', BSON(['_id', 1, '_version', 0]), bsonEmpty
  , BSON(['$inc', BSON(['_version', 1])]), true);
  CheckNotNull(LResultDoc);
  LValue := LResultDoc['ok'];
  CheckEquals(1, LValue);
  LValue := LResultDoc['value'];

  LResultDoc := FMongoConnection.findAndModify('UnitTests.AutoId', BSON(['_id', 1, '_version', 1]), bsonEmpty
  , BSON(['$inc', BSON(['_version', 1])]), true);
  CheckNotNull(LResultDoc);
  LValue := LResultDoc['ok'];
  CheckEquals(1, LValue);
  LValue := LResultDoc['value'];
  LIntf := LValue;
  LIter := (LIntf as IDBResultset);
  while not LIter.IsEmpty do
  begin
    for i := 0 to LIter.GetFieldCount - 1 do
    begin
      Status(Format('"%s": %s', [LIter.GetFieldName(i), VarToStrDef(LIter.GetFieldValue(i), 'Null')]));
    end;
  end;

  LDoc := FMongoConnection.findAndModify('UnitTests.AutoId', BSON(['_id', 2, '_version', 1]), bsonEmpty
  , BSON(['$inc', BSON(['_version', 1])]), false);
  LValue := LDoc['value'];
  CheckTrue(VarIsNull(LValue));
end;

procedure TMongoSessionTest.FindAll;
var
  LKey: TMongoEntity;
  LKeys: IList<TMongoEntity>;
begin
  LKey := TMongoEntity.Create;
  try
    LKey.Id := 1;
    LKey.Key := 100;

    FManager.Save(LKey);

    LKey.Id := 2;
    LKey.Key := 900;

    FManager.Save(LKey);

    LKeys := FManager.FindAll<TMongoEntity>;
    CheckEquals(2, LKeys.Count);

    FManager.Delete(LKey);
    LKey.Id := 1;
    FManager.Delete(LKey);
  finally
    LKey.Free;
  end;
end;

procedure TMongoSessionTest.First;
var
  LKey: TMongoEntity;
begin
  InsertObject(FMongoConnection, 100);
  LKey := nil;
  try
    LKey := FManager.FindOne<TMongoEntity>(1);
    CheckEquals(100, LKey.Key);
  finally
    RemoveObject(FMongoConnection, 100);
    LKey.Free;
  end;
end;

procedure TMongoSessionTest.Page;
var
  LPage: IDBPage<TMongoEntity>;
  LKey: TMongoEntity;
begin
  LKey := TMongoEntity.Create;
  try
    LKey.Id := 1;
    LKey.Key := 100;

    FManager.Save(LKey);

    LKey.Id := 2;
    LKey.Key := 900;

    FManager.Save(LKey);

    LPage := FManager.Page<TMongoEntity>(1, 10);
    CheckEquals(2, LPage.Items.Count);
  finally
    FManager.Delete(LKey);
    LKey.Id := 1;
    FManager.Delete(LKey);
    LKey.Free;
  end;
end;

{$IFDEF PERFORMANCE_TESTS}
procedure TMongoSessionTest.Performance;
var
  LKey: TMongoEntity;
  i, iCount: Integer;
  sw : TStopwatch;
begin
  FConnection.ClearExecutionListeners;
  iCount := 10000;
  sw := TStopwatch.StartNew;
  for i := 1 to iCount do
  begin
    LKey := TMongoEntity.Create;
    try
      LKey.FId := i;
      LKey.Key := i + 1;
      FManager.Save(LKey);
    finally
      LKey.Free;
    end;
  end;
  sw.Stop;
  Status(Format('Saved %d simple entities in %d ms', [iCount, sw.ElapsedMilliseconds]));
end;
{$ENDIF}

procedure TMongoSessionTest.RawQuery;
var
  LKeys: IList<TMongoEntity>;
begin
  InsertObject(FMongoConnection, 123, 1);
  //FirstLetter - Operation (S - select, U - update, I - insert, D - delete)
  //[Namespace.Collection]
  //{json query}
  LKeys := FManager.GetList<TMongoEntity>('S[UnitTests.MongoTest]{"KEY": 123}', []);
  CheckEquals(123, LKeys[0].Key);
  InsertObject(FMongoConnection, 124, 2);
  LKeys := FManager.GetList<TMongoEntity>('S[UnitTests.MongoTest]{"KEY": {"$gt": 122} }', []);
  CheckEquals(2, LKeys.Count);
end;

procedure TMongoSessionTest.Save_Update_Delete;
var
  LKey: TMongoEntity;
begin
  LKey := TMongoEntity.Create;

  LKey.FId := 2;
  LKey.Key := 100;
  LKey.Name := 'Foo';

  FManager.Save(LKey);

  LKey.FId := 3;
  LKey.Key := 111;
  LKey.Name := 'Bar';
  FManager.Save(LKey);
  LKey.Free;

  LKey := FManager.FindOne<TMongoEntity>(2);
  CheckEquals(100, LKey.Key, 'Key is 100');
  CheckEquals('Foo', LKey.Name, 'Name is Foo');

  LKey.Key := 999;
  FManager.Save(LKey);
  LKey.Free;

  LKey := FManager.FindOne<TMongoEntity>(3);
  CheckEquals(111, LKey.Key, 'Key is 111');
  CheckEquals('Bar', LKey.Name, 'Name is Bar');
  LKey.Free;

  LKey := FManager.FindOne<TMongoEntity>(2);
  CheckEquals(999, LKey.Key, 'Key is 999');
  CheckEquals('Foo', LKey.Name, 'Name is still Foo');

  FManager.Delete(LKey);

  LKey.Free;

  LKey := FManager.FindOne<TMongoEntity>(2);
  CheckNull(LKey, 'Entity should not exist');
end;

procedure TMongoSessionTest.SetUp;
begin
  inherited;
  FMongoConnection := TMongoDBConnection.Create;
  FMongoConnection.Connected := True;
  FConnection := TConnectionFactory.GetInstance(dtMongo, FMongoConnection);
  FConnection.AutoFreeConnection := True;
  FConnection.QueryLanguage := qlMongoDB;
  FManager := TMongoDBSession.Create(FConnection);
  FManager.Execute('D[UnitTests.MongoTest]{}', []); //delete all
  FManager.Execute('D[UnitTests.AutoId]{}', []); //delete all
  {$WARNINGS OFF}
  if DebugHook <> 0 then
  begin
    FConnection.AddExecutionListener(
      procedure(const command: string; const params: IEnumerable<TDBParam>)
      var
        param: TDBParam;
        i: Integer;
      begin
        Status(command);
        i := 0;
        for param in params do
        begin
          if VarType(param.ToVariant) <> varUnknown then
            Status(Format('%2:d Param %0:s = %1:s', [param.Name, VarToStrDef(param.ToVariant, 'NULL'), i]));
          Inc(i);
        end;
        Status('-----');
      end);
  end;
  {$WARNINGS ON}
end;

procedure TMongoSessionTest.SimpleCriteria_Between;
var
  LCriteria: ICriteria<TMongoEntity>;
  Key: IProperty;
  LKeys: IList<TMongoEntity>;
begin
  InsertObject(FMongoConnection, 100, 1);
  LCriteria := FManager.CreateCriteria<TMongoEntity>;
  Key := TProperty<TMongoEntity>.Create('KEY');

  LKeys := LCriteria.Add(Key.Between(1, 2)).ToList;
  CheckEquals(0, LKeys.Count, 'Between 0');

  LCriteria.Clear;

  LKeys := LCriteria.Add(Key.Between(99, 100)).ToList;
  CheckEquals(1, LKeys.Count, 'Between 1');
end;

procedure TMongoSessionTest.SimpleCriteria_Eq;
var
  LCriteria: ICriteria<TMongoEntity>;
  Key: IProperty;
  LKeys: IList<TMongoEntity>;
begin
  InsertObject(FMongoConnection, 100, 1);
  LCriteria := FManager.CreateCriteria<TMongoEntity>;
  Key := TProperty<TMongoEntity>.Create('KEY');
  LKeys := LCriteria.Add(Key.Eq(100)).ToList;
  CheckEquals(1, LKeys.Count, 'Eq');

  LCriteria.Clear;
  LKeys := LCriteria.Add(Key.NotEq(100)).ToList;
  CheckEquals(0, LKeys.Count, 'Not Eq');

  LCriteria.Clear;
  LKeys := LCriteria.Add(Key.GEq(101)).ToList;
  CheckEquals(0, LKeys.Count, 'Greater Eq');

  LCriteria.Clear;
  LKeys := LCriteria.Add(Key.Gt(100)).ToList;
  CheckEquals(0, LKeys.Count, 'Greater Than');

  LCriteria.Clear;
  LKeys := LCriteria.Add(Key.Lt(100)).ToList;
  CheckEquals(0, LKeys.Count, 'Less Than');

  LCriteria.Clear;
  LKeys := LCriteria.Add(Key.LEq(100)).ToList;
  CheckEquals(1, LKeys.Count, 'Less Than or equals');
end;

procedure TMongoSessionTest.SimpleCriteria_In;
var
  LCriteria: ICriteria<TMongoEntity>;
  Key: IProperty;
  LKeys: IList<TMongoEntity>;
begin
  InsertObject(FMongoConnection, 100, 1);
  LCriteria := FManager.CreateCriteria<TMongoEntity>;
  Key := TProperty<TMongoEntity>.Create('KEY');
  LKeys := LCriteria.Add(Key.&In(TArray<Integer>.Create(100,1,2))).ToList;
  CheckEquals(1, LKeys.Count, 'In');

  LCriteria.Clear;
  LKeys := LCriteria.Add(Key.NotIn(TArray<Integer>.Create(0,1,2))).ToList;
  CheckEquals(1, LKeys.Count, 'Not In');
end;

procedure TMongoSessionTest.SimpleCriteria_Like;
var
  LCriteria: ICriteria<TMongoEntity>;
  Name: IProperty;
  LKeys: IList<TMongoEntity>;
begin
  InsertObject(FMongoConnection, 100, 1, 'Foobar');
  LCriteria := FManager.CreateCriteria<TMongoEntity>;
  Name := TProperty<TMongoEntity>.Create('Name');

  LKeys := LCriteria.Add(Name.NotLike('bar')).ToList;
  CheckEquals(0, LKeys.Count, 'Not Like');

  LCriteria.Clear;
  LKeys := LCriteria.Add(Name.Like('bar')).ToList;
  CheckEquals(1, LKeys.Count, 'Like');
end;

procedure TMongoSessionTest.SimpleCriteria_Not;
var
  LCriteria: ICriteria<TMongoEntity>;
  Key: IProperty;
  LKeys: IList<TMongoEntity>;
begin
  InsertObject(FMongoConnection, 100, 1);
  LCriteria := FManager.CreateCriteria<TMongoEntity>;
  Key := TProperty<TMongoEntity>.Create('KEY');

  LKeys := LCriteria.Add(Restrictions.&Not( Key.Eq(100))).ToList;
  CheckEquals(0, LKeys.Count, 'Not');
end;

procedure TMongoSessionTest.SimpleCriteria_Null;
var
  LCriteria: ICriteria<TMongoEntity>;
  Key: IProperty;
  LKeys: IList<TMongoEntity>;
begin
  InsertObject(FMongoConnection, Null, 1);
  LCriteria := FManager.CreateCriteria<TMongoEntity>;
  Key := TProperty<TMongoEntity>.Create('KEY');
  LKeys := LCriteria.Add(Key.IsNotNull).ToList;
  CheckEquals(0, LKeys.Count, 'Not Null');

  LCriteria.Clear;
  LKeys := LCriteria.Add(Key.IsNull).ToList;
  CheckEquals(1, LKeys.Count, 'Is Null');
end;

procedure TMongoSessionTest.SimpleCriteria_Or;
var
  LCriteria: ICriteria<TMongoEntity>;
  Key, Id: IProperty;
  LKeys: IList<TMongoEntity>;
begin
  InsertObject(FMongoConnection, 999, 1);
  LCriteria := FManager.CreateCriteria<TMongoEntity>;
  Key := TProperty<TMongoEntity>.Create('KEY');
  Id := TProperty<TMongoEntity>.Create('_id');

  LKeys := LCriteria.Add(Restrictions.Or(Key.NotEq(999), Id.NotEq(1)) ).ToList;
  CheckEquals(0, LKeys.Count, 'Simple Or');
end;

procedure TMongoSessionTest.SimpleCriteria_OrderBy;
var
  LCriteria: ICriteria<TMongoEntity>;
  Key: IProperty;
  LKeys: IList<TMongoEntity>;
begin
  InsertObject(FMongoConnection, 999, 1);
  InsertObject(FMongoConnection, 1000, 2);
  LCriteria := FManager.CreateCriteria<TMongoEntity>;
  Key := TProperty<TMongoEntity>.Create('KEY');

  LKeys := LCriteria.OrderBy(Key.Desc).ToList;
  CheckEquals(2, LKeys.Count);
  CheckEquals(1000, LKeys.First.Key);
  CheckEquals(999, LKeys.Last.Key);
end;

procedure TMongoSessionTest.TearDown;
begin
  inherited;
  FManager.Execute('D[UnitTests.MongoTest]{}', []); //delete all
  FManager.Execute('D[UnitTests.AutoId]{}', []); //delete all
  FManager.Free;
  FConnection := nil;
end;

procedure TMongoSessionTest.Versioning;
var
  LModel, LModelOld, LModelLoaded: TMongoSubArrayModel;
  bOk: Boolean;
begin
  LModel := TMongoSubArrayModel.Create;
  LModel.Name := 'Initial version';
  LModel.Version := 454; //doesnt matter what we set now
  FManager.Save(LModel);

  LModelLoaded := FManager.FindOne<TMongoSubArrayModel>(TValue.FromVariant(LModel.Id));
  CheckEquals(0, LModelLoaded.Version);
  LModelLoaded.Name := 'Updated version No. 1';

  LModelOld := FManager.FindOne<TMongoSubArrayModel>(TValue.FromVariant(LModel.Id));
  CheckEquals(0, LModelOld.Version);
  LModelOld.Name := 'Updated version No. 2';

  FManager.Save(LModelLoaded);
  CheckEquals(1, LModelLoaded.Version);

  try
    FManager.Save(LModelOld);
    bOk := False;
  except
    on E:EORMOptimisticLockException do
    begin
      bOk := True;
    end;
  end;
  CheckTrue(bOk, 'This should fail because version already changed to the same entity');

  LModel.Free;
  LModelLoaded.Free;
  LModelOld.Free;
end;

{$ENDREGION}


{$REGION 'TestMongoRepository'}

procedure TMongoRepositoryTest.InsertList;
var
  LKeys: IList<TMongoEntity>;
  LKey: TMongoEntity;
  i, iSize: Integer;
begin
  LKeys := TCollections.CreateList<TMongoEntity>(True);
  iSize := 100;
  for i := 1 to iSize do
  begin
    LKey := TMongoEntity.Create;
    LKey.Id := i;
    LKey.Key := 1234;
    LKeys.Add(LKey);
  end;
  FRepository.Insert(LKeys);
  CheckEquals(iSize, FRepository.Count);
end;

procedure TMongoRepositoryTest.Query;
var
  LKeys: IList<TMongoEntity>;
begin
  InsertObject(FMongoConnection, 100, 1);
  InsertObject(FMongoConnection, 999, 2);

  LKeys := FRepository.Query('{_id: { $in: [1, 2] } }', []);
  CheckEquals(2, LKeys.Count);
end;

procedure TMongoRepositoryTest.SetUp;
begin
  inherited;
  FMongoConnection := TMongoDBConnection.Create;
  FMongoConnection.Connected := True;
  FConnection := TConnectionFactory.GetInstance(dtMongo, FMongoConnection);
  FConnection.AutoFreeConnection := True;
  FConnection.QueryLanguage := qlMongoDB;
  FSession := TMongoDBSession.Create(FConnection);
  FSession.Execute('D[UnitTests.MongoTest]{}', []); //delete all
  FSession.Execute('D[UnitTests.AutoId]{}', []); //delete all
  FRepository := TMongoDBRepository<TMongoEntity, Integer>.Create(FSession);
end;

procedure TMongoRepositoryTest.TearDown;
begin
  FSession.Execute('D[UnitTests.MongoTest]{}', []); //delete all
  FSession.Execute('D[UnitTests.AutoId]{}', []); //delete all
  FSession.Free;
  FConnection := nil;
  inherited;
end;


{ TMongoAutogeneratedIdModel }

constructor TMongoAutogeneratedIdModel.Create;
begin
  inherited Create;
 // FKey := TMongoAdapter.Create;
end;

destructor TMongoAutogeneratedIdModel.Destroy;
begin
  FKey.Free;
  inherited;
end;

{ TMongoSubArrayModel }

constructor TMongoSubArrayModel.Create;
begin
  inherited;
  FPersons := TCollections.CreateObjectList<TPerson>;
end;

{ TPerson }

constructor TPerson.Create;
begin
  inherited;
end;

constructor TPerson.Create(const AName: string);
begin
  Create;
  FName := AName;
end;

{ TMongoSubSimpleArrayModel }

constructor TMongoSubSimpleArrayModel.Create;
begin
  inherited;
  FAges := TCollections.CreateList<Integer>;
end;

{$ENDREGION}


{$REGION 'TMongoProxyRepositoryTest'}

procedure TMongoProxyRepositoryTest.CustomMethod;
var
  LKeys: IList<TMongoEntity>;
begin
  InsertObject(FConnection, 100, 1);

  LKeys := FProxyRepository.CustomQuery;
  CheckEquals(1, LKeys.Count);
end;

procedure TMongoProxyRepositoryTest.CustomMethodWithArgument_ReturnObject;
var
  LModel: TMongoEntity;
begin
  InsertObject(FConnection, 100, 1);
  LModel := FProxyRepository.CustomQueryWithArgumentReturnObject(1);
  CheckEquals(100, LModel.Key);
  LModel.Free;
end;

procedure TMongoProxyRepositoryTest.CustomMethodWithStringArgument_ReturnObject;
var
  LModel: TMongoEntity;
begin
  InsertObject(FConnection, 100, 1, 'Foo');
  LModel := FProxyRepository.CustomQueryWithStringArgumentReturnObject('Foo');
  CheckEquals(100, LModel.Key);
  CheckEquals('Foo', LModel.Name);
  LModel.Free;
end;

procedure TMongoProxyRepositoryTest.CustomMethod_ReturnObject;
var
  LModel: TMongoEntity;
begin
  InsertObject(FConnection, 100, 1);

  LModel := FProxyRepository.CustomQueryReturnObject;
  CheckEquals(100, LModel.Key);
  LModel.Free;
end;

procedure TMongoProxyRepositoryTest.DefaultMethod_Count;
begin
  InsertObject(FConnection, 100, 1);

  CheckEquals(1, FProxyRepository.Count);
end;

procedure TMongoProxyRepositoryTest.DefaultMethod_Delete;
var
  LModel: TMongoEntity;
begin
  InsertObject(FConnection, 100, 1);
  LModel := TMongoEntity.Create;
  LModel.Id := 1;
  LModel.Key := 100;
  FProxyRepository.Delete(LModel);
  CheckFalse(FProxyRepository.Exists(1));
  LModel.Free;
end;

procedure TMongoProxyRepositoryTest.DefaultMethod_DeleteList;
var
  LModel: TMongoEntity;
  LKeys: IList<TMongoEntity>;
begin
  InsertObject(FConnection, 100, 1);
  LKeys := TCollections.CreateObjectList<TMongoEntity>;
  LModel := TMongoEntity.Create;
  LModel.Id := 1;
  LModel.Key := 100;
  LKeys.Add(LModel);
  FProxyRepository.Delete(LKeys);
  CheckFalse(FProxyRepository.Exists(1));
  InsertObject(FConnection, 100, 1);
  FProxyRepository.DeleteAll;
  CheckFalse(FProxyRepository.Exists(1));
end;

procedure TMongoProxyRepositoryTest.DefaultMethod_Execute;
var
  LRes: NativeUInt;
begin
  LRes := FProxyRepository.Execute('I[UnitTests.MongoTest]{"KEY": ?$}', [1]);
  CheckEquals(1, LRes);
end;

procedure TMongoProxyRepositoryTest.DefaultMethod_Exists;
begin
  InsertObject(FConnection, 100, 1);
  CheckTrue(FProxyRepository.Exists(1));
end;

procedure TMongoProxyRepositoryTest.DefaultMethod_FindAll;
begin
  InsertObject(FConnection, 100, 1);
  CheckEquals(1, FProxyRepository.FindAll.Count);
end;

procedure TMongoProxyRepositoryTest.DefaultMethod_FindOne;
var
  LModel: TMongoEntity;
begin
  InsertObject(FConnection, 100, 1);
  LModel := FProxyRepository.FindOne(1);
  CheckEquals(100, LModel.Key);
  LModel.Free;
end;

procedure TMongoProxyRepositoryTest.DefaultMethod_Insert;
var
  LModel: TMongoEntity;
begin
  LModel := TMongoEntity.Create;
  LModel.Id := 1;
  LModel.Key := 100;
  FProxyRepository.Insert(LModel);
  CheckTrue(FProxyRepository.Exists(1));
  LModel.Free;
end;

procedure TMongoProxyRepositoryTest.DefaultMethod_InsertList;
var
  LModel: TMongoEntity;
  LKeys: IList<TMongoEntity>;
begin
  CheckFalse(FProxyRepository.Exists(1));
  LKeys := TCollections.CreateObjectList<TMongoEntity>;
  LModel := TMongoEntity.Create;
  LModel.Id := 1;
  LModel.Key := 100;
  LKeys.Add(LModel);

  FProxyRepository.Insert(LKeys);
  CheckTrue(FProxyRepository.Exists(1));
end;

procedure TMongoProxyRepositoryTest.DefaultMethod_FindWhere;
begin
  InsertObject(FConnection, 100, 1);
  CheckEquals(1, FProxyRepository.FindWhere.Page(1,10).ItemCount);
end;

procedure TMongoProxyRepositoryTest.DefaultMethod_FindWhere_Expression;
var
  Key: Prop;
begin
  InsertObject(FConnection, 100, 1);
  Key := Prop.Create('KEY');
  CheckEquals(1, FProxyRepository.FindWhere.Add(Key = 100).Page(1,10).ItemCount);
end;

procedure TMongoProxyRepositoryTest.DefaultMethod_Query;
var
  LKeys: IList<TMongoEntity>;
begin
  LKeys := FProxyRepository.Query('{}', []);
  CheckEquals(0, LKeys.Count);
end;

procedure TMongoProxyRepositoryTest.DefaultMethod_Save;
var
  LModel: TMongoEntity;
begin
  LModel := TMongoEntity.Create;
  LModel.Id := 1;
  LModel.Key := 100;
  LModel := FProxyRepository.Save(LModel);
  CheckTrue(FProxyRepository.Exists(1));
  LModel.Free;
end;

procedure TMongoProxyRepositoryTest.DefaultMethod_SaveCascade;
var
  LModel: TMongoEntity;
begin
  LModel := TMongoEntity.Create;
  LModel.Id := 1;
  LModel.Key := 100;
  FProxyRepository.SaveCascade(LModel);
  CheckTrue(FProxyRepository.Exists(1));
  LModel.Free;
end;

procedure TMongoProxyRepositoryTest.DefaultMethod_SaveList;
var
  LKeys: IList<TMongoEntity>;
  LSavedKeys: IEnumerable<TMongoEntity>;
  LModel: TMongoEntity;
begin
  LKeys := TCollections.CreateObjectList<TMongoEntity>;
  LModel := TMongoEntity.Create;
  LModel.Id := 1;
  LModel.Key := 100;
  LKeys.Add(LModel);
  LSavedKeys := FProxyRepository.Save(LKeys);
  CheckTrue(FProxyRepository.Exists(1));
end;

procedure TMongoProxyRepositoryTest.SetUp;
begin
  inherited;
  FDBConnection := TConnectionFactory.GetInstance(dtMongo, Connection);
  FDBConnection.QueryLanguage := qlMongoDB;
  FSession := TMongoDBSession.Create(FDBConnection);
  FProxyRepository := TProxyRepository<TMongoEntity, Integer>.Create(FSession, TypeInfo(ICustomerRepository)
    , TMongoDBRepository<TMongoEntity, Integer>) as ICustomerRepository;
end;

procedure TMongoProxyRepositoryTest.TearDown;
begin
  FSession.Free;
  inherited;
end;

{$ENDREGION}


var
  sExecLine: string;
  StartInfo: TStartupInfo;
  ProcInfo: TProcessInformation;
  bCreated: Boolean;

initialization
  if DirectoryExists(TMongoConnectionAdapterTest.DirMongoDB) then
  begin
    sExecLine := TMongoConnectionAdapterTest.DirMongoDB + 'mongod.exe' +
      Format(' --dbpath "%s" --journal', [TMongoConnectionAdapterTest.DirMongoDB + 'data\db']);

    FillChar(StartInfo,SizeOf(TStartupInfo),#0);
    FillChar(ProcInfo,SizeOf(TProcessInformation),#0);
    StartInfo.cb := SizeOf(TStartupInfo);
    StartInfo.wShowWindow := SW_HIDE;
    bCreated := CreateProcess(nil, PChar(sExecLine), nil, nil, True, 0, nil, nil, StartInfo, ProcInfo);
    if bCreated then
    begin
      RegisterTests('Spring.Persistence.Adapters', [
        TMongoResultSetAdapterTest.Suite,
        TMongoStatementAdapterTest.Suite,
        TMongoConnectionAdapterTest.Suite,
        TMongoSessionTest.Suite,
        TMongoRepositoryTest.Suite
      {$IF CompilerVersion > 22}
        ,TMongoProxyRepositoryTest.Suite
      {$IFEND}
      ]);
    end;
  end;

finalization
  if bCreated then
    TerminateProcess(ProcInfo.hProcess, 0);

end.

