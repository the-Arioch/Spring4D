unit Spring.Persistence.Core.Observable;

interface

uses
  Spring,
  Classes,
  SysUtils;

type
  TAction<T> = reference to procedure(const item: T);

  EOnErrorHandlerNotAssigned = class(Exception);

  IScheduler = interface(IInvokable)
    procedure Execute(const proc: TThreadProcedure);
  end;

  TMainThreadScheduler = class(TInterfacedObject, IScheduler)
  protected
    procedure Execute(const proc: TThreadProcedure);
  end;

  TNewThreadScheduler = class(TInterfacedObject, IScheduler)
  protected
    procedure Execute(const proc: TThreadProcedure);
  end;

  Schedulers = class sealed
  public
    class function MainThread: IScheduler; static;
    class function NewThread: IScheduler; static;
  end;

  ISubscription = interface(IInvokable)
    procedure Unsubscribe;
    function IsUnsubscribed: Boolean;
  end;

  IObservable<T> = interface(IInvokable)
    function Filter(const predicate: TPredicate<T>): IObservable<T>;
    function Subscribe(const onNext: TAction<T>; const onError: TAction<Exception> = nil;
      const onComplete: TProc = nil): ISubscription;
    function ObserveOn(const scheduler: IScheduler): IObservable<T>;
    function SubscribeOn(const scheduler: IScheduler): IObservable<T>;
  end;

  ISubscriber<T> = interface(ISubscription)
    procedure OnNext(const item: T);
    procedure OnError(const exception: Exception);
    procedure OnComplete;
  end;

  TSubscriber<T> = class(TInterfacedObject, ISubscriber<T>, ISubscription)
  private
    fOnNext: TAction<T>;
    fOnError: TAction<Exception>;
    fOnComplete: TProc;
    fUnsubscribed: Boolean;
    fScheduler: IScheduler;
    fCanGoNext: TPredicate<T>;
  protected
    procedure OnNext(const item: T);
    procedure OnError(const exception: Exception);
    procedure OnComplete;

    procedure Unsubscribe;
    function IsUnsubscribed: Boolean;
  public
    constructor Create(const doOnNext: TAction<T>; const doOnError: TAction<Exception>; const doOnComplete: TProc;
      const scheduler: IScheduler; const canGoNextPred: TPredicate<T>); virtual;
    destructor Destroy; override;
  end;

  TObservable<T> = class(TInterfacedObject, IObservable<T>)
  private
    fSubscriberAction: TAction<ISubscriber<T>>;
    fObserveOnScheduler: IScheduler;
    fSubscribeOnScheduler: IScheduler;
  protected
    procedure ProcessSubscriber(const subscriber: ISubscriber<T>);
    function CreateSubscriber(const onNext: TAction<T>; const onError: TAction<Exception>;
      const onComplete: TProc; const scheduler: IScheduler): ISubscriber<T>; virtual;
    function CanGoNext(item: T): Boolean; virtual;

    function Filter(const predicate: TPredicate<T>): IObservable<T>;

    function Subscribe(const onNext: TAction<T>; const onError: TAction<Exception> = nil;
      const onComplete: TProc = nil): ISubscription;

    function ObserveOn(const scheduler: IScheduler): IObservable<T>;
    function SubscribeOn(const scheduler: IScheduler): IObservable<T>;
  public
    constructor Create(const subscriberAction: TAction<ISubscriber<T>>); virtual;
    destructor Destroy; override;
  end;

  TFilteredObservable<T> = class(TObservable<T>)
  private
    fPredicate: TPredicate<T>;
  protected
    function CanGoNext(item: T): Boolean; override;
    constructor Create(const subscriberAction: TAction<ISubscriber<T>>; const predicate: TPredicate<T>); virtual;
  end;

implementation

{ TObservable<T> }

function TObservable<T>.CanGoNext(item: T): Boolean;
begin
  Result := True;
end;

constructor TObservable<T>.Create(const subscriberAction: TAction<ISubscriber<T>>);
begin
  fSubscriberAction := subscriberAction;
  fObserveOnScheduler := Schedulers.MainThread;
  fSubscribeOnScheduler := Schedulers.MainThread;
end;

function TObservable<T>.CreateSubscriber(const onNext: TAction<T>;
  const onError: TAction<Exception>; const onComplete: TProc; const scheduler: IScheduler): ISubscriber<T>;
begin
  Result := TSubscriber<T>.Create(onNext, onError, onComplete, scheduler, CanGoNext);
end;

destructor TObservable<T>.Destroy;
begin
  inherited Destroy;
end;

function TObservable<T>.Filter(const predicate: TPredicate<T>): IObservable<T>;
begin
  Result := TFilteredObservable<T>.Create(fSubscriberAction, predicate);
end;

function TObservable<T>.ObserveOn(const scheduler: IScheduler): IObservable<T>;
begin
  fObserveOnScheduler := scheduler;
  Result := Self;
end;

procedure TObservable<T>.ProcessSubscriber(const subscriber: ISubscriber<T>);
var
  action: TAction<ISubscriber<T>>;
begin
  action := fSubscriberAction;
  fSubscribeOnScheduler.Execute(procedure
    begin
      action(subscriber);
    end);
end;

function TObservable<T>.Subscribe(const onNext: TAction<T>; const onError: TAction<Exception>; const onComplete: TProc): ISubscription;
var
  subscriber: ISubscriber<T>;
begin
  subscriber := CreateSubscriber(onNext, onError, onComplete, fObserveOnScheduler);
  ProcessSubscriber(subscriber);
  Result := subscriber;
end;

function TObservable<T>.SubscribeOn(
  const scheduler: IScheduler): IObservable<T>;
begin
  fSubscribeOnScheduler := scheduler;
  Result := Self;
end;

{ TSubscriber<T> }

constructor TSubscriber<T>.Create(const doOnNext: TAction<T>;
  const doOnError: TAction<Exception>; const doOnComplete: TProc;
  const scheduler: IScheduler; const canGoNextPred: TPredicate<T>);
begin
  fOnNext := doOnNext;
  fOnError := doOnError;
  fOnComplete := doOnComplete;
  fScheduler := scheduler;
  fCanGoNext := canGoNextPred;
end;

destructor TSubscriber<T>.Destroy;
begin
  inherited Destroy;
end;

function TSubscriber<T>.IsUnsubscribed: Boolean;
begin
  Result := fUnsubscribed;
end;

procedure TSubscriber<T>.OnComplete;
var
  local_OnComplete: TProc;
begin
  local_OnComplete := fOnComplete;
  if Assigned(local_OnComplete) then
    fScheduler.Execute(procedure
    begin
      local_OnComplete();
    end);
end;

procedure TSubscriber<T>.OnError(const exception: Exception);
begin
  if not Assigned(fOnError) then
    raise EOnErrorHandlerNotAssigned.CreateFmt('On Error Handler Is Not Assigned. Exception raised: %s',
      [exception.ToString]);

  fScheduler.Execute(procedure
    begin
      fOnError(exception);
    end);
end;

procedure TSubscriber<T>.OnNext(const item: T);
var
  local_OnNext: TAction<T>;
begin
  if not IsUnsubscribed then
  begin
    local_OnNext := fOnNext;
    fScheduler.Execute(procedure
      begin
        if fCanGoNext(item) then
          local_OnNext(item);
      end);
  end;
end;

procedure TSubscriber<T>.Unsubscribe;
begin
  fUnsubscribed := True;
end;

{ TMainThreadScheduler }

procedure TMainThreadScheduler.Execute(const proc: TThreadProcedure);
begin
  if TThread.CurrentThread.ThreadID = MainThreadId then
    proc()
  else
    TThread.Queue(nil, proc);
end;

{ TNewThreadScheduler }

procedure TNewThreadScheduler.Execute(const proc: TThreadProcedure);
begin
  TThread.CreateAnonymousThread(TProc(proc)).Start;
end;

{ Schedulers }

class function Schedulers.MainThread: IScheduler;
begin
  Result := TMainThreadScheduler.Create;
end;

class function Schedulers.NewThread: IScheduler;
begin
  Result := TNewThreadScheduler.Create;
end;

{ TFilteredObservable<T> }

function TFilteredObservable<T>.CanGoNext(item: T): Boolean;
begin
  Result := fPredicate(item);
end;

constructor TFilteredObservable<T>.Create(
  const subscriberAction: TAction<ISubscriber<T>>;
  const predicate: TPredicate<T>);
begin
  inherited Create(subscriberAction);
  fPredicate := predicate;
end;

end.
