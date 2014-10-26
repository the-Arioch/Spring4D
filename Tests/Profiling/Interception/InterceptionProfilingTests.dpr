program InterceptionProfilingTests;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  Interfaces in 'Interfaces.pas',
  Main in 'Main.pas',
  TestImpl in 'TestImpl.pas';

begin
  try
    RunTests;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;
end.
