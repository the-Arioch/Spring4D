unit CustomerRepositoryDecorator;

interface

uses
  Customer,
  Spring.Collections,
  Spring.Container.Common,
  Spring.Logging,
  Spring.Persistence.Core.Interfaces,
  Spring.Persistence.Core.Repository.Simple;

type
  TCustomerRepositoryDecorator = class(TSimpleRepository<TCustomer,string>)
  private
    fRepository: IPagedRepository<TCustomer,string>;
    [Inject]
    fLogger: ILogger;
  public
    constructor Create(const repository: IPagedRepository<TCustomer,string>); reintroduce;
    function FindAll: IList<TCustomer>; override;
    function FindOne(const id: string): TCustomer; override;
  end;

implementation

{ TCustomerRepositoryDecorator }

constructor TCustomerRepositoryDecorator.Create(
  const repository: IPagedRepository<TCustomer, string>);
begin
  inherited Create(nil);
  fRepository := repository;
end;

function TCustomerRepositoryDecorator.FindAll: IList<TCustomer>;
begin
  fLogger.Enter('FindAll');
  Result := fRepository.FindAll;
  fLogger.LogValue('Result.Count', Result.Count);
  fLogger.Leave('FindAll');
end;

function TCustomerRepositoryDecorator.FindOne(const id: string): TCustomer;
begin
  fLogger.Enter('FindOne');
  fLogger.LogValue('id', id);
  Result := fRepository.FindOne(id);
  fLogger.LogValue('Result', Result);
  fLogger.Leave('FindOne');
end;

end.
