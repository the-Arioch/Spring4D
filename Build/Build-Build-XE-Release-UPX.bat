pushd %~dp0
call Run-Dependend-rsvars-From-Path.bat 8 msbuildRelease Build.dproj
upx.exe ..\Build.exe
popd
