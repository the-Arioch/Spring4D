@echo off
  echo 1 rsvars.bat:  %1
  echo 2 .dproj file: %2
  echo 3 config:      %3
  echo 4 platform:    %4
  echo 5 dcu path:    %5
  echo 6 define:      %6
  echo 6 verbosity:   %7
  echo 8 pause:       "%8"
  :: clear some variables to allow build.exe to be run from Delphi XE (BDS 8.0) without forcing all Spring4D build to be initiated by XE (BDS 8.0)
  :: set AQtime7_Product_Path=
  :: set BDS=
  :: set BDSAppDataBaseDir=
  :: set BDSBIN=
  :: set BDSINCLUDE=
  set BDSLIB=
  :: set BDSPROJECTSDIR=
  :: set BDSUSERDIR=
  :: set DELPHI=
  :: set Platform=
  :: set ProductVersion=
  call :do call %1
setlocal
  set DprojDirectory=%~dp2
  set DprojDirectory=%DprojDirectory:~0,-1%
  for %%f in (%DprojDirectory%) do set DprojDelphi=%%~nf
  if not exist Logs\ mkdir Logs
  for /f "tokens=2,4" %%c in ('echo %~4 %~3') do set buildlog="Logs\%DprojDelphi%.%%c.%%d.MSBuildLog.txt"
  echo   build log:   %buildlog%
  :: msbuild command-line reference: http://msdn.microsoft.com/en-us/library/ms164311.aspx
  :: verbosidy: q[uiet], m[inimal], n[ormal], d[etailed], and diag[nostic]
  call :do %FrameworkDir%\msbuild.exe /nologo %2 /verbosity:%7 /target:build /p:DCC_BuildAllUnits=true /p:%3 /p:%4 /p:%5 /p:%6 /l:FileLogger,Microsoft.Build.Engine;logfile=%buildlog%

endlocal
  if "%7"=="" goto :eof
  pause
  goto :eof
:do
  echo %*
  :: you can also echo %* and pipe it to %~dpn0.log
  %*
  goto :eof
