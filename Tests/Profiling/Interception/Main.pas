unit Main;

interface

procedure RunTests;

implementation

uses
  Diagnostics,
  SysUtils,
  Interfaces,
  TestImpl,
  Spring.Interception;

type
  TTestInterceptor = class(TInterfacedObject, IInterceptor)
  public
    procedure Intercept(const invocation: IInvocation);
  end;

procedure MeasureIt(const proc: TProc; const msg: string);
const
  CallCount = 100000;
var
  sw: TStopwatch;
  i: Integer;
begin
  sw := TStopwatch.StartNew;
  for i := 1 to CallCount do
    proc();
  Writeln(Format('%s (%d times): %d ms', [msg, CallCount, sw.ElapsedMilliseconds]));
end;

procedure RunTestCases(const test: ITest; const msg: string);
begin
  Writeln(msg);
  MeasureIt(procedure begin test.TestProc1 end, 'no parameter');
  MeasureIt(procedure begin test.TestProc2(42) end, 'one parameter');
  MeasureIt(procedure begin test.TestProc3(42, 'hello world') end, 'two parameters');
end;

procedure RunTests;
var
  test: ITest;
  gen: TProxyGenerator;
  intercept: IInterceptor;
begin
  test := TTest.Create;
  RunTestCases(test, 'without interception');

  test := gen.CreateInterfaceProxyWithTarget(test, []);
  RunTestCases(test, 'with interception but no interceptor');

  test := TTest.Create;
  intercept := TTestInterceptor.Create;
  test := gen.CreateInterfaceProxyWithTarget(test, [intercept]);
  RunTestCases(test, 'with interception and one interceptor');

  test := TTest.Create;
  intercept := TTestInterceptor.Create;
  test := gen.CreateInterfaceProxyWithTarget(test, [intercept, intercept, intercept]);
  RunTestCases(test, 'with interception and three interceptors');
end;

{ TTestInterceptor }

procedure TTestInterceptor.Intercept(const invocation: IInvocation);
begin
  invocation.Proceed;
end;

end.
