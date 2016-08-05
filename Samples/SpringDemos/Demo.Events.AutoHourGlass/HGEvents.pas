unit HGEvents;

interface
uses Spring.Events;

type
  TEvent<T> = class( Spring.Events.TEvent<T> )
    protected
      procedure InternalInvoke(Params: Pointer; StackSize: Integer); override;
  end;

implementation
uses Deltics.Hourglass;

{ TEvent<T> }

procedure TEvent<T>.InternalInvoke(Params: Pointer; StackSize: Integer);
begin
  HourglassOn;
  inherited;
end;

end.
