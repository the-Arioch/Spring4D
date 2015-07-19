unit Spring.Persistence.Core.Observable;

interface

uses
  Spring,
  Spring.Collections,
  Classes,
  SysUtils;

type
  TAction<T> = reference to procedure(const item: T);

  EOnErrorHandlerNotAssigned = class(Exception);

  ISubscription = interface(IInvokable)
    procedure Unsubscribe;
    function IsUnsubscribed: Boolean;
  end;

  IObservable<T> = interface(IInvokable)
    function Subscribe(const onNext: TAction<T>; const onError: TAction<Exception>; const onComplete: TProc): ISubscription;
  end;

  ISubscriber<T> = interface(IInvokable)
    procedure OnNext(const item: T);
    procedure OnError(const exception: Exception);
    procedure OnComplete;

    procedure Unsubscribe;
    function IsUnsubscribed: Boolean;
  end;

  TSubscriber<T> = class(TInterfacedObject, ISubscriber<T>, ISubscription)
  private
    fOnNext: TAction<T>;
    fOnError: TAction<Exception>;
    fOnComplete: TProc;
    fUnsubscribed: Boolean;
  protected
    procedure OnNext(const item: T);
    procedure OnError(const exception: Exception);
    procedure OnComplete;

    procedure Unsubscribe;
    function IsUnsubscribed: Boolean;
  public
    constructor Create(const doOnNext: TAction<T>; const doOnError: TAction<Exception>; const doOnComplete: TProc); virtual;
  end;

  TObservable<T> = class(TInterfacedObject, IObservable<T>)
  private
    fSubscriberAction: TAction<ISubscriber<T>>;
  protected
    procedure ProcessSubscriber(const subscriber: ISubscriber<T>);
    function Subscribe(const onNext: TAction<T>; const onError: TAction<Exception>; const onComplete: TProc): ISubscription; virtual;
  public
    constructor Create(const subscriberAction: TAction<ISubscriber<T>>); virtual;
    destructor Destroy; override;
  end;

implementation

{ TObservable<T> }

constructor TObservable<T>.Create(const subscriberAction: TAction<ISubscriber<T>>);
begin
  fSubscriberAction := subscriberAction;
end;

destructor TObservable<T>.Destroy;
begin
  inherited Destroy;
end;

procedure TObservable<T>.ProcessSubscriber(const subscriber: ISubscriber<T>);
begin
  fSubscriberAction(subscriber);
end;

function TObservable<T>.Subscribe(const onNext: TAction<T>; const onError: TAction<Exception>; const onComplete: TProc): ISubscription;
var
  subscriber: TSubscriber<T>;
begin
  subscriber := TSubscriber<T>.Create(onNext, onError, onComplete);
  ProcessSubscriber(subscriber);
  Result := subscriber;
end;

{ TSubscriber<T> }

constructor TSubscriber<T>.Create(const doOnNext: TAction<T>;
  const doOnError: TAction<Exception>; const doOnComplete: TProc);
begin
  fOnNext := doOnNext;
  fOnError := doOnError;
  fOnComplete := doOnComplete;
end;

function TSubscriber<T>.IsUnsubscribed: Boolean;
begin
  Result := fUnsubscribed;
end;

procedure TSubscriber<T>.OnComplete;
begin
  if Assigned(fOnComplete) then
    fOnComplete();
end;

procedure TSubscriber<T>.OnError(const exception: Exception);
begin
  if not Assigned(fOnError) then
    raise EOnErrorHandlerNotAssigned.CreateFmt('On Error Handler Is Not Assigned. Exception raised: %s',
      [exception.ToString]);

  fOnError(exception);
end;

procedure TSubscriber<T>.OnNext(const item: T);
begin
  if not IsUnsubscribed then
  begin
    fOnNext(item);
  end;
end;

procedure TSubscriber<T>.Unsubscribe;
begin
  fUnsubscribed := True;
end;

end.
