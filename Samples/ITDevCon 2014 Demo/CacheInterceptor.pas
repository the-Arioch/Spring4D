unit CacheInterceptor;

interface

uses
  Rtti,
  Spring.Interception,
  Spring.Logging;

type
  TCacheInterceptor = class(TInterfacedObject, IInterceptor)
  private
    fLastUpdated: TDateTime;
    fValue: TValue;
  public
    procedure Intercept(const invocation: IInvocation);
  end;

implementation

uses
  DateUtils,
  SysUtils;

{ TCacheInterceptor }

procedure TCacheInterceptor.Intercept(const invocation: IInvocation);
begin
  if invocation.Method.Name = 'FindAll' then
  begin
    if SecondsBetween(fLastUpdated, Now) < 10 then
    begin
      invocation.Result := fValue;
      Exit;
    end;
  end;

  invocation.Proceed;
  fValue := invocation.Result;
  fLastUpdated := Now;
end;

end.
