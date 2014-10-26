unit ManualDI;

interface

procedure StartUp;

implementation

uses
  MainForm, Forms,
  CustomersViewModel, Customer,
  Spring.Persistence.Core.Interfaces,
  CustomerRepository,
  Spring.Persistence.Core.Session,
  Spring.Persistence.Adapters.SQLite,
  SQLiteTable3;

procedure StartUp;
var
  database: TSQLiteDatabase;
  connection: IDBConnection;
  session: TSession;
  repository: IPagedRepository<TCustomer,string>;
  viewModel: TObject;
  view: TCustomersView;
begin
  database := TSQLiteDatabase.Create('Northwind.db3');
  connection := TSQLiteConnectionAdapter.Create(database);
  connection.AutoFreeConnection := True;
  session := TSession.Create(connection);
  repository := TCustomerRepository.Create(session);
  viewModel := TCustomersViewModel.Create(repository);
  Application.CreateForm(TCustomersView, view);
  view.DataContext := viewModel;

  ReportMemoryLeaksOnShutdown := True;
end;

end.
