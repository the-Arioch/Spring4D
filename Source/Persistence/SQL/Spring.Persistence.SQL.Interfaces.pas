﻿{***************************************************************************}
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

unit Spring.Persistence.SQL.Interfaces;

interface

uses
  Classes,
  Spring.Collections,
  Spring.Persistence.Mapping.Attributes,
  Spring.Persistence.SQL.Commands,
  Spring.Persistence.SQL.Types;

type
  ICommandExecutionListener = interface
    ['{590E86C8-0B05-4BFE-9B26-3A9A4D0510BF}']
    procedure ExecutingCommand(const command: string; const list: IList);
  end;

  TQueryLanguage = (qlAnsiSQL = 0, qlSQLite, qlMSSQL, qlASA, qlOracle, qlFirebird, qlPostgreSQL, qlMySQL, qlNoSQL, qlMongoDB);

  ISQLGenerator = interface
    ['{8F46D275-50E4-4DE8-9E56-7D6599935E32}']
    function GetQueryLanguage: TQueryLanguage;
    function GenerateSelect(const command: TSelectCommand): string;
    function GenerateInsert(const command: TInsertCommand): string;
    function GenerateUpdate(const command: TUpdateCommand): string;
    function GenerateDelete(const command: TDeleteCommand): string;
    function GenerateCreateTable(const command: TCreateTableCommand): IList<string>;
    function GenerateCreateFK(const command: TCreateFKCommand): IList<string>;
    function GenerateCreateSequence(const command: TCreateSequenceCommand): string;
    function GenerateGetNextSequenceValue(const sequence: SequenceAttribute): string;
    function GenerateGetLastInsertId(const identityColumn: ColumnAttribute): string;
    function GeneratePagedQuery(const sql: string; limit, offset: Integer): string;
    function GenerateGetQueryCount(const sql: string): string;
    function GenerateUniqueId: Variant;
    function GetSQLTableCount(const tablename: string): string;
    function GetSQLSequenceCount(const sequenceName: string): string;
    function GetTableColumns(const tableName: string): string;
    function GetSQLTableExists(const tableName: string): string;
    function GetEscapeFieldnameChar: Char;
    function GetUpdateVersionFieldQuery(const command: TUpdateCommand;
      const versionColumn: VersionAttribute; const version, primaryKey: Variant): Variant;
  end;

implementation

uses
  // auto register all generators
  Spring.Persistence.SQL.Generators.Register;

end.