unit Registrations;

interface

uses
  Spring.Container;

procedure RegisterTypes;

implementation

uses
  MainForm, Forms,
  CustomersViewModel, Customer,
  Spring.Persistence.Core.Interfaces,
  CustomerRepository,
  Spring.Persistence.Core.Session,
  Spring.Persistence.Core.ConnectionFactory,
  Spring.Persistence.Adapters.SQLite;

procedure RegisterTypes;
const
  ConnectionString = '{"SQLiteTable3.TSQLiteDatabase": {"Filename": "Northwind.db3"}}';
var
  container: TContainer;
begin
  container := GlobalContainer;

  container.RegisterType<TSession,TSession>;
  container.RegisterType<IDBConnection>.DelegateTo(
    function: IDBConnection
    begin
      Result := TConnectionFactory.GetInstance(dtSQLite, ConnectionString);
    end);
  container.RegisterType<IPagedRepository<TCustomer,string>, TCustomerRepository>;

  container.RegisterType<TObject, TCustomersViewModel>('customersViewModel').AsSingleton;

  container.RegisterType<TCustomersView, TCustomersView>.DelegateTo(
    function: TCustomersView
    begin
      Application.CreateForm(TCustomersView, Result);
    end);

  container.Build;
end;

end.
