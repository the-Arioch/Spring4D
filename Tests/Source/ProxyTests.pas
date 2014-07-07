unit ProxyTests;

interface

uses
  TestFramework;

type
  TProxyTest = class(TTestCase)
  published
    procedure Should_be_able_to_wrap_interface_with_one_method;
    procedure Should_be_able_to_write_interface_with_two_methods;

    procedure ClassProxy_should_implement_additional_interfaces;
//    procedure ClassProxy_for_class_already_implementing_additional_interfaces;
  end;

  TEnsurePartnerStatusRule = class(TInterfacedObject)
  end;

  ISupportsInvalidation = interface(IInvokable)
    ['{45A48AD9-4F7E-4A8D-8FA2-EA46BEAC3A9A}']
    procedure Invalidate;
  end;

implementation

uses
  Rtti,
  SysUtils,
  Spring.Collections,
  Spring.Interception,
  DelegateWrapper,
  Interfaces,
  Generics.Defaults;

{ TProxyTest }

procedure TProxyTest.Should_be_able_to_wrap_interface_with_one_method;
var
  len: TFunc<string, Integer>;
  wrapped: IAnsweringEngine;
  i: Integer;
begin
  len :=
    function(s: string): Integer
    begin
      Result := Length(s);
    end;
  wrapped := TDelegateWrapper.WrapAs<IAnsweringEngine>(@len);
  CheckNotNull(wrapped);
  i := wrapped.GetAnswer('Answer to Life the Universe and Everything');
  CheckEquals(42, i);
end;

type
  {$M+}
  TEqualsFunc<T> = reference to function(const Left, Right: T): Boolean;
  TGetHashCodeFunc<T> = reference to function(const Value: T): Integer;
  {$M-}

procedure TProxyTest.Should_be_able_to_write_interface_with_two_methods;
var
  compare: TEqualsFunc<string>;
  getHashCode: TGetHashCodeFunc<string>;
  comparer: IEqualityComparer<string>;
  stringByLength: IDictionary<string, string>;
  atFive: string;
begin
  compare :=
    function(const s1, s2: string): Boolean
    begin
      Result := Length(s1) = Length(s2);
    end;
  getHashCode :=
    function(const s: string): Integer
    begin
      Result := Length(s);
    end;

  Interfaces.IEqualityComparer<string>(comparer) :=
    TDelegateWrapper.WrapAs<Interfaces.IEqualityComparer<string>>([@compare, @getHashCode]);
//  comparer := TDelegateWrapper.WrapAs<IEqualityComparer<string>>([@compare, @getHashCode]);
  stringByLength := TCollections.CreateDictionary<string, string>(comparer);
  stringByLength.Add('four', 'some string');
  stringByLength.Add('five!', 'some other string');
  CheckEquals(2, stringByLength.Count);
  atFive := stringByLength['12345'];
  CheckEquals('some other string', atFive);
end;

type
  TInvalidationInterceptor = class(TInterfacedObject, IInterceptor)
    procedure Intercept(const invocation: IInvocation);
  end;

procedure TInvalidationInterceptor.Intercept(const invocation: IInvocation);
begin
end;

procedure TProxyTest.ClassProxy_should_implement_additional_interfaces;
var
  generator: TProxyGenerator;
  proxy: TObject;
  supportsInvalidation: ISupportsInvalidation;
begin
  generator := TProxyGenerator.Create;
  try
    proxy := generator.CreateClassProxy(
      TEnsurePartnerStatusRule,
      [TypeInfo(ISupportsInvalidation)],
      [TInvalidationInterceptor.Create]);
    CheckTrue(Supports(proxy, ISupportsInvalidation, supportsInvalidation));
    supportsInvalidation.Invalidate;
  finally
    proxy.Free;
    generator.Free;
  end;
end;

initialization
  RegisterTest(TProxyTest.Suite);

end.
