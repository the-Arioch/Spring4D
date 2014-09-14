(*
* Copyright (c) 2012, Linas Naginionis
* Contacts: lnaginionis@gmail.com or support@soundvibe.net
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without
* modification, are permitted provided that the following conditions are met:
*     * Redistributions of source code must retain the above copyright
*       notice, this list of conditions and the following disclaimer.
*     * Redistributions in binary form must reproduce the above copyright
*       notice, this list of conditions and the following disclaimer in the
*       documentation and/or other materials provided with the distribution.
*     * Neither the name of the <organization> nor the
*       names of its contributors may be used to endorse or promote products
*       derived from this software without specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY THE AUTHOR ''AS IS'' AND ANY
* EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
* DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
* DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
* (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
* LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
* ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
* (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
* SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*)
unit Spring.Persistence.SQL.Generator.NoSQL;

interface

uses
  Spring.Persistence.SQL.AbstractSQLGenerator, Spring.Persistence.SQL.Commands
  , Spring.Persistence.SQL.Types, Spring.Persistence.Mapping.Attributes
  , Spring.Persistence.SQL.Interfaces, Spring.Collections;

type
  {$REGION 'Documentation'}
  ///	<summary>
  ///	  Represents base <b>NoSQL</b> database statements generator.
  ///	</summary>
  {$ENDREGION}
  TNoSQLGenerator = class(TAbstractSQLGenerator)
  public
    function GetQueryLanguage(): TQueryLanguage; override;

    function GenerateCreateTable(ACreateTableCommand: TCreateTableCommand): IList<string>; override;
    function GenerateCreateFK(ACreateFKCommand: TCreateFKCommand): IList<string>; override;
    function GenerateCreateSequence(ASequence: TCreateSequenceCommand): string; override;
    function GenerateGetNextSequenceValue(ASequence: SequenceAttribute): string; override;
    function GenerateGetLastInsertId(AIdentityColumn: ColumnAttribute): string; override;

    function GetSQLSequenceCount(const ASequenceName: string): string; override;
    function GetTableColumns(const ATableName: string): string; override;
    function GetSQLDataTypeName(AField: TSQLCreateField): string; override;
    function GetSQLTableExists(const ATablename: string): string; override;
    function GetEscapeFieldnameChar(): Char; override;
  end;

implementation


{ TNoSQLGenerator }

function TNoSQLGenerator.GenerateCreateFK(ACreateFKCommand: TCreateFKCommand): IList<string>;
begin
  Result := TCollections.CreateList<string>;
end;

function TNoSQLGenerator.GenerateCreateSequence(ASequence: TCreateSequenceCommand): string;
begin
  Result := '';
end;

function TNoSQLGenerator.GenerateCreateTable(ACreateTableCommand: TCreateTableCommand): IList<string>;
begin
  Result := TCollections.CreateList<string>;
end;

function TNoSQLGenerator.GenerateGetLastInsertId(AIdentityColumn: ColumnAttribute): string;
begin
  Result := ' ';
end;

function TNoSQLGenerator.GenerateGetNextSequenceValue(ASequence: SequenceAttribute): string;
begin
  Result := '';
end;

function TNoSQLGenerator.GetEscapeFieldnameChar: Char;
begin
  Result := '"';
end;

function TNoSQLGenerator.GetQueryLanguage: TQueryLanguage;
begin
  Result := qlNoSQL;
end;

function TNoSQLGenerator.GetSQLDataTypeName(AField: TSQLCreateField): string;
begin
  Result := '';
end;

function TNoSQLGenerator.GetSQLSequenceCount(const ASequenceName: string): string;
begin
  Result := '';
end;

function TNoSQLGenerator.GetSQLTableExists(const ATablename: string): string;
begin
  Result := '';
end;

function TNoSQLGenerator.GetTableColumns(const ATableName: string): string;
begin
  Result := '';
end;


end.