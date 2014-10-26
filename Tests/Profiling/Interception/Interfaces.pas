unit Interfaces;

interface

type
  ITest = interface(IInvokable)
    procedure TestProc1;
    procedure TestProc2(const i: Integer);
    procedure TestProc3(const i: Integer; const s: string);
  end;

implementation

end.
