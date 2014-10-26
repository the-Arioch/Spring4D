unit TestImpl;

interface

uses
  Interfaces;

type
  TTest = class(TInterfacedObject, ITest)
  public
    procedure TestProc1;
    procedure TestProc2(const i: Integer);
    procedure TestProc3(const i: Integer; const s: string);
  end;

implementation

{ TTest }

procedure TTest.TestProc1;
begin
end;

procedure TTest.TestProc2(const i: Integer);
begin
end;

procedure TTest.TestProc3(const i: Integer; const s: string);
begin
end;

end.
