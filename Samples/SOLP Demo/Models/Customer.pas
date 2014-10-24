unit Customer;

interface

uses
  Spring.Persistence.Mapping.Attributes;

type
  [Table('Customers')]
  TCustomer = class
  private
    FCustomerId: string;
    FCompanyName: string;
    FCity: string;
  public
    [Column([cpPrimaryKey])]
    property CustomerId: string read FCustomerId write FCustomerId;
    [Column]
    property CompanyName: string read FCompanyName write FCompanyName;
    [Column]
    property City: string read FCity write FCity;
  end;

implementation

end.
