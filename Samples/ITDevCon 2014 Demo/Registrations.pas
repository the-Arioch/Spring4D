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
  Spring.Persistence.Adapters.SQLite,
  Spring.Interception,
  LoggingInterceptor,
  CacheInterceptor,
  Spring.Logging,
  Spring.Logging.Loggers,
  Spring.Logging.Controller,
  Spring.Container.DecoratorExtension,
  CustomerRepositoryDecorator,
  Spring.Logging.Appenders.CodeSite;

procedure RegisterTypes;
const
  ConnectionString = '{"SQLiteTable3.TSQLiteDatabase": {"Filename": "Northwind.db3"}}';
var
  container: TContainer;
begin
  container := GlobalContainer;

  // using classic decorator but managed by container
//  container.AddExtension<TDecoratorContainerExtension>;
//  container.RegisterType<IPagedRepository<TCustomer,string>, TCustomerRepositoryDecorator>;

  // logging
  container.RegisterType<ILogAppender, TCodeSiteAppender>('codesite');
  container.RegisterType<ILoggerController, TLoggerController>;
  container.RegisterType<ILogger, TLogger>.AsSingleton;

  // interception
  container.RegisterType<IInterceptor, TCacheInterceptor>('caching');
  container.RegisterType<IInterceptor, TLoggingInterceptor>('logging');

  // database
  container.RegisterType<IDBConnection>.DelegateTo(
    function: IDBConnection
    begin
      Result := TConnectionFactory.GetInstance(dtSQLite, ConnectionString);
    end);
  container.RegisterType<TSession,TSession>.AsSingleton;
  container.RegisterType<IPagedRepository<TCustomer,string>, TCustomerRepository>;

  // viewmodel
  container.RegisterType<TObject, TCustomersViewModel>('customersViewModel').AsSingleton;

  // gui
  container.RegisterType<TCustomersView, TCustomersView>.DelegateTo(
    function: TCustomersView
    begin
      Application.CreateForm(TCustomersView, Result);
    end);

  container.Build;
end;

end.
