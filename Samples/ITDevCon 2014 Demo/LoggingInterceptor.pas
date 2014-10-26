unit LoggingInterceptor;

interface

uses
  Spring.Interception,
  Spring.Logging;

type
  TLoggingInterceptor = class(TInterfacedObject, IInterceptor)
  private
    fLogger: ILogger;
  public
    constructor Create(const logger: ILogger);
    procedure Intercept(const invocation: IInvocation);
  end;

implementation

uses
  Rtti,
  SysUtils;

{ TLoggingInterceptor }

constructor TLoggingInterceptor.Create(const logger: ILogger);
begin
  inherited Create;
  fLogger := logger;
end;

procedure TLoggingInterceptor.Intercept(const invocation: IInvocation);
var
  i: Integer;
  param: TRttiParameter;
begin
  fLogger.Enter(invocation.Method.Name);
  i := 0;
  for param in invocation.Method.GetParameters do
  begin
    fLogger.LogValue(param.Name, invocation.Arguments[i]);
    Inc(i);
  end;
  try
    invocation.Proceed;
    if invocation.Method.ReturnType <> nil then
      fLogger.LogValue('Result', invocation.Result);
    fLogger.Leave(invocation.Method.Name);
  except
    on E: Exception do
    begin
      fLogger.Error('error', E);
      raise;
    end;
  end;
end;

end.
