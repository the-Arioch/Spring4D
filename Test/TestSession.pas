unit TestSession;
{

  Delphi DUnit Test Case
  ----------------------
  This unit contains a skeleton test case class generated by the Test Case Wizard.
  Modify the generated code to correctly setup and call the methods from the unit
  being tested.

}

{$I sv.inc}

interface

uses
  TestFramework, Windows, Forms, Dialogs, Controls, Classes, SysUtils,
  Variants, Graphics, Messages, StdCtrls, Core.Session, Core.Interfaces
  ,uModels, Rtti, SQLiteTable3;

type

  TestTSession = class(TTestCase)
  private
    FConnection: IDBConnection;
    FManager: TSession;
  public
    procedure SetUp; override;
    procedure TearDown; override;

    procedure GetLazyNullable();
  published
    procedure First();
    procedure Fetch();
    procedure Inheritance_Simple_Customer();
    procedure Insert();
    procedure InsertFromCollection();
    procedure Update();
    procedure Delete();
    procedure Save();
    procedure ExecutionListeners();
    procedure Page();
    procedure ExecuteScalar();
    procedure Execute();
    procedure Nullable();
    procedure GetLazyValueClass();
    procedure GetLazyValue();
    procedure FindOne();
    procedure FindAll();
    procedure Enums();
    procedure Streams();
    procedure ManyToOne();
    procedure Transactions();
    procedure FetchCollection();
    {$IFDEF USE_SPRING}
    procedure ListSession_Begin_Commit();
    {$ENDIF}
  end;

  TInsertData = record
    Age: Integer;
    Name: string;
    Height: Double;
    Picture: TStream;
  end;

var
  TestDB: TSQLiteDatabase = nil;

procedure InsertCustomer(AAge: Integer = 25; AName: string = 'Demo'; AHeight: Double = 15.25; APicture: TStream = nil);
procedure InsertCustomerOrder(ACustID: Integer; ACustPaymID: Integer; AOrderStatusCode: Integer; ATotalPrice: Double);
procedure ClearTable(const ATableName: string);


implementation

uses
  Adapters.SQLite
  ,Core.ConnectionFactory
  ,SQL.Register
  ,SQL.Params
  ,SvDesignPatterns
  {$IFDEF USE_SPRING} ,Spring.Collections {$ENDIF}
  ,Generics.Collections
  ,Core.Reflection
  ,TestConsts
  ,Core.Criteria.Properties
  ;


const
  SQL_GET_ALL_CUSTOMERS = 'SELECT * FROM ' + TBL_PEOPLE + ';';

function GetPictureSize(APicture: TPicture): Int64;
var
  LStream: TMemoryStream;
begin
  Result := 0;
  if Assigned(APicture) then
  begin
    LStream := TMemoryStream.Create;
    try
      APicture.Graphic.SaveToStream(LStream);

      Result := LStream.Size;
    finally
      LStream.Free;
    end;
  end;
end;



procedure CreateTables(AConnection: TSQLiteDatabase = nil);
var
  LConn: TSQLiteDatabase;
begin
  if Assigned(AConnection) then
    LConn := AConnection
  else
    LConn := TestDB;

  LConn.ExecSQL('CREATE TABLE IF NOT EXISTS '+ TBL_PEOPLE + ' ([CUSTID] INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, [CUSTAGE] INTEGER NULL,'+
    '[CUSTNAME] VARCHAR (255), [CUSTHEIGHT] FLOAT, [LastEdited] DATETIME, [EMAIL] TEXT, [MIDDLENAME] TEXT, [AVATAR] BLOB, [AVATARLAZY] BLOB NULL'+
    ',[CUSTTYPE] INTEGER, [CUSTSTREAM] BLOB, [COUNTRY] TEXT );');

  LConn.ExecSQL('CREATE TABLE IF NOT EXISTS '+ TBL_ORDERS + ' ('+
    '"ORDER_ID" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,'+
    '"Customer_ID" INTEGER NOT NULL CONSTRAINT "FK_Customer_Orders" REFERENCES "Customers"("CUSTID") ON DELETE CASCADE ON UPDATE CASCADE,'+
    '"Customer_Payment_Method_Id" INTEGER,'+
    '"Order_Status_Code" INTEGER,'+
    '"Date_Order_Placed" DATETIME DEFAULT CURRENT_TIMESTAMP,'+
    '"Total_Order_Price" FLOAT);');

  if not LConn.TableExists(TBL_PEOPLE) then
    raise Exception.Create('Table CUSTOMERS does not exist');
end;

procedure InsertCustomer(AAge: Integer = 25; AName: string = 'Demo'; AHeight: Double = 15.25; APicture: TStream = nil);
begin
  TestDB.ExecSQL('INSERT INTO  ' + TBL_PEOPLE + ' (['+CUSTAGE+'], ['+CUSTNAME+'], ['+CUSTHEIGHT+']) VALUES (?,?,?);',
    [AAge, AName, AHeight]);
end;

procedure InsertCustomerEnum(AType: Integer; AAge: Integer = 25; AName: string = 'Demo'; AHeight: Double = 15.25);
begin
  TestDB.ExecSQL('INSERT INTO  ' + TBL_PEOPLE + ' (['+CUSTAGE+'], ['+CUSTNAME+'], ['+CUSTHEIGHT+'], ['+CUSTTYPE+']) VALUES (?,?,?,?);',
    [AAge, AName, AHeight, AType]);
end;

procedure InsertCustomerNullable(AAge: Integer = 25; AName: string = 'Demo'; AHeight: Double = 15.25; const AMiddleName: string = ''; APicture: TStream = nil);
begin
  TestDB.ExecSQL('INSERT INTO  ' + TBL_PEOPLE + ' (['+CUSTAGE+'], ['+CUSTNAME+'], ['+CUSTHEIGHT+'], ['+CUST_MIDDLENAME+']) VALUES (?,?,?,?);',
    [AAge, AName, AHeight, AMiddleName]);
end;

procedure InsertCustomerAvatar(AAge: Integer = 25; AName: string = 'Demo'; AHeight: Double = 15.25; const AMiddleName: string = ''; APicture: TStream = nil);
var
  LRows: Integer;
begin
  TestDB.ExecSQL('INSERT INTO  ' + TBL_PEOPLE + ' (['+CUSTAGE+'], ['+CUSTNAME+'], ['+CUSTHEIGHT+'], ['+CUST_MIDDLENAME+'], ['+CUSTAVATAR+'], ['+CUSTAVATAR_LAZY+']) VALUES (?,?,?,?,?,?);',
    [AAge, AName, AHeight, AMiddleName, APicture, APicture], LRows);
  if LRows < 1 then
    raise Exception.Create('Cannot insert into table');
end;

procedure InsertCustomerOrder(ACustID: Integer; ACustPaymID: Integer; AOrderStatusCode: Integer; ATotalPrice: Double);
begin
  TestDB.ExecSQL('INSERT INTO  ' + TBL_ORDERS + ' ([Customer_Id], [Customer_Payment_Method_Id], [Order_Status_Code], [Total_Order_Price]) '+
    ' VALUES (?,?,?,?);',
    [ACustID, ACustPaymID, AOrderStatusCode, ATotalPrice]);
end;

procedure ClearTable(const ATableName: string);
begin
  TestDB.ExecSQL('DELETE FROM ' + ATableName + ';');
end;

function GetDBValue(const ASql: string): Variant;
begin
  Result := TestDB.GetUniTableIntf(ASql).Fields[0].Value;
end;


function GetTableRecordCount(const ATablename: string; AConnection: TSQLiteDatabase = nil): Int64;
var
  LConn: TSQLiteDatabase;
begin
  if Assigned(AConnection) then
  begin
    LConn := TSQLiteDatabase.Create(AConnection.Filename);
    try
      Result := LConn.GetUniTableIntf('SELECT COUNT(*) FROM ' + ATablename).Fields[0].Value;
    finally
      LConn.Free;
    end;
  end
  else
    Result := GetDBValue('SELECT COUNT(*) FROM ' + ATablename);
end;

procedure TestTSession.Delete;
var
  LCustomer: TCustomer;
  sSql: string;
  LResults: ISQLiteTable;
begin
  sSql := 'select * from ' + TBL_PEOPLE;

  InsertCustomer();

  LCustomer := FManager.FirstOrDefault<TCustomer>(sSql, []);
  try
    CheckEquals(25, LCustomer.Age);

    FManager.Delete(LCustomer);

    LResults := TestDB.GetUniTableIntf('SELECT COUNT(*) FROM ' + TBL_PEOPLE);
    CheckEquals(0, LResults.Fields[0].AsInteger);

  finally
    LCustomer.Free;
  end;

  //try insert after deletion
  LCustomer := TCustomer.Create;
  try
    LCustomer.Name := 'Inserted';

    FManager.Save(LCustomer);

    LResults := TestDB.GetUniTableIntf('SELECT COUNT(*) FROM ' + TBL_PEOPLE);
    CheckEquals(1, LResults.Fields[0].AsInteger);

  finally
    LCustomer.Free;
  end;
end;

const
  SQL_EXEC_SCALAR = 'SELECT COUNT(*) FROM ' + TBL_PEOPLE + ';';

procedure TestTSession.Enums;
var
  LCustomer: TCustomer;
  iLastID: Integer;
  LVal: Variant;
begin
  InsertCustomer();
  iLastID := TestDB.GetLastInsertRowID;
  LCustomer := FManager.FindOne<TCustomer>(iLastID);
  try
    CheckTrue(ctOneTime = LCustomer.CustomerType);
  finally
    LCustomer.Free;
  end;

  InsertCustomerEnum(Ord(ctBusinessClass));
  iLastID := TestDB.GetLastInsertRowID;
  LCustomer := FManager.FindOne<TCustomer>(iLastID);
  try
    CheckTrue(ctBusinessClass = LCustomer.CustomerType);

    LCustomer.CustomerType := ctReturning;
    FManager.Save(LCustomer);
    LVal := GetDBValue(Format('select custtype from ' + TBL_PEOPLE + ' where custid = %D', [iLastID]));
    CheckTrue(Integer(LVal) = Ord(ctReturning));
  finally
    LCustomer.Free;
  end;

  InsertCustomerEnum(20);
  iLastID := TestDB.GetLastInsertRowID;
  LCustomer := FManager.FindOne<TCustomer>(iLastID);
  try
    CheckTrue(20 = Ord(LCustomer.CustomerType));
  finally
    LCustomer.Free;
  end;
end;

procedure TestTSession.Execute;
begin
  FManager.Execute('INSERT INTO CUSTOMERS SELECT * FROM CUSTOMERS;', []);
end;

procedure TestTSession.ExecuteScalar;
var
  LRes: Integer;
begin
  LRes := FManager.ExecuteScalar<Integer>(SQL_EXEC_SCALAR, []);
  CheckEquals(0, LRes);
  InsertCustomer();
  LRes := FManager.ExecuteScalar<Integer>(SQL_EXEC_SCALAR, []);
  CheckEquals(1, LRes);
end;

procedure TestTSession.ExecutionListeners;
var
  sLog, sLog2, sSql: string;
  iParamCount1, iParamCount2: Integer;
  LCustomer: TCustomer;
begin
  sLog := '';
  sLog2 := '';
  FConnection.AddExecutionListener(
    procedure(const ACommand: string; const AParams: TObjectList<TDBParam>)
    begin
      sLog := ACommand;
      iParamCount1 := AParams.Count;
    end);

  FConnection.AddExecutionListener(
    procedure(const ACommand: string; const AParams: TObjectList<TDBParam>)
    begin
      sLog2 := ACommand;
      iParamCount2 := AParams.Count;
    end);

  InsertCustomer();
  sSql := 'select * from ' + TBL_PEOPLE;
  LCustomer := FManager.FirstOrDefault<TCustomer>(sSql, []);
  try
    CheckTrue(sLog <> '');
    CheckTrue(sLog2 <> '');
    CheckEqualsString(sLog, sLog2);
    CheckEquals(0, iParamCount1);
    CheckEquals(0, iParamCount2);

    LCustomer.Name := 'Execution Listener test';
    LCustomer.Age := 58;

    sLog := '';
    sLog2 := '';

    FManager.Update(LCustomer);

    CheckTrue(sLog <> '');
    CheckTrue(sLog2 <> '');
    CheckEqualsString(sLog, sLog2);
    CheckTrue(iParamCount1 > 1);
    CheckTrue(iParamCount2 > 1);

    sLog := '';
    sLog2 := '';
    LCustomer.Name := 'Insert Execution Listener test';
    FManager.Insert(LCustomer);

    CheckTrue(sLog <> '');
    CheckTrue(sLog2 <> '');
    CheckEqualsString(sLog, sLog2);
    CheckTrue(iParamCount1 > 0);
    CheckTrue(iParamCount2 > 0);

    sLog := '';
    sLog2 := '';
    FManager.Delete(LCustomer);
    CheckTrue(sLog <> '');
    CheckTrue(sLog2 <> '');
    CheckEqualsString(sLog, sLog2);
    CheckTrue(iParamCount1 = 1);
    CheckTrue(iParamCount2 = 1);

    Status(sLog);

  finally
    LCustomer.Free;
  end;
end;

procedure TestTSession.Fetch;
var
  LCollection: {$IFDEF USE_SPRING} Spring.Collections.IList<TCustomer> {$ELSE} TObjectList<TCustomer> {$ENDIF} ;
  sSql: string;
begin
  sSql := 'SELECT * FROM ' + TBL_PEOPLE;
  {$IFDEF USE_SPRING}
  LCollection := TCollections.CreateList<TCustomer>(True);
  {$ELSE}
  LCollection := TObjectList<TCustomer>.Create(True);
  {$ENDIF}

  FManager.Fetch<TCustomer>(sSql, [], LCollection);
  CheckEquals(0, LCollection.Count);

  LCollection.Clear;

  InsertCustomer();
  FManager.Fetch<TCustomer>(sSql, [], LCollection);
  CheckEquals(1, LCollection.Count);
  CheckEquals(25, LCollection[0].Age);

  LCollection.Clear;

  InsertCustomer(15);
  FManager.Fetch<TCustomer>(sSql, [], LCollection);
  CheckEquals(2, LCollection.Count);
  CheckEquals(15, LCollection[1].Age);
  {$IFNDEF USE_SPRING}
  LCollection.Free;
  {$ENDIF}
end;

procedure TestTSession.FetchCollection;
var
  LCollection: IList<TCustomer>;
begin
  InsertCustomer();
  LCollection := TCollections.CreateObjectList<TCustomer>;
  FManager.Fetch<TCustomer>('SELECT * FROM ' + TBL_PEOPLE, [], LCollection);
  CheckEquals(1, LCollection.Count);
end;

procedure TestTSession.FindAll;
var
  LCollection: {$IFDEF USE_SPRING} Spring.Collections.IList<TCustomer> {$ELSE} TObjectList<TCustomer> {$ENDIF} ;
  i: Integer;
begin
  LCollection := FManager.FindAll<TCustomer>;
  CheckEquals(0, LCollection.Count);
  TestDB.BeginTransaction;
  for i := 1 to 10 do
  begin
    InsertCustomer(i);
  end;
  TestDB.Commit;
  {$IFNDEF USE_SPRING}
  LCollection.Free;
  {$ENDIF}

  LCollection := FManager.FindAll<TCustomer>;
  CheckEquals(10, LCollection.Count);

  {$IFNDEF USE_SPRING}
  LCollection.Free;
  {$ENDIF}
end;

procedure TestTSession.FindOne;
var
  LCustomer: TCustomer;
  RowID: Integer;
begin
  LCustomer := FManager.FindOne<TCustomer>(1);
  CheckTrue(LCustomer = nil);

  InsertCustomer();
  RowID := TestDB.GetLastInsertRowID;
  LCustomer := FManager.FindOne<TCustomer>(RowID);
  try
    CheckTrue(LCustomer <> nil);
    CheckEquals(RowID, LCustomer.ID);
  finally
    LCustomer.Free;
  end;
end;

procedure TestTSession.First;
var
  LCustomer: TCustomer;
  sSql: string;
  fsPic: TFileStream;
begin
  sSql := 'SELECT * FROM ' + TBL_PEOPLE;
  LCustomer := FManager.FirstOrDefault<TCustomer>(sSql, []);

  CheckTrue(System.Default(TCustomer) = LCustomer);

  fsPic := TFileStream.Create(PictureFilename, fmOpenRead or fmShareDenyNone);
  try
    fsPic.Position := 0;
    InsertCustomerAvatar(25, 'Demo', 15.25, '', fsPic);
  finally
    fsPic.Free;
  end;

  LCustomer := FManager.First<TCustomer>(sSql, []);
  try
    CheckTrue(Assigned(LCustomer));
    CheckEquals(25, LCustomer.Age);

    CheckTrue(LCustomer.Avatar.Graphic <> nil);
  finally
    FreeAndNil(LCustomer);
  end;
  InsertCustomer(15);

  LCustomer := FManager.First<TCustomer>(sSql, []);
  try
    CheckTrue(Assigned(LCustomer));
    CheckEquals(25, LCustomer.Age);
  finally
    FreeAndNil(LCustomer);
  end;

  sSql := sSql + ' WHERE '+CUSTAGE+' = :0 AND '+CUSTNAME+'=:1';
  LCustomer := FManager.First<TCustomer>(sSql, [15, 'Demo']);
  try
    CheckTrue(Assigned(LCustomer));
    CheckEquals(15, LCustomer.Age);
  finally
    FreeAndNil(LCustomer);
  end;
end;

procedure TestTSession.GetLazyNullable;
var
  LCustomer: TCustomer;
  fsPic: TFileStream;
begin
  fsPic := TFileStream.Create(PictureFilename, fmOpenRead or fmShareDenyNone);
  try
    LCustomer := FManager.SingleOrDefault<TCustomer>('select * from ' + TBL_PEOPLE, []);
    try
      CheckTrue(LCustomer.AvatarLazy.IsNull);
    finally
      LCustomer.Free;
    end;

    InsertCustomerAvatar(25, 'Nullable Lazy', 2.36, 'Middle', fsPic);

    LCustomer := FManager.SingleOrDefault<TCustomer>('select * from ' + TBL_PEOPLE, []);
    try
      CheckFalse(LCustomer.AvatarLazy.IsNull);
    finally
      LCustomer.Free;
    end;

  finally
    fsPic.Free;
  end;
end;

procedure TestTSession.GetLazyValue;
var
  LCustomer: TCustomer;
  LList: IList<TCustomer_Orders>;
begin
  LCustomer := TCustomer.Create;
  try
    LCustomer.Name := 'Test';
    LCustomer.Age := 10;

    FManager.Save(LCustomer);

    InsertCustomerOrder(LCustomer.ID, 10, 5, 100.59);
    InsertCustomerOrder(LCustomer.ID, 20, 15, 150.59);

    CheckEquals(2, LCustomer.Orders.Count);

    LList := TCollections.CreateObjectList<TCustomer_Orders>(True);

    FManager.SetLazyValue<IList<TCustomer_Orders>>(LList, LCustomer.ID, LCustomer, nil);

    CheckEquals(2, LList.Count);
    CheckEquals(LCustomer.ID, LList.First.Customer_ID);
    CheckEquals(10, LList.First.Customer_Payment_Method_Id);
    CheckEquals(5, LList.First.Order_Status_Code);
    CheckEquals(LCustomer.ID, LList.Last.Customer_ID);
    CheckEquals(20, LList.Last.Customer_Payment_Method_Id);
    CheckEquals(15, LList.Last.Order_Status_Code);

  finally
    LCustomer.Free;
  end;

  LCustomer := FManager.SingleOrDefault<TCustomer>('SELECT * FROM ' + TBL_PEOPLE, []);
  try
    CheckEquals(2, LCustomer.OrdersIntf.Count);
    CheckEquals(LCustomer.ID, LCustomer.OrdersIntf.First.Customer_ID);
    CheckEquals(10, LCustomer.OrdersIntf.First.Customer_Payment_Method_Id);
    CheckEquals(5, LCustomer.OrdersIntf.First.Order_Status_Code);
    CheckEquals(LCustomer.ID, LCustomer.OrdersIntf.Last.Customer_ID);
    CheckEquals(20, LCustomer.OrdersIntf.Last.Customer_Payment_Method_Id);
    CheckEquals(15, LCustomer.OrdersIntf.Last.Order_Status_Code);
  finally
    LCustomer.Free;
  end;

  ClearTable(TBL_ORDERS);
  LCustomer := FManager.SingleOrDefault<TCustomer>('SELECT * FROM ' + TBL_PEOPLE, []);
  try
    CheckEquals(0, LCustomer.OrdersIntf.Count);
  finally
    LCustomer.Free;
  end;
end;

procedure TestTSession.GetLazyValueClass;
var
  LCustomer: TCustomer;
  LOrder: TCustomer_Orders;
  LList: TObjectList<TCustomer_Orders>;
begin
  LCustomer := TCustomer.Create;
  try
    LCustomer.Name := 'Test';
    LCustomer.Age := 10;

    FManager.Save(LCustomer);

    InsertCustomerOrder(LCustomer.ID, 10, 5, 100.59);
    InsertCustomerOrder(LCustomer.ID, 20, 15, 150.59);

    CheckEquals(2, LCustomer.Orders.Count);

    LOrder := FManager.GetLazyValueClass<TCustomer_Orders>(LCustomer.ID, LCustomer, nil);
    try
      CheckTrue(Assigned(LOrder));
      CheckEquals(LOrder.Customer_ID, LCustomer.ID);
    finally
      LOrder.Free;
    end;

    LList := FManager.GetLazyValueClass<TObjectList<TCustomer_Orders>>(LCustomer.ID, LCustomer, nil);
    try
      CheckEquals(2, LList.Count);
      CheckEquals(LCustomer.ID, LList.First.Customer_ID);
      CheckEquals(10, LList.First.Customer_Payment_Method_Id);
      CheckEquals(5, LList.First.Order_Status_Code);
      CheckEquals(LCustomer.ID, LList.Last.Customer_ID);
      CheckEquals(20, LList.Last.Customer_Payment_Method_Id);
      CheckEquals(15, LList.Last.Order_Status_Code);
    finally
      LList.Free;
    end;
  finally
    LCustomer.Free;
  end;
end;

procedure TestTSession.Inheritance_Simple_Customer;
var
  LCustomer: TCustomer;
  LForeignCustomer: TForeignCustomer;
begin
  LForeignCustomer := TForeignCustomer.Create;
  LCustomer := nil;
  try
    LForeignCustomer.Country := 'US';
    LForeignCustomer.Name := 'John';
    LForeignCustomer.Age := 28;
    LForeignCustomer.EMail := 'john@gmail.com';

    FManager.Save(LForeignCustomer);

    LCustomer := FManager.FindOne<TCustomer>(LForeignCustomer.ID);

    CheckEquals('John', LCustomer.Name);
    CheckEquals(28, LCustomer.Age);
    LForeignCustomer.Free;

    LForeignCustomer := FManager.FindOne<TForeignCustomer>(LCustomer.ID);
    CheckEquals('US', LForeignCustomer.Country);
    CheckEquals('John', LForeignCustomer.Name);
    CheckEquals(28, LForeignCustomer.Age);

    LCustomer.Free;
    LForeignCustomer.Free;
    ClearTable(TBL_PEOPLE);

    LCustomer := TCustomer.Create;
    LCustomer.Name := 'Foo';
    FManager.Save(LCustomer);
    LForeignCustomer := FManager.FindOne<TForeignCustomer>(LCustomer.ID);

    CheckEquals('Foo', LForeignCustomer.Name);
    CheckTrue(LForeignCustomer.Country.IsNull);
  finally
    LForeignCustomer.Free;
    LCustomer.Free;
  end;
end;

procedure TestTSession.Insert;
var
  LCustomer: TCustomer;
  LTable: ISQLiteTable;
  LID, LCount: Int64;
begin
  LCustomer := TCustomer.Create;
  try
    LCustomer.Name := 'Insert test';
    LCustomer.Age := 10;
    LCustomer.Height := 1.1;
    LCustomer.Avatar.LoadFromFile(PictureFilename);

    FManager.Insert(LCustomer);

    LTable := TestDB.GetUniTableIntf('select * from ' + TBL_PEOPLE);
    CheckEqualsString(LCustomer.Name, LTable.FieldByName[CUSTNAME].AsString);
    CheckEquals(LCustomer.Age, LTable.FieldByName[CUSTAGE].AsInteger);
    LID := LTable.FieldByName[CUSTID].AsInteger;
    CheckEquals(LID, LCustomer.ID);
    CheckTrue(LTable.FieldByName[CUST_MIDDLENAME].IsNull);
    CheckFalse(LTable.FieldByName[CUSTAVATAR].IsNull);
  finally
    LCustomer.Free;
  end;

  LCustomer := TCustomer.Create;
  try
    LCustomer.Name := 'Insert test 2';
    LCustomer.Age := 15;
    LCustomer.Height := 41.1;
    LCustomer.MiddleName := 'Middle Test';

    FManager.Insert(LCustomer);
    LTable := TestDB.GetUniTableIntf('select * from ' + TBL_PEOPLE + ' where ['+CUSTAGE+'] = 15;');
    CheckEqualsString(LCustomer.Name, LTable.FieldByName[CUSTNAME].AsString);
    CheckEquals(LCustomer.Age, LTable.FieldByName[CUSTAGE].AsInteger);
    LID := LTable.FieldByName[CUSTID].AsInteger;
    CheckEquals(LID, LCustomer.ID);
    CheckEqualsString(LCustomer.MiddleName, LTable.FieldByName[CUST_MIDDLENAME].AsString);

    LCount := TestDB.GetUniTableIntf('select count(*) from ' + TBL_PEOPLE).Fields[0].AsInteger;
    CheckEquals(2, LCount);
  finally
    LCustomer.Free;
  end;
end;

procedure TestTSession.InsertFromCollection;
var
  LCollection: {$IFDEF USE_SPRING} Spring.Collections.IList<TCustomer> {$ELSE} TObjectList<TCustomer> {$ENDIF} ;
  LCustomer: TCustomer;
  i: Integer;
  LTran: IDBTransaction;
  LCount: Integer;
begin
  {$IFDEF USE_SPRING}
  LCollection := TCollections.CreateList<TCustomer>(True);
  {$ELSE}
  LCollection := TObjectList<TCustomer>.Create(True);
  {$ENDIF}
  try
    for i := 1 to 100 do
    begin
      LCustomer := TCustomer.Create;
      LCustomer.Name := IntToStr(i);
      LCustomer.Age := i;
      LCustomer.LastEdited := EncodeDate(2009, 1, 12);
      LCollection.Add(LCustomer);
    end;

    CheckEquals(100, LCollection.Count);

    //wrap in the transaction
    LTran := FManager.Connection.BeginTransaction;
    FManager.InsertList<TCustomer>(LCollection);
    LTran.Commit;
    LCount := TestDB.GetUniTableIntf('select count(*) from ' + TBL_PEOPLE).Fields[0].AsInteger;
    CheckEquals(LCollection.Count, LCount);
  finally
    {$IFNDEF USE_SPRING}
    LCollection.Free;
    {$ENDIF}
  end;
end;

{$IFDEF USE_SPRING}
procedure TestTSession.ListSession_Begin_Commit;
var
  LCustomers: IList<TCustomer>;
  LCustomer: TCustomer;
  LListSession: IListSession<TCustomer>;
  LProp: IProperty;
begin
  //fetch some customers from db
  InsertCustomer(15, 'Bar');
  InsertCustomer(10, 'Foo');
  LCustomers := FManager.FindAll<TCustomer>;
  CheckEquals(2, LCustomers.Count);
  LListSession := FManager.BeginListSession<TCustomer>(LCustomers);

  //add some customers
  LCustomer := TCustomer.Create();
  LCustomer.Age := 1;
  LCustomer.Name := 'New';
  LCustomers.Add(LCustomer);

  LCustomer := TCustomer.Create();
  LCustomer.Age := 9;
  LCustomer.Name := 'Cloud';
  LCustomers.Add(LCustomer);


  //delete customer which was fetched from database
  LCustomers.Delete(0);

  //edit customer which was fetched from the database
  LCustomers.First.Name := 'Edited Foo';
  LListSession.CommitListSession;

 // LCustomers := FManager.FindAll<TCustomer>;
  LProp := TProperty<TCustomer>.ForName('CUSTAGE');
  LCustomers := FManager.CreateCriteria<TCustomer>.AddOrder(LProp.Asc).List;
  CheckEquals(3, LCustomers.Count);
  CheckEquals(1, LCustomers.First.Age);
  CheckEquals(9, LCustomers[1].Age);
  CheckEquals(10, LCustomers[2].Age);
  CheckEquals('Edited Foo', LCustomers[2].Name);
end;
{$ENDIF}

const
  SQL_MANY_TO_ONE: string = 'SELECT O.*, C.CUSTID CUSTOMERS_Customer_ID_CUSTID '+
    ' ,C.CUSTNAME CUSTOMERS_Customer_ID_CUSTNAME, C.CUSTAGE CUSTOMERS_Customer_ID_CUSTAGE '+
    ' FROM '+ TBL_ORDERS + ' O '+
    ' LEFT OUTER JOIN ' + TBL_PEOPLE + ' C ON C.CUSTID=O.Customer_ID;';

procedure TestTSession.ManyToOne;
var
  LOrder: TCustomer_Orders;
  LCustomer: TCustomer;
  LID: Integer;
begin
  LCustomer := TCustomer.Create;
  try
    LCustomer.Name := 'ManyToOne';
    LCustomer.Age := 15;

    FManager.Save(LCustomer);

    InsertCustomerOrder(LCustomer.ID, 1, 1, 100.50);

    LOrder := FManager.Single<TCustomer_Orders>(SQL_MANY_TO_ONE, []);
    CheckTrue(Assigned(LOrder), 'Cannot get Order from DB');
    LID := LOrder.ORDER_ID;
    CheckTrue(Assigned(LOrder.Customer), 'Cannot get customer (inside order) from DB');
    CheckEqualsString(LCustomer.Name, LOrder.Customer.Name);
    CheckEquals(LCustomer.Age, LOrder.Customer.Age);
    FreeAndNil(LOrder);

    LOrder := FManager.FindOne<TCustomer_Orders>(LID);
    CheckTrue(Assigned(LOrder), 'Cannot get Order from DB');
    CheckTrue(Assigned(LOrder.Customer), 'Cannot get customer (inside order) from DB');
    CheckEqualsString(LCustomer.Name, LOrder.Customer.Name);
    CheckEquals(LCustomer.Age, LOrder.Customer.Age);
    FreeAndNil(LOrder);



    ClearTable(TBL_PEOPLE);
    LOrder := FManager.Single<TCustomer_Orders>(SQL_MANY_TO_ONE, []);
    CheckTrue(Assigned(LOrder), 'Cannot get Order from DB');
    CheckNotEqualsString(LCustomer.Name, LOrder.Customer.Name);
    FreeAndNil(LOrder);



  finally
    LCustomer.Free;
  end;
end;

procedure TestTSession.Nullable;
var
  LCustomer: TCustomer;
begin
  InsertCustomerNullable(25, 'Demo', 15.25, 'Middle');
  LCustomer := FManager.SingleOrDefault<TCustomer>('SELECT * FROM ' + TBL_PEOPLE, []);
  try
    CheckTrue(LCustomer.MiddleName.HasValue);
    CheckEqualsString('Middle', LCustomer.MiddleName.Value);
  finally
    LCustomer.Free;
  end;

  TestDB.ExecSQL('UPDATE ' + TBL_PEOPLE + ' SET '+CUST_MIDDLENAME+' = NULL;');
  LCustomer := FManager.SingleOrDefault<TCustomer>('SELECT * FROM ' + TBL_PEOPLE, []);
  try
    CheckTrue(LCustomer.MiddleName.IsNull);
  finally
    LCustomer.Free;
  end;
end;

procedure TestTSession.Page;
var
  LPage: IDBPage<TCustomer>;
  i: Integer;
  iTotal: Integer;
begin
  iTotal := 50;
  TestDB.BeginTransaction;
  for i := 1 to iTotal do
  begin
    InsertCustomer(i);
  end;
  TestDB.Commit;

  LPage := FManager.Page<TCustomer>(1, 10, 'select * from ' + TBL_PEOPLE, []);
  CheckEquals(iTotal, LPage.GetTotalItems);
  CheckEquals(10, LPage.Items.Count);
end;

procedure TestTSession.Save;
var
  LCustomer: TCustomer;
  LTable: ISQLiteTable;
  LID, LCount: Int64;
begin
  LCustomer := TCustomer.Create;
  try
    LCustomer.Name := 'Insert test';
    LCustomer.Age := 10;
    LCustomer.Height := 1.1;
    LCustomer.Avatar.LoadFromFile(PictureFilename);

    FManager.Save(LCustomer);

    LTable := TestDB.GetUniTableIntf('select * from ' + TBL_PEOPLE);
    CheckEqualsString(LCustomer.Name, LTable.FieldByName[CUSTNAME].AsString);
    CheckEquals(LCustomer.Age, LTable.FieldByName[CUSTAGE].AsInteger);
    LID := LTable.FieldByName[CUSTID].AsInteger;
    CheckEquals(LID, LCustomer.ID);
    CheckTrue(LTable.FieldByName[CUST_MIDDLENAME].IsNull);
    CheckFalse(LTable.FieldByName[CUSTAVATAR].IsNull);
  finally
    LCustomer.Free;
  end;

  LCustomer := TCustomer.Create;
  try
    LCustomer.Name := 'Insert test 2';
    LCustomer.Age := 15;
    LCustomer.Height := 41.1;
    LCustomer.MiddleName := 'Middle Test';

    FManager.Save(LCustomer);
    LTable := TestDB.GetUniTableIntf('select * from ' + TBL_PEOPLE + ' where ['+CUSTAGE+'] = 15;');
    CheckEqualsString(LCustomer.Name, LTable.FieldByName[CUSTNAME].AsString);
    CheckEquals(LCustomer.Age, LTable.FieldByName[CUSTAGE].AsInteger);
    LID := LTable.FieldByName[CUSTID].AsInteger;
    CheckEquals(LID, LCustomer.ID);
    CheckEqualsString(LCustomer.MiddleName, LTable.FieldByName[CUST_MIDDLENAME].AsString);

    LCount := TestDB.GetUniTableIntf('select count(*) from ' + TBL_PEOPLE).Fields[0].AsInteger;
    CheckEquals(2, LCount);
  finally
    LCustomer.Free;
  end;
end;

procedure TestTSession.SetUp;
begin
  FConnection := TConnectionFactory.GetInstance(dtSQLite, TestDB);
  FManager := TSession.Create(FConnection);
end;

procedure TestTSession.Streams;
var
  LCustomer: TCustomer;
  LResults: ISQLiteTable;
  LStream: TMemoryStream;
begin
  LCustomer := TCustomer.Create;
  try
    CheckTrue(LCustomer.CustStream.Size <= 0);

    LCustomer.CustStream.LoadFromFile(PictureFilename);

    FManager.Save(LCustomer);

    LResults := TestDB.GetUniTableIntf(SQL_GET_ALL_CUSTOMERS);
    CheckFalse(LResults.EOF);
    LStream := LResults.FieldByName[CUST_STREAM].AsBlob;
    CheckTrue(Assigned(LStream));
    try
      CheckTrue(LStream.Size > 0);
      CheckEquals(LCustomer.CustStream.Size, LStream.Size);
    finally
      LStream.Free;
    end;
  finally
    LCustomer.Free;
  end;
end;

procedure TestTSession.TearDown;
begin
  ClearTable(TBL_PEOPLE);
  ClearTable(TBL_ORDERS);
  FManager.Free;
end;

procedure TestTSession.Transactions;
var
  LCustomer: TCustomer;
  LDatabase: TSQLiteDatabase;
  LSession: TSession;
  LConn: IDBConnection;
  sFile: string;
begin
  LCustomer := TCustomer.Create;
  sFile := IncludeTrailingPathDelimiter(ExtractFileDir(ParamStr(0))) + 'test.db';
  DeleteFile(sFile);
  LDatabase := TSQLiteDatabase.Create(sFile);
  LDatabase.Open();
  LConn := TConnectionFactory.GetInstance(dtSQLite, LDatabase);
  LSession := TSession.Create(LConn);
  CreateTables(LDatabase);
  try
    LCustomer.Name := 'Transactions';
    LCustomer.Age := 1;

    LSession.BeginTransaction;
    LSession.Save(LCustomer);

    CheckEquals(0, GetTableRecordCount(TBL_PEOPLE, LDatabase));
    LSession.CommitTransaction;
    CheckEquals(1, GetTableRecordCount(TBL_PEOPLE, LDatabase));

    LSession.BeginTransaction;
    LSession.Delete(LCustomer);
    LSession.RollbackTransaction;
    CheckEquals(1, GetTableRecordCount(TBL_PEOPLE, LDatabase));
  finally
    LCustomer.Free;
    LDatabase.Close;
    LDatabase.Free;
    LSession.Free;
    LConn := nil;
    if not DeleteFile(sFile) then
    begin
      Status('Cannot delete file. Error: ' + SysErrorMessage(GetLastError));
    end;
  end;
end;

procedure TestTSession.Update;
var
  LCustomer: TCustomer;
  sSql: string;
  LResults: ISQLiteTable;
begin
  sSql := 'select * from ' + TBL_PEOPLE;

  InsertCustomer();

  LCustomer := FManager.FirstOrDefault<TCustomer>(sSql, []);
  try
    CheckEquals(25, LCustomer.Age);

    LCustomer.Age := 55;
    LCustomer.Name := 'Update Test';


    FManager.Update(LCustomer);

    LResults := TestDB.GetUniTableIntf('SELECT * FROM ' + TBL_PEOPLE);
    CheckEquals(LCustomer.Age, LResults.FieldByName[CUSTAGE].AsInteger);
    CheckEqualsString(LCustomer.Name, LResults.FieldByName[CUSTNAME].AsString);
    CheckTrue(LCustomer.MiddleName.IsNull);

    LCustomer.MiddleName := 'Middle';
    FManager.Update(LCustomer);

    LResults := TestDB.GetUniTableIntf('SELECT * FROM ' + TBL_PEOPLE);
    CheckEqualsString(LCustomer.MiddleName, LResults.FieldByName[CUST_MIDDLENAME].AsString);

  finally
    LCustomer.Free;
  end;
end;

type
  TSQLiteEvents = class
  public
    class procedure DoOnAfterOpen(Sender: TObject);
  end;

{ TSQLiteEvents }

class procedure TSQLiteEvents.DoOnAfterOpen(Sender: TObject);
begin
  CreateTables();
end;


initialization
  // Register any test cases with the test runner
  RegisterTest(TestTSession.Suite);

  TestDB := TSQLiteDatabase.Create(':memory:');
  TestDB.OnAfterOpen := TSQLiteEvents.DoOnAfterOpen;
  CreateTables();

finalization
  TestDB.Free;

end.

