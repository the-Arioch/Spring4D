{***************************************************************************}
{                                                                           }
{           Spring Framework for Delphi                                     }
{                                                                           }
{           Copyright (c) 2009-2014 Spring4D Team                           }
{                                                                           }
{           http://www.spring4d.org                                         }
{                                                                           }
{***************************************************************************}
{                                                                           }
{  Licensed under the Apache License, Version 2.0 (the "License");          }
{  you may not use this file except in compliance with the License.         }
{  You may obtain a copy of the License at                                  }
{                                                                           }
{      http://www.apache.org/licenses/LICENSE-2.0                           }
{                                                                           }
{  Unless required by applicable law or agreed to in writing, software      }
{  distributed under the License is distributed on an "AS IS" BASIS,        }
{  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. }
{  See the License for the specific language governing permissions and      }
{  limitations under the License.                                           }
{                                                                           }
{***************************************************************************}

unit Spring.Tests.Interception.Types;

{$I Spring.inc}
{$I Spring.Tests.inc}

interface

uses
  Rtti,
  SysUtils,
  Spring,
  Spring.Collections,
  Spring.Interception,
  Spring.Services.Logging;

type
  IHasCount = interface
    ['{E76AAB8E-B78E-4AA6-96D4-01F92FBE6268}']
    function GetCount: Integer;
    property Count: Integer read GetCount;
  end;

  {$RTTI EXPLICIT METHODS([vcProtected..vcPublished])}
  TPet = class
  private
    fName: string;
    fAge: Integer;
    fDeceased: Boolean;
  protected
    function GetAge: Integer; virtual;
    function GetDeceased: Boolean; virtual;
    function GetName: string; virtual;
    procedure SetAge(const Value: Integer); virtual;
    procedure SetDeceased(const Value: Boolean); virtual;
    procedure SetName(const Value: string); virtual;
  public
    function ToString: string; override;

    procedure Test(var i: Integer); virtual;

    property Name: string read GetName write SetName;
    property Age: Integer read GetAge write SetAge;
    property Deceased: Boolean read GetDeceased write SetDeceased;
  end;

  TPetWithNonVirtualMethod = class(TPet)
  public
    procedure NonVirtualMethod;
  end;

  TPetWithNonVirtualSetter = class(TPet)
  protected
    function GetNonVirtualProperty: Integer;
    procedure SetNonVirtualProperty(const Value: Integer);
  public
    property NonVirtualProperty: Integer read GetNonVirtualProperty
      write SetNonVirtualProperty;
  end;

  IFreezable = interface
    ['{EC4A628B-5137-4144-8589-F74FDAD6143F}']
    function GetIsFrozen: Boolean;
    procedure Freeze;
    property IsFrozen: Boolean read GetIsFrozen;
  end;

  TFreezable = record
  private
    class var
      fGenerator: TProxyGenerator;
    class function AsFreezable(const target: TObject): IFreezable; static;
  public
    class constructor Create;
    class destructor Destroy;

    class function IsFreezable(const obj: TObject): Boolean; static;
    class procedure Freeze(const freezable: TObject); static;
    class function IsFrozen(const obj: TObject): Boolean; static;

    class function MakeFreezable<T: class, constructor>: T; static;
  end;

  TFreezableInterceptor = class(TInterfacedObject, IInterceptor, IFreezable, IHasCount)
  private
    fCount: Integer;
    fIsFrozen: Boolean;
    function GetCount: Integer;
    function GetIsFrozen: Boolean;
  public
    procedure Freeze;
    procedure Intercept(const invocation: IInvocation);
  end;

  TFreezableInterceptorSelector = class(TInterfacedObject, IInterceptorSelector)
  public
    function SelectInterceptors(const method: TRttiMethod;
      const interceptors: IEnumerable<IInterceptor>): IEnumerable<IInterceptor>;
  end;

  TFreezableProxyGenerationHook = class(TInterfacedObject, IProxyGenerationHook)
  public
    procedure NonVirtualMemberNotification(const method: TRttiMethod);
    function ShouldInterceptMethod(const method: TRttiMethod): Boolean;
  end;

  ENotFreezableObjectException = class(Exception);
  EObjectFrozenException = class(Exception);

  TCallLoggingInterceptor = class(TInterfacedObject, IInterceptor, IHasCount)
  private
    fLogger: ILogger;
    fCount: Integer;
    function GetCount: Integer;
  public
    constructor Create; overload;
    constructor Create(const logger: ILogger); overload;
    procedure Intercept(const invocation: IInvocation);
    property Count: Integer read GetCount;
  end;

  TPerson = class(TObject);

  ISupportsInvalidation = interface(IInvokable)
    ['{45A48AD9-4F7E-4A8D-8FA2-EA46BEAC3A9A}']
    procedure Invalidate;
  end;

  TEnsurePartnerStatusRule = class
  end;

  IClientRule = interface(IInvokable)
    ['{ED28AB18-DE4C-4B11-90EA-768A4DCC38C5}']
  end;

  TApplyDiscountRule = class(TInterfacedObject, ISupportsInvalidation, IClientRule)
  public
    procedure Invalidate;
  end;

  IAnsweringEngine = interface(IInvokable)
    ['{D3B8E1FF-9B51-43FA-BF70-3AAC9B742E26}']
    function GetAnswer(s: string): Integer;
  end;

  IDeepThought = interface
    ['{FD310D32-A8FB-429E-A753-E7C0824AF777}']
    procedure SetAnsweringEngine(const answeringEngine: IAnsweringEngine);
  end;

  {$M+}
  IEqualityComparer<T> = interface//(Generics.Defaults.IEqualityComparer<T>)
    // DO NOT ADD ANY METHODS HERE!!!
    function Equals(const Left, Right: T): Boolean;
    function GetHashCode(const Value: T): Integer;
  end;
  {$M-}

  IStorage = interface(IInvokable)
    ['{674F4FE4-EBD1-4D16-AFDE-B43D51104A34}']
    procedure Save(const data: string);
  end;

  TDelegateWrapper = record
    class function WrapAs<T: IInterface>(delegate: PInterface): T; overload; static;
    class function WrapAs<T: IInterface>(delegates: array of PInterface): T; overload; static;
  end;

  TMethodInterceptor = class(TInterfacedObject, IInterceptor)
  private
    fDelegate: IInterface;
  public
    constructor Create(const delegate: IInterface);
    procedure Intercept(const invocation: IInvocation);
    property Delegate: IInterface read fDelegate;
  end;

  TDelegateSelector = class(TInterfacedObject, IInterceptorSelector)
  public
    function SelectInterceptors(const method: TRttiMethod;
      const interceptors: IEnumerable<IInterceptor>): IEnumerable<IInterceptor>;
  end;

  TSecondaryStorage = class(TInterfacedObject, IStorage)
  private
    fItems: IList<string>;
  public
    constructor Create;
    procedure Save(const items: string);
    property Items: IList<string> read fItems;
  end;

  TPrimaryStorage = class(TSecondaryStorage)
  private
    fIsUp: Boolean;
  public
    property IsUp: Boolean read fIsUp write fIsUp;
  end;

  TStorageFactory = class
  private
    fPrimaryStorage: IStorage;
    fSecondaryStorage: IStorage;
    fGenerator: TProxyGenerator;
  public
    constructor Create(const primaryStorage: IStorage);
    destructor Destroy; override;
    function GetStorage: IStorage;
    property SecondaryStorage: IStorage read fSecondaryStorage write fSecondaryStorage;
  end;

  TStorageInterceptor = class(TInterfacedObject, IInterceptor)
  private
    fSecondaryStorage: IStorage;
    procedure ChangeToSecondaryStorage(const invocation: IInvocation);
  public
    constructor Create(const secondaryStorage: IStorage);
    procedure Intercept(const invocation: IInvocation);
  end;

implementation

uses
  StrUtils,
  Spring.Helpers,
  Spring.Reflection;


{$REGION 'TPet'}

function TPet.GetAge: Integer;
begin
  Result := fAge;
end;

function TPet.GetDeceased: Boolean;
begin
  Result := fDeceased;
end;

function TPet.GetName: string;
begin
  Result := fName;
end;

procedure TPet.SetAge(const Value: Integer);
begin
  fAge := Value;
end;

procedure TPet.SetDeceased(const Value: Boolean);
begin
  fDeceased := Value;
end;

procedure TPet.SetName(const Value: string);
begin
  fName := Value;
end;

procedure TPet.Test(var i: Integer);
begin
  Inc(i);
end;

function TPet.ToString: string;
begin
  Result := Format('Name: %1:d, Age: %1:d, Deceased: %2:s', [Name, Age, BoolToStr(Deceased)]);
end;

{$ENDREGION}


{$REGION 'TPetWithNonVirtualMethod'}

procedure TPetWithNonVirtualMethod.NonVirtualMethod;
begin
end;

{$ENDREGION}


{$REGION 'TPetWithNonVirtualSetter'}

function TPetWithNonVirtualSetter.GetNonVirtualProperty: Integer;
begin
  Result := 0;
end;

procedure TPetWithNonVirtualSetter.SetNonVirtualProperty(
  const Value: Integer);
begin
end;

{$ENDREGION}


{$REGION 'TFreezable'}

class constructor TFreezable.Create;
begin
  fGenerator := TProxyGenerator.Create;
end;

class destructor TFreezable.Destroy;
begin
  fGenerator.Free;
end;

class function TFreezable.AsFreezable(const target: TObject): IFreezable;
var
  hack: IProxyTargetAccessor;
begin
  if target = nil then
    Exit(nil);
  if not target.GetInterface(IProxyTargetAccessor, hack) then
    Exit(nil);
  Result := hack.GetInterceptors.FirstOrDefault(
    function(const i: IInterceptor): Boolean
    begin
      Result := Supports(i, IFreezable);
    end) as IFreezable;
end;

class function TFreezable.IsFreezable(const obj: TObject): Boolean;
begin
  Result := AsFreezable(obj) <> nil;
end;

class procedure TFreezable.Freeze(const freezable: TObject);
var
  interceptor: IFreezable;
begin
  interceptor := AsFreezable(freezable);
  if interceptor = nil then
    raise ENotFreezableObjectException.Create(freezable.ToString);
  interceptor.Freeze;
end;

class function TFreezable.IsFrozen(const obj: TObject): Boolean;
var
  freezable: IFreezable;
begin
  freezable := AsFreezable(obj);
  Result := Assigned(freezable) and freezable.IsFrozen;
end;

class function TFreezable.MakeFreezable<T>: T;
var
  freezableInterceptor: TFreezableInterceptor;
  options: TProxyGenerationOptions;
  proxy: TObject;
begin
  freezableInterceptor := TFreezableInterceptor.Create;
  options := TProxyGenerationOptions.Create(TFreezableProxyGenerationHook.Create);
  options.Selector := TFreezableInterceptorSelector.Create;
  proxy := fGenerator.CreateClassProxy(TClass(T), options, [
    TCallLoggingInterceptor.Create, freezableInterceptor]);
  Result := T(proxy)
end;

{$ENDREGION}


{$REGION 'TFreezableInterceptor'}

procedure TFreezableInterceptor.Freeze;
begin
  fIsFrozen := True;
end;

function TFreezableInterceptor.GetCount: Integer;
begin
  Result := fCount;
end;

function TFreezableInterceptor.GetIsFrozen: Boolean;
begin
  Result := fIsFrozen;
end;

procedure TFreezableInterceptor.Intercept(const invocation: IInvocation);
begin
  Inc(fCount);
  if fIsFrozen and StartsText('Set', invocation.Method.Name) then
    raise EObjectFrozenException.Create('');
  invocation.Proceed;
end;

{$ENDREGION}


{$REGION 'TFreezableInterceptorSelector'}

function TFreezableInterceptorSelector.SelectInterceptors(
  const method: TRttiMethod;
  const interceptors: IEnumerable<IInterceptor>): IEnumerable<IInterceptor>;
begin
  if StartsText('Set', method.Name) then
    Exit(interceptors);
  Result := interceptors.Where(
    function(const i: IInterceptor): Boolean
    begin
      Result := not (i is TFreezableInterceptor);
    end);
end;

{$ENDREGION}


{$REGION 'TFreezableProxyGenerationHook'}

procedure TFreezableProxyGenerationHook.NonVirtualMemberNotification(
  const method: TRttiMethod);
begin
  if StartsText('Set', method.Name) then
    raise EInvalidOperationException.CreateFmt('Property %s is not virtual. ' +
      'Cannot freeze classes with non-virtual properties.', [Copy(method.Name, 4)]);
end;

function TFreezableProxyGenerationHook.ShouldInterceptMethod(
  const method: TRttiMethod): Boolean;
begin
  Result := StartsText('Set', method.Name) or StartsText('Get', method.Name);
end;

{$ENDREGION}


{$REGION 'TCallLoggingInterceptor'}

constructor TCallLoggingInterceptor.Create;
begin
//  fLogger := DefaultLogger;
end;

constructor TCallLoggingInterceptor.Create(const logger: ILogger);
begin
  fLogger := logger;
end;

function TCallLoggingInterceptor.GetCount: Integer;
begin
  Result := fCount;
end;

procedure TCallLoggingInterceptor.Intercept(const invocation: IInvocation);
begin
//  fLogger.EnterMethod(invocation.Target, invocation.Method.Name);
  try
    try
      Inc(fCount);
      invocation.Proceed;
    except
      on E: Exception do
      begin
//        fLogger.LogException(E);
        raise;
      end;
    end;
  finally
//    fLogger.LeaveMethod(invocation.Target, invocation.Method.Name);
  end;
end;

{$ENDREGION}


{$REGION 'TApplyDiscountRule'}

procedure TApplyDiscountRule.Invalidate;
begin
end;

{$ENDREGION}


{$REGION 'TDelegateWrapper'}

class function TDelegateWrapper.WrapAs<T>(delegate: PInterface): T;
var
  generator: TProxyGenerator;
begin
  generator := TProxyGenerator.Create;
  try
    Result := generator.CreateInterfaceProxyWithoutTarget<T>(
      TMethodInterceptor.Create(delegate^));
  finally
    generator.Free;
  end;
end;

class function TDelegateWrapper.WrapAs<T>(delegates: array of PInterface): T;
var
  generator: TProxyGenerator;
  options: TProxyGenerationOptions;
  interceptors: TArray<IInterceptor>;
  i: Integer;
begin
  generator := TProxyGenerator.Create;
  try
    options.Selector := TDelegateSelector.Create;
    SetLength(interceptors, Length(delegates));
    for i := Low(delegates) to High(delegates) do
      interceptors[i] := TMethodInterceptor.Create(delegates[i]^);
    Result := generator.CreateInterfaceProxyWithoutTarget<T>(
      options, interceptors);
  finally
    generator.Free;
  end;
end;

{$ENDREGION}


{$REGION 'TMethodInterceptor'}

constructor TMethodInterceptor.Create(const delegate: IInterface);
begin
  fDelegate := delegate;
end;

procedure TMethodInterceptor.Intercept(const invocation: IInvocation);
type
  PPVtable = ^PVtable;
  PVtable = ^TVtable;
  TVtable = array[0..3] of Pointer;
var
  arguments: TArray<TValue>;
  method: TRttiMethod;
  params: TArray<TRttiParameter>;
  args: TArray<TValue>;
  i: Integer;
  codeAddress: Pointer;
begin
  arguments := invocation.Arguments;
  method := invocation.Method;
  params := method.GetParameters;
  SetLength(args, Length(arguments) + 1);
  args[0] := TValue.From(fDelegate);

  // convert arguments for Invoke call (like done in the DispatchInvoke methods
  for i := Low(arguments) to High(arguments) do
    PassArg(params[i], arguments[i], args[i + 1], method.CallingConvention);

  codeAddress := PPVtable(fDelegate)^^[3];

  invocation.Result := Rtti.Invoke(codeAddress, args, method.CallingConvention, method.ReturnTypeHandle);
end;

{$ENDREGION}


{$REGION 'TDelegateSelector'}

function TDelegateSelector.SelectInterceptors(const method: TRttiMethod;
  const interceptors: IEnumerable<IInterceptor>): IEnumerable<IInterceptor>;
begin
  Result := interceptors.Where(
    function(const interceptor: IInterceptor): Boolean
    var
      methodInterceptor: TMethodInterceptor;
    begin
      methodInterceptor := interceptor as TMethodInterceptor;
      Result := Assigned(methodInterceptor);
    end).Skip(method.VirtualIndex - 3).Take(1);
end;

{$ENDREGION}


{$REGION 'TSecondaryStorage'}

constructor TSecondaryStorage.Create;
begin
  fItems := TCollections.CreateList<string>;
end;

procedure TSecondaryStorage.Save(const items: string);
begin
  fItems.Add(items);
end;

{$ENDREGION}


{$REGION 'TStorageFactory'}

constructor TStorageFactory.Create(const primaryStorage: IStorage);
begin
  fPrimaryStorage := primaryStorage;
  fGenerator := TProxyGenerator.Create;
end;

destructor TStorageFactory.Destroy;
begin
  fGenerator.Free;
  inherited;
end;

function TStorageFactory.GetStorage: IStorage;
var
  interceptor: IInterceptor;
begin
  interceptor := TStorageInterceptor.Create(fSecondaryStorage);
  Result := fGenerator.CreateInterfaceProxyWithTarget<IStorage>(
    fPrimaryStorage, interceptor);
end;

{$ENDREGION}


{$REGION 'TStorageInterceptor'}

procedure TStorageInterceptor.ChangeToSecondaryStorage(
  const invocation: IInvocation);
var
  changeProxyTarget: IChangeProxyTarget;
begin
  changeProxyTarget := invocation as IChangeProxyTarget;
  changeProxyTarget.ChangeInvocationTarget(TValue.From(fSecondaryStorage));
end;

constructor TStorageInterceptor.Create(const secondaryStorage: IStorage);
begin
  fSecondaryStorage := secondaryStorage;
end;

procedure TStorageInterceptor.Intercept(const invocation: IInvocation);
var
  primaryStorage: TPrimaryStorage;
begin
  primaryStorage := invocation.Target.AsInterface as TPrimaryStorage;
  if not primaryStorage.IsUp then
    ChangeToSecondaryStorage(invocation);
  invocation.Proceed;
end;

{$ENDREGION}


end.
