unit TestObservable;

interface

uses
  TestFramework,
  Spring.Persistence.Core.Observable
  ;

type
  TTestObservable = class(TTestCase)
  protected
    function GetFooBarObservable: IObservable<string>;
    function GetFooBarObservableEmit5Times: IObservable<string>;
  published
    procedure WhenOneSubscriber_EmitItemToIt;
    procedure WhenTwoSubscribers_EmitTwoItems;
    procedure WhenTwoSubscribers_EmitTwoItemsInThread;   
    procedure FilterItems; 
  end;

implementation

uses
  Classes,
  SysUtils,
  StrUtils,
  Forms;

{ TTestObservable }

function isFoobar(item: string): Boolean;
begin
  Result := item = 'FooBar';
end;

procedure TTestObservable.FilterItems;
var
  subscription: ISubscription;
  actual: string;
begin
  subscription := GetFooBarObservableEmit5Times
    .Filter(isFoobar)
    .Subscribe(procedure(const item: string)
      begin
        Status(item); 
        actual := item;
      end);   

  CheckEquals('FooBar', actual);
end;

function TTestObservable.GetFooBarObservable: IObservable<string>;
begin
  Result := TObservable<string>.Create(procedure(const subscriber: ISubscriber<string>)
    begin
      try
        subscriber.OnNext('FooBar');
        subscriber.OnComplete;    
      except 
        on E: Exception do
          subscriber.OnError(E);
      end;         
    end);
end;

function TTestObservable.GetFooBarObservableEmit5Times: IObservable<string>;
begin
  Result := TObservable<string>.Create(procedure(const subscriber: ISubscriber<string>)
    begin
      try
        subscriber.OnNext('FooBar');
        subscriber.OnNext('FooBar2');
        subscriber.OnNext('FooBar3');
        subscriber.OnNext('FooBar4');
        subscriber.OnNext('FooBar5');             
        subscriber.OnComplete;                
      except 
        on E: Exception do
          subscriber.OnError(E);
      end;         
    end);
end;

procedure TTestObservable.WhenOneSubscriber_EmitItemToIt;
var
  observable: IObservable<string>;
  actual: string;
begin
  observable := GetFooBarObservable;
  observable.Subscribe(procedure(const item: string)
    begin
      Status(item); 
      actual := item;
    end);

  CheckEquals('FooBar', actual);
end;

procedure TTestObservable.WhenTwoSubscribers_EmitTwoItems;
var
  observable: IObservable<string>;
  actual, actual2: string;
  subscription, subscription2: ISubscription;
begin
  observable := GetFooBarObservable;
  subscription := observable.Subscribe(procedure(const item: string)
    begin
      Status(item + ' 1st subscriber'); 
      actual := item;
    end, nil, nil);
  subscription2 := observable.Subscribe(procedure(const item: string)
    begin
      Status(item + ' 2nd subscriber'); 
      actual2 := item;
    end);

  CheckEquals('FooBar', actual, 'First subscriber should receive FooBar');    
  CheckEquals('FooBar', actual2, 'Second subscriber should receive FooBar');  
end;

procedure TTestObservable.WhenTwoSubscribers_EmitTwoItemsInThread;
var
  observable: IObservable<string>;
  actual, actual2: string;
  subscription, subscription2: ISubscription;
begin
  observable := GetFooBarObservableEmit5Times
    .SubscribeOn(Schedulers.NewThread)
    .ObserveOn(Schedulers.MainThread);    
  subscription := observable.Subscribe(procedure(const item: string)
    begin
      Status(item + ' 1st subscriber');
      actual := item;
    end);
  subscription2 := observable.Subscribe(procedure(const item: string)
    begin
      Status(item + ' 2nd subscriber');    
      actual2 := item;
    end);

  TThread.Sleep(100);  
  Application.ProcessMessages;

  CheckEquals('FooBar5', actual, 'First subscriber should receive FooBar5');    
  CheckEquals('FooBar5', actual2, 'Second subscriber should receive FooBar5'); 
end;

initialization
  RegisterTest(TTestObservable.Suite);

end.
