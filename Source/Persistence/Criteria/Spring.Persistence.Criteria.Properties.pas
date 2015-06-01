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

{$I Spring.inc}

unit Spring.Persistence.Criteria.Properties;

interface

uses
  Spring,
  Spring.Persistence.Criteria.Interfaces,
  Spring.Persistence.Criteria.Restrictions,
  Spring.Persistence.SQL.Types;

type
  TSetNumbers = set of Byte;

  /// <summary>
  ///   A factory for property-specific criterion and projection instances.
  /// </summary>
  TProperty = class(TInterfacedObject, IProperty)
  private
    fPropertyName: string;
    fEntityClass: TClass;
  protected
    function Eq(const value: TValue): ICriterion;
    function NotEq(const value: TValue): ICriterion;
    function GEq(const value: TValue): ICriterion;
    function Gt(const value: TValue): ICriterion;
    function IsNull: ICriterion;
    function IsNotNull: ICriterion;
    function Like(const value: string; matchMode: TMatchMode = mmExact): ICriterion;
    function NotLike(const value: string; matchMode: TMatchMode = mmExact): ICriterion;
    function LEq(const value: TValue): ICriterion;
    function Lt(const value: TValue): ICriterion;
    function &In<T>(const value: TArray<T>): ICriterion;
    function NotIn<T>(const value: TArray<T>): ICriterion;
    function InStr(const value: TArray<string>): ICriterion;
    function NotInStr(const value: TArray<string>): ICriterion;
    function InInt(const value: TArray<Integer>): ICriterion;
    function NotInInt(const value: TArray<Integer>): ICriterion;
    function Between(const low, high: TValue): ICriterion;
    function Asc: IOrderBy;
    function Desc: IOrderBy;

    function EqProperty(const other: IProperty): ICriterion; overload;
    function EqProperty(const otherPropertyName: string): ICriterion; overload;
    function NeProperty(const other: IProperty): ICriterion; overload;
    function NeProperty(const otherPropertyName: string): ICriterion; overload;
    function GeProperty(const other: IProperty): ICriterion; overload;
    function GeProperty(const otherPropertyName: string): ICriterion; overload;
    function GtProperty(const other: IProperty): ICriterion; overload;
    function GtProperty(const otherPropertyName: string): ICriterion; overload;
    function LeProperty(const other: IProperty): ICriterion; overload;
    function LeProperty(const otherPropertyName: string): ICriterion; overload;
    function LtProperty(const other: IProperty): ICriterion; overload;
    function LtProperty(const otherPropertyName: string): ICriterion; overload;

    function GetEntityClass: TClass;
    function GetPropertyName: string;
    procedure SetEntityClass(value: TClass);
    procedure SetPropertyName(const value: string);
  public
    constructor Create(const propertyName: string; entityClass: TClass = nil);

    property EntityClass: TClass read GetEntityClass;
    property PropertyName: string read GetPropertyName write SetPropertyName;
  end;

  /// <summary>
  ///   A factory for property-specific criterion and projection instances.
  /// </summary>
  TProperty<T: class> = class(TProperty)
  public
    constructor Create(const propertyName: string);
  end;

  TExpr = record
  private
    fCriterion: ICriterion;
  public
    class operator Implicit(const criterion: ICriterion): TExpr; overload;
    class operator Implicit(const expr: TExpr): ICriterion; overload;

    class operator LogicalAnd(const left, right: TExpr): ICriterion;
    class operator LogicalOr(const left, right: TExpr): ICriterion;
    class operator LogicalNot(const expr: TExpr): ICriterion;
  end;

  /// <summary>
  ///   Represents record to hold entity's property name for using in
  ///   ICriteria&lt;T&gt; searches.
  /// </summary>
  Prop = record
  private
    fProp: IProperty;
  public
    constructor Create(const propertyName: string; const entityClass: TClass = nil);

    class operator Equal(const left, right: Prop): TExpr; overload;
    class operator Equal(const left: Prop; const right: Variant): TExpr; overload;
    class operator Equal(const left: Variant; const right: Prop): TExpr; overload;

    class operator NotEqual(const left, right: Prop): TExpr; overload;
    class operator NotEqual(const left: Prop; const right: Variant): TExpr; overload;
    class operator NotEqual(const left: Variant; const right: Prop): TExpr; overload;

    class operator GreaterThan(const left, right: Prop): TExpr; overload;
    class operator GreaterThan(const left: Prop; const right: Variant): TExpr; overload;
    class operator GreaterThan(const left: Variant; const right: Prop): TExpr; overload;

    class operator GreaterThanOrEqual(const left, right: Prop): TExpr; overload;
    class operator GreaterThanOrEqual(const left: Prop; const right: Variant): TExpr; overload;
    class operator GreaterThanOrEqual(const left: Variant; const right: Prop): TExpr; overload;

    class operator LessThan(const left, right: Prop): TExpr; overload;
    class operator LessThan(const left: Prop; const right: Variant): TExpr; overload;
    class operator LessThan(const left: Variant; const right: Prop): TExpr; overload;

    class operator LessThanOrEqual(const left, right: Prop): TExpr; overload;
    class operator LessThanOrEqual(const left: Prop; const right: Variant): TExpr; overload;
    class operator LessThanOrEqual(const left: Variant; const right: Prop): TExpr; overload;

    class operator In(const left: Prop; const right: TArray<string>): TExpr; overload;
    class operator In(const left: Prop; const right: array of string): TExpr; overload;
    class operator In(const left: Prop; const right: array of Integer): TExpr; overload;
    class operator In(const left: Prop; const right: TArray<Integer>): TExpr; overload;
    class operator In(const left: Prop; const right: TSetNumbers): TExpr; overload;

    function IsNull: ICriterion;
    function IsNotNull: ICriterion;
    function Like(const value: string; matchMode: TMatchMode = mmExact): ICriterion;
    function NotLike(const value: string; matchMode: TMatchMode = mmExact): ICriterion;
    function Between(const low, high: TValue): ICriterion;

    function Asc: IOrderBy;
    function Desc: IOrderBy;
  end;

implementation

uses
  Spring.Collections,
  Spring.Persistence.Core.Exceptions,
  Spring.Persistence.Criteria.Criterion.PropertyExpression,
  Spring.Persistence.Criteria.OrderBy;


{$REGION 'TProperty'}

constructor TProperty.Create(const propertyName: string; entityClass: TClass);
begin
  fPropertyName := propertyName;
  fEntityClass := entityClass;
end;

function TProperty.Asc: IOrderBy;
begin
  Result := TOrderBy.Asc(fPropertyName);
  Result.SetEntityClass(GetEntityClass);
end;

function TProperty.Between(const low, high: TValue): ICriterion;
begin
  Result := Restrictions.Between(PropertyName, low, high);
  Result.SetEntityClass(GetEntityClass);
end;

function TProperty.Desc: IOrderBy;
begin
  Result := TOrderBy.Desc(fPropertyName);
  Result.SetEntityClass(GetEntityClass);
end;

function TProperty.Eq(const value: TValue): ICriterion;
begin
  Result := Restrictions.Eq(fPropertyName, value);
  Result.SetEntityClass(GetEntityClass);
end;

function TProperty.EqProperty(const otherPropertyName: string): ICriterion;
begin
  Result := TPropertyExpression.Create(PropertyName, otherPropertyName, woEqual
    , TSQLTable.CreateFromClass(fEntityClass), nil);
  Result.SetEntityClass(GetEntityClass);
end;

function TProperty.EqProperty(const other: IProperty): ICriterion;
begin
  Result := TPropertyExpression.Create(
    PropertyName, other.PropertyName, woEqual,
    TSQLTable.CreateFromClass(fEntityClass),
    TSQLTable.CreateFromClass(other.EntityClass));
  Result.SetEntityClass(EntityClass);
end;

function TProperty.GeProperty(const otherPropertyName: string): ICriterion;
begin
  Result := TPropertyExpression.Create(
    PropertyName, otherPropertyName, woMoreOrEqual,
    TSQLTable.CreateFromClass(fEntityClass), nil);
  Result.SetEntityClass(GetEntityClass);
end;

function TProperty.GeProperty(const other: IProperty): ICriterion;
begin
  Result := TPropertyExpression.Create(
    PropertyName, other.GetPropertyName, woMoreOrEqual,
    TSQLTable.CreateFromClass(fEntityClass),
    TSQLTable.CreateFromClass(other.GetEntityClass));
  Result.SetEntityClass(GetEntityClass);
end;

function TProperty.GEq(const value: TValue): ICriterion;
begin
  Result := Restrictions.GEq(fPropertyName, value);
  Result.SetEntityClass(GetEntityClass);
end;

function TProperty.GetEntityClass: TClass;
begin
  Result := fEntityClass;
end;

function TProperty.GetPropertyName: string;
begin
  Result := fPropertyName;
end;

function TProperty.Gt(const value: TValue): ICriterion;
begin
  Result := Restrictions.Gt(fPropertyName, value);
  Result.SetEntityClass(GetEntityClass);
end;

function TProperty.GtProperty(const other: IProperty): ICriterion;
begin
  Result := TPropertyExpression.Create(
    PropertyName, other.GetPropertyName, woMore,
    TSQLTable.CreateFromClass(fEntityClass),
    TSQLTable.CreateFromClass(other.GetEntityClass));
  Result.SetEntityClass(GetEntityClass);
end;

function TProperty.GtProperty(const otherPropertyName: string): ICriterion;
begin
  Result := TPropertyExpression.Create(
    PropertyName, otherPropertyName, woMore,
    TSQLTable.CreateFromClass(fEntityClass), nil);
  Result.SetEntityClass(GetEntityClass);
end;

function TProperty.&In<T>(const value: TArray<T>): ICriterion;
begin
  Result := Restrictions.&In<T>(fPropertyName, value);
  Result.SetEntityClass(GetEntityClass);
end;

function TProperty.InInt(const value: TArray<Integer>): ICriterion;
begin
  Result := &In<Integer>(value);
  Result.SetEntityClass(GetEntityClass);
end;

function TProperty.InStr(const value: TArray<string>): ICriterion;
begin
  Result := &In<string>(value);
  Result.SetEntityClass(GetEntityClass);
end;

function TProperty.IsNotNull: ICriterion;
begin
  Result := Restrictions.IsNotNull(fPropertyName);
  Result.SetEntityClass(GetEntityClass);
end;

function TProperty.IsNull: ICriterion;
begin
  Result := Restrictions.IsNull(fPropertyName);
  Result.SetEntityClass(GetEntityClass);
end;

function TProperty.LeProperty(const other: IProperty): ICriterion;
begin
  Result := TPropertyExpression.Create(
    PropertyName, other.GetPropertyName, woLessOrEqual,
    TSQLTable.CreateFromClass(fEntityClass),
    TSQLTable.CreateFromClass(other.GetEntityClass));
  Result.SetEntityClass(GetEntityClass);
end;

function TProperty.LeProperty(const otherPropertyName: string): ICriterion;
begin
  Result := TPropertyExpression.Create(
    PropertyName, otherPropertyName, woLessOrEqual,
    TSQLTable.CreateFromClass(fEntityClass), nil);
  Result.SetEntityClass(GetEntityClass);
end;

function TProperty.LEq(const value: TValue): ICriterion;
begin
  Result := Restrictions.LEq(fPropertyName, value);
  Result.SetEntityClass(GetEntityClass);
end;

function TProperty.Like(const value: string; matchMode: TMatchMode): ICriterion;
begin
  Result := Restrictions.Like(fPropertyName, value, matchMode);
  Result.SetEntityClass(GetEntityClass);
end;

function TProperty.Lt(const value: TValue): ICriterion;
begin
  Result := Restrictions.Lt(fPropertyName, value);
  Result.SetEntityClass(GetEntityClass);
end;

function TProperty.LtProperty(const otherPropertyName: string): ICriterion;
begin
  Result := TPropertyExpression.Create(
    PropertyName, otherPropertyName, woLess,
    TSQLTable.CreateFromClass(fEntityClass), nil);
  Result.SetEntityClass(GetEntityClass);
end;

function TProperty.LtProperty(const other: IProperty): ICriterion;
begin
  Result := TPropertyExpression.Create(
    PropertyName, other.GetPropertyName, woLess,
    TSQLTable.CreateFromClass(fEntityClass),
    TSQLTable.CreateFromClass(other.GetEntityClass));
  Result.SetEntityClass(GetEntityClass);
end;

function TProperty.NeProperty(const other: IProperty): ICriterion;
begin
  Result := TPropertyExpression.Create(
    PropertyName, other.GetPropertyName, woNotEqual,
    TSQLTable.CreateFromClass(fEntityClass),
    TSQLTable.CreateFromClass(other.GetEntityClass));
  Result.SetEntityClass(GetEntityClass);
end;

function TProperty.NeProperty(const otherPropertyName: string): ICriterion;
begin
  Result := TPropertyExpression.Create(
    PropertyName, otherPropertyName, woNotEqual,
    TSQLTable.CreateFromClass(fEntityClass), nil);
  Result.SetEntityClass(GetEntityClass);
end;

function TProperty.NotEq(const value: TValue): ICriterion;
begin
  Result := Restrictions.NotEq(fPropertyName, value);
  Result.SetEntityClass(GetEntityClass);
end;

function TProperty.NotIn<T>(const value: TArray<T>): ICriterion;
begin
  Result := Restrictions.NotIn<T>(fPropertyName, value);
  Result.SetEntityClass(GetEntityClass);
end;

function TProperty.NotInInt(const value: TArray<Integer>): ICriterion;
begin
  Result := NotIn<Integer>(value);
  Result.SetEntityClass(GetEntityClass);
end;

function TProperty.NotInStr(const value: TArray<string>): ICriterion;
begin
  Result := NotIn<string>(value);
  Result.SetEntityClass(GetEntityClass);
end;

function TProperty.NotLike(const value: string; matchMode: TMatchMode): ICriterion;
begin
  Result := Restrictions.NotLike(fPropertyName, value, matchMode);
  Result.SetEntityClass(GetEntityClass);
end;

procedure TProperty.SetEntityClass(value: TClass);
begin
  fEntityClass := value;
end;

procedure TProperty.SetPropertyName(const Value: string);
begin
  fPropertyName := Value;
end;

{$ENDREGION}


{$REGION 'TProperty<T>'}

constructor TProperty<T>.Create(const propertyName: string);
begin
  inherited Create(propertyName, T);
end;

{$ENDREGION}


{$REGION 'Prop'}

constructor Prop.Create(const propertyName: string; const entityClass: TClass);
begin
  fProp := TProperty.Create(propertyName, entityClass);
end;

class operator Prop.Equal(const left, right: Prop): TExpr;
begin
  Result.fCriterion := left.fProp.EqProperty(right.fProp);
end;

class operator Prop.Equal(const left: Prop; const right: Variant): TExpr;
begin
  Result.fCriterion := left.fProp.Eq(TValue.FromVariant(right));
end;

class operator Prop.In(const left: Prop; const right: TArray<string>): TExpr;
begin
  Result.fCriterion := left.fProp.InStr(right);
end;

class operator Prop.In(const left: Prop; const right: array of string): TExpr;
var
  rightArray: TArray<string>;
  I: Integer;
begin
  SetLength(rightArray, Length(right));
  for I := Low(right) to High(right) do
    rightArray[I] := right[I];

  Result.fCriterion := left.fProp.InStr(rightArray);
end;

class operator Prop.In(const left: Prop; const right: array of Integer): TExpr;
var
  rightArray: TArray<Integer>;
  I: Integer;
begin
  SetLength(rightArray, Length(right));
  for I := Low(right) to High(right) do
    rightArray[I] := right[I];
  Result.fCriterion := left.fProp.InInt(rightArray);
end;

class operator Prop.In(const left: Prop; const right: TArray<Integer>): TExpr;
begin
  Result.fCriterion := left.fProp.InInt(right);
end;

class operator Prop.In(const left: Prop; const right: TSetNumbers): TExpr;
var
  rightArray: TArray<Integer>;
  lright: TSetNumbers;
begin
  lright := right;
  rightArray := TEnumerable.Range(0, 256)
    .Where(function(const value: Integer): Boolean
    begin
      Result := value in lright;
    end).ToArray;
  Result.fCriterion := left.fProp.InInt(rightArray);
end;

function Prop.IsNull: ICriterion;
begin
  Result := fProp.IsNull;
end;

function Prop.IsNotNull: ICriterion;
begin
  Result := fProp.IsNotNull;
end;

function Prop.Like(const value: string; matchMode: TMatchMode): ICriterion;
begin
  Result := fProp.Like(value, matchMode);
end;

function Prop.NotLike(const value: string; matchMode: TMatchMode): ICriterion;
begin
  Result := fProp.NotLike(value, matchMode);
end;

function Prop.Between(const low, high: TValue): ICriterion;
begin
  Result := fProp.Between(low, high);
end;

function Prop.Asc: IOrderBy;
begin
  Result := fProp.Asc;
end;

function Prop.Desc: IOrderBy;
begin
  Result := fProp.Desc;
end;

class operator Prop.Equal(const left: Variant; const right: Prop): TExpr;
begin
  Result.fCriterion := right.fProp.Eq(TValue.FromVariant(left));
end;

class operator Prop.GreaterThan(const left, right: Prop): TExpr;
begin
  Result.fCriterion := left.fProp.GtProperty(right.fProp);
end;

class operator Prop.GreaterThan(const left: Prop;
  const right: Variant): TExpr;
begin
  Result.fCriterion := left.fProp.Gt(TValue.FromVariant(right));
end;

class operator Prop.GreaterThan(const left: Variant;
  const right: Prop): TExpr;
begin
  Result.fCriterion := right.fProp.Lt(TValue.FromVariant(left));
end;

class operator Prop.GreaterThanOrEqual(const left, right: Prop): TExpr;
begin
  Result.fCriterion := left.fProp.GeProperty(right.fProp);
end;

class operator Prop.GreaterThanOrEqual(const left: Prop;
  const right: Variant): TExpr;
begin
  Result.fCriterion := left.fProp.GEq(TValue.FromVariant(right));
end;

class operator Prop.GreaterThanOrEqual(const left: Variant;
  const right: Prop): TExpr;
begin
  Result.fCriterion := right.fProp.LEq(TValue.FromVariant(left));
end;

class operator Prop.LessThan(const left, right: Prop): TExpr;
begin
  Result.fCriterion := left.fProp.LtProperty(right.fProp);
end;

class operator Prop.LessThan(const left: Prop;
  const right: Variant): TExpr;
begin
  Result.fCriterion := left.fProp.Lt(TValue.FromVariant(right));
end;

class operator Prop.LessThan(const left: Variant;
  const right: Prop): TExpr;
begin
  Result.fCriterion := right.fProp.Gt(TValue.FromVariant(left));
end;

class operator Prop.LessThanOrEqual(const left, right: Prop): TExpr;
begin
  Result.fCriterion := left.fProp.LeProperty(right.fProp);
end;

class operator Prop.LessThanOrEqual(const left: Prop;
  const right: Variant): TExpr;
begin
  Result.fCriterion := left.fProp.LEq(TValue.FromVariant(right));
end;

class operator Prop.LessThanOrEqual(const left: Variant;
  const right: Prop): TExpr;
begin
  Result.fCriterion := right.fProp.GEq(TValue.FromVariant(left));
end;

class operator Prop.NotEqual(const left: Variant;
  const right: Prop): TExpr;
begin
  Result.fCriterion := right.fProp.NotEq(TValue.FromVariant(left));
end;

class operator Prop.NotEqual(const left: Prop;
  const right: Variant): TExpr;
begin
  Result.fCriterion := left.fProp.NotEq(TValue.FromVariant(right));
end;

class operator Prop.NotEqual(const left, right: Prop): TExpr;
begin
  Result.fCriterion := left.fProp.NeProperty(right.fProp);
end;

{$ENDREGION}


{$REGION 'TExpr'}

class operator TExpr.Implicit(const expr: TExpr): ICriterion;
begin
  Result := expr.fCriterion;
end;

class operator TExpr.LogicalAnd(const left, right: TExpr): ICriterion;
begin
  Result := Restrictions.&And(left.fCriterion, right.fCriterion);
end;

class operator TExpr.LogicalOr(const left, right: TExpr): ICriterion;
begin
  Result := Restrictions.&Or(left.fCriterion, right.fCriterion);
end;

class operator TExpr.LogicalNot(const expr: TExpr): ICriterion;
begin
  Result := Restrictions.&Not(expr.fCriterion);
end;

class operator TExpr.Implicit(const criterion: ICriterion): TExpr;
begin
  Result.fCriterion := criterion;
end;

{$ENDREGION}


end.
