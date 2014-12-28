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

{$i Spring.inc}

unit MainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, StdCtrls, ExtCtrls, CheckLst, BuildEngine;

type
  TfrmMain = class(TForm)
    btnBuild: TButton;
    mmoDetails: TMemo;
    lblDetails: TLabel;
    grpTargets: TGroupBox;
    TargetsListBox: TCheckListBox;
    lblHomepage: TLinkLabel;
    BalloonHint1: TBalloonHint;
    btnClean: TButton;
    chkRunTests: TCheckBox;
    grpBuildOptions: TGroupBox;
    chkModifyDelphiRegistrySettings: TCheckBox;
    chkPauseAfterEachStep: TCheckBox;
    TargetsPopupMenu: TPopupMenu;
    mniCheckAll: TMenuItem;
    mniUncheckAll: TMenuItem;
    grpBuildConfigurations: TGroupBox;
    chkDebug: TCheckBox;
    chkRelease: TCheckBox;
    chkRunTestsAsConsole: TCheckBox;
    chkDryRun: TCheckBox;
    InvertSelectionMenuItem: TMenuItem;
    N2: TMenuItem;
    CheckOnlyMobilePlatforms: TMenuItem;
    CheckOnlyNonMobilePlatforms: TMenuItem;
    CheckOnlyOSXMenuItem: TMenuItem;
    CheckOnlyWindowsMenuItem: TMenuItem;
    Label1: TLabel;
    msbuildVerbosityComboBox: TComboBox;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnBuildClick(Sender: TObject);
    procedure btnCleanClick(Sender: TObject);
    procedure TargetsListBoxClickCheck(Sender: TObject);
    procedure lblHomepageLinkClick(Sender: TObject; const Link: string;
      LinkType: TSysLinkType);
    procedure chkRunTestsClick(Sender: TObject);
    procedure chkModifyDelphiRegistrySettingsClick(Sender: TObject);
    procedure chkPauseAfterEachStepClick(Sender: TObject);
    procedure mniCheckAllClick(Sender: TObject);
    procedure mniUncheckAllClick(Sender: TObject);
    procedure chkDebugClick(Sender: TObject);
    procedure chkDryRunClick(Sender: TObject);
    procedure chkReleaseClick(Sender: TObject);
    procedure chkRunTestsAsConsoleClick(Sender: TObject);
    procedure InvertSelectionMenuItemClick(Sender: TObject);
    procedure CheckOnlyMobilePlatformsClick(Sender: TObject);
    procedure CheckOnlyNonMobilePlatformsClick(Sender: TObject);
    procedure CheckOnlyOSXMenuItemClick(Sender: TObject);
    procedure CheckOnlyWindowsMenuItemClick(Sender: TObject);
    procedure msbuildVerbosityComboBoxChange(Sender: TObject);
  protected
    procedure SyncBuildTasksFromTargetsListBox; virtual;
    procedure CheckOnlyTargetsListBoxBy(const CompilerFunction: TFunc<TCompilerTarget, Boolean>); virtual;
  private
    fBuildEngine: TBuildEngine;
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

uses
  ShellAPI,
  Spring.Utils;

const
  CCompilerSettingsFileName = 'Build.Settings.Compilers.ini';
  CBuildSettingsFileName = 'Build.Settings.ini';

procedure ScrollToLastLine(Memo: TMemo);
begin
  SendMessage(Memo.Handle, EM_LINESCROLL, 0,Memo.Lines.Count);
end;

procedure TfrmMain.FormCreate(Sender: TObject);
var
  task: TBuildTask;
  index: Integer;
begin
  fBuildEngine := TBuildEngine.Create;
  fBuildEngine.ConfigureCompilers(ApplicationPath + CCompilerSettingsFileName);
  fBuildEngine.LoadSettings(ApplicationPath + CBuildSettingsFileName);
  chkDebug.Checked := TBuildConfig.Debug in fBuildEngine.BuildConfigs;
  chkRelease.Checked := TBuildConfig.Release in fBuildEngine.BuildConfigs;
  chkPauseAfterEachStep.Checked := fBuildEngine.PauseAfterEachStep;
  chkDryRun.Checked := fBuildEngine.DryRun;
  chkRunTests.Checked := fBuildEngine.RunTests;
  chkRunTestsAsConsole.Checked := fBuildEngine.RunTestsAsConsole;
  chkModifyDelphiRegistrySettings.Checked := fBuildEngine.ModifyDelphiRegistrySettings;
  msbuildVerbosityComboBox.ItemIndex := msbuildVerbosityComboBox.Items.IndexOf(fBuildEngine.MsbuildVerbosity);

  TargetsListBox.Clear;
  for task in fBuildEngine.Tasks do
  begin
    if fBuildEngine.OnlyShowInstalledVersions and not task.CanBuild then
      Continue;
    index := TargetsListBox.Items.AddObject(task.Name, task);
    TargetsListBox.ItemEnabled[index] := task.CanBuild;
    TargetsListBox.Checked[index] := fBuildEngine.SelectedTasks.Contains(task);
  end;

  if FileExists('Build.md') then
    mmoDetails.Lines.LoadFromFile('Build.md');
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  fBuildEngine.SaveSettings(ApplicationPath + CBuildSettingsFileName);
  fBuildEngine.Free;
end;

procedure TfrmMain.lblHomepageLinkClick(Sender: TObject; const Link: string;
  LinkType: TSysLinkType);
begin
  ShellExecute(Handle, 'open', PChar(Link), nil, nil, SW_NORMAL);
end;

procedure TfrmMain.TargetsListBoxClickCheck(Sender: TObject);
begin
  SyncBuildTasksFromTargetsListBox();
end;

procedure TfrmMain.mniUncheckAllClick(Sender: TObject);
begin
  TargetsListBox.CheckAll(cbUnchecked);
  SyncBuildTasksFromTargetsListBox();
end;

procedure TfrmMain.btnBuildClick(Sender: TObject);
begin
  fBuildEngine.BuildAll;
  mmoDetails.Lines.AddStrings(fBuildEngine.CommandLog);
  ScrollToLastLine(mmoDetails);
end;

procedure TfrmMain.btnCleanClick(Sender: TObject);
begin
  fBuildEngine.CleanUp;
end;

procedure TfrmMain.CheckOnlyMobilePlatformsClick(Sender: TObject);
begin
  CheckOnlyTargetsListBoxBy(function (compiler: TCompilerTarget): Boolean
  begin
    Result := compiler.IsMobilePlatform;
  end
  );
end;

procedure TfrmMain.CheckOnlyNonMobilePlatformsClick(Sender: TObject);
begin
  CheckOnlyTargetsListBoxBy(function (compiler: TCompilerTarget): Boolean
  begin
    Result := not compiler.IsMobilePlatform;
  end
  );
end;

procedure TfrmMain.CheckOnlyOSXMenuItemClick(Sender: TObject);
begin
  CheckOnlyTargetsListBoxBy(function (compiler: TCompilerTarget): Boolean
  begin
    Result := compiler.IsOsxPlatform;
  end
  );
end;

procedure TfrmMain.CheckOnlyTargetsListBoxBy(
  const CompilerFunction: TFunc<TCompilerTarget, Boolean>);
var
  index: Integer;
  task: TBuildTask;
begin
  for index := 0 to TargetsListBox.Count - 1 do
  begin
    task := TBuildTask(TargetsListBox.Items.Objects[index]);
    TargetsListBox.Checked[index] := CompilerFunction(task.Compiler);
  end;
  SyncBuildTasksFromTargetsListBox();
end;

procedure TfrmMain.CheckOnlyWindowsMenuItemClick(Sender: TObject);
begin
  CheckOnlyTargetsListBoxBy(function (compiler: TCompilerTarget): Boolean
  begin
    Result := compiler.IsWindowsPlatform;
  end
  );
end;

procedure TfrmMain.mniCheckAllClick(Sender: TObject);
begin
  TargetsListBox.CheckAll(cbChecked, False, False);
  SyncBuildTasksFromTargetsListBox();
end;

procedure TfrmMain.chkReleaseClick(Sender: TObject);
begin
  if chkRelease.Checked then
    fBuildEngine.BuildConfigs := fBuildEngine.BuildConfigs + [TBuildConfig.Release]
  else
    fBuildEngine.BuildConfigs := fBuildEngine.BuildConfigs - [TBuildConfig.Release];
end;

procedure TfrmMain.chkRunTestsAsConsoleClick(Sender: TObject);
begin
  fBuildEngine.RunTestsAsConsole := chkRunTestsAsConsole.Checked;
end;

procedure TfrmMain.chkRunTestsClick(Sender: TObject);
begin
  fBuildEngine.RunTests := chkRunTests.Checked;
end;

procedure TfrmMain.chkDebugClick(Sender: TObject);
begin
  if chkDebug.Checked then
    fBuildEngine.BuildConfigs := fBuildEngine.BuildConfigs + [TBuildConfig.Debug]
  else
    fBuildEngine.BuildConfigs := fBuildEngine.BuildConfigs - [TBuildConfig.Debug];
end;

procedure TfrmMain.chkDryRunClick(Sender: TObject);
begin
  fBuildEngine.DryRun := chkDryRun.Checked;
end;

procedure TfrmMain.chkModifyDelphiRegistrySettingsClick(Sender: TObject);
begin
  fBuildEngine.ModifyDelphiRegistrySettings := chkModifyDelphiRegistrySettings.Checked;
end;

procedure TfrmMain.chkPauseAfterEachStepClick(Sender: TObject);
begin
  fBuildEngine.PauseAfterEachStep := chkPauseAfterEachStep.Checked;
end;

procedure TfrmMain.InvertSelectionMenuItemClick(Sender: TObject);
begin
  CheckOnlyTargetsListBoxBy(function (compiler: TCompilerTarget): Boolean
  begin
    Result := not compiler.IsMobilePlatform;
  end
  );
end;

procedure TfrmMain.msbuildVerbosityComboBoxChange(Sender: TObject);
begin
  fBuildEngine.MsbuildVerbosity := msbuildVerbosityComboBox.Text;
end;

procedure TfrmMain.SyncBuildTasksFromTargetsListBox;
var
  task: TBuildTask;
  i: Integer;
begin
  fBuildEngine.SelectedTasks.Clear();
  for i := 0 to TargetsListBox.Count - 1 do
  begin
    if TargetsListBox.Checked[i] then
    begin
      task := TBuildTask(TargetsListBox.Items.Objects[i]);
      fBuildEngine.SelectedTasks.Add(task);
    end;
  end;
  btnBuild.Enabled := not fBuildEngine.SelectedTasks.IsEmpty;
end;

end.
