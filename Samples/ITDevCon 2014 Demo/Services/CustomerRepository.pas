unit CustomerRepository;

interface

uses
  Customer,
  Spring.Collections,
  Spring.Container.Common,
  Spring.Persistence.Core.Repository.Simple,
  Spring.Persistence.Core.Session;

type
  [Interceptor('caching')]
  [Interceptor('logging')]
  TCustomerRepository = class(TSimpleRepository<TCustomer,string>)
  public
    constructor Create(const session: TSession); override;
  end;

implementation

{ TCustomerRepository }

constructor TCustomerRepository.Create(const session: TSession);
begin
  inherited Create(session);
end;

end.
