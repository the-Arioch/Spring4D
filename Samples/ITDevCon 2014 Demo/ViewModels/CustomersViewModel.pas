unit CustomersViewModel;

interface

uses
  Customer,
  DSharp.Core.PropertyChangedBase,
  Spring,
  Spring.Collections,
  Spring.Persistence.Core.Interfaces;

{$DEFINE USE_LAZY}

type
  TCustomersViewModel = class(TPropertyChangedBase)
  private
    fCustomers: IObjectList;
    fCustomerId: string;
{$IFDEF USE_LAZY}
    fCustomerRepository: Lazy<IPagedRepository<TCustomer,string>>;
{$ELSE}
    fCustomerRepository: IPagedRepository<TCustomer,string>;
{$ENDIF}
  public
{$IFDEF USE_LAZY}
    constructor Create(const customerRespository: Lazy<IPagedRepository<TCustomer,string>>);
{$ELSE}
    constructor Create(const customerRespository: IPagedRepository<TCustomer,string>);
{$ENDIF}

    procedure LoadCustomers(Sender: TObject);
    property Customers: IObjectList read fCustomers;
    property CustomerId: string read fCustomerId write fCustomerId;
  end;

implementation

{ TCustomersViewModel }

{$IFDEF USE_LAZY}
constructor TCustomersViewModel.Create(
  const customerRespository: Lazy<IPagedRepository<TCustomer, string>>);
{$ELSE}
constructor TCustomersViewModel.Create(
  const customerRespository: IPagedRepository<TCustomer, string>);
{$ENDIF}
begin
  inherited Create;
  fCustomerRepository := customerRespository;
end;

procedure TCustomersViewModel.LoadCustomers(Sender: TObject);
begin
  // load customers
  if fCustomerId = '' then
    fCustomers := fCustomerRepository{$IFDEF USE_LAZY}.Value{$ENDIF}.FindAll as IObjectList
  else
  begin
    fCustomers := TCollections.CreateList<TCustomer>(True) as IObjectList;
    fCustomers.Add(fCustomerRepository{$IFDEF USE_LAZY}.Value{$ENDIF}.FindOne(fCustomerId));
  end;

  NotifyOfPropertyChange('Customers');
end;

end.
