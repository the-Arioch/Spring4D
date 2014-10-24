program CustomerList;

uses
  Vcl.Forms,
  Spring.Container,
  MainForm in 'Views\MainForm.pas' {CustomersView},
  CustomersViewModel in 'ViewModels\CustomersViewModel.pas',
  Customer in 'Models\Customer.pas',
  CustomerRepository in 'Services\CustomerRepository.pas',
  Registrations in 'Registrations.pas',
  ManualDI in 'ManualDI.pas';

{$R *.res}
{.$DEFINE USE_CONTAINER}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
{$IFDEF USE_CONTAINER}
  RegisterTypes;
  GlobalContainer.Resolve<TCustomersView>;
{$ELSE}
  ManualDI.StartUp;
{$ENDIF}
  Application.Run;
end.
