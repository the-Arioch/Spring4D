unit CustomerRepository;

interface

uses
  Customer,
  Spring.Collections,
  Spring.Persistence.Core.Repository.Simple;

type
  TCustomerRepository = class(TSimpleRepository<TCustomer,string>);

implementation

end.
