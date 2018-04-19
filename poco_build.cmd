@echo off
@setlocal

set MYDIR=%~dp0
pushd "%MYDIR%"

IF NOT EXIST "poco" (
    echo poco folder not found, did you forget to clone?
    exit /B -1
)

rem Only build basic components
for /f "usebackq tokens=1* delims=: " %%i in (`vswhere -latest -requires Microsoft.Component.MSBuild`) do (
  if /i "%%i"=="installationPath" set LatestVS=%%j
)

set POCO_COMMON=build all both x64 samples tests

pushd "%MYDIR%poco"
IF NOT "%LatestVS%"=="" (
	set "VS150COMNTOOLS=%LatestVS%\Common7\Tools\"
	call "%LatestVS%\VC\Auxiliary\Build\vcvarsall.bat" x64 8.1
    pushd "%MYDIR%poco"
    call buildwin 150 %POCO_COMMON% devenv
) ELSE (
	IF NOT "%VS140COMNTOOLS%"=="" (
		ECHO Visual Studio 2015
		call "%VS140COMNTOOLS%\..\..\VC\vcvarsall.bat" x64 8.1
		REM call buildwin 140 %POCO_COMMON% msbuild
	) ELSE (
		ECHO Visual Studio 2012
		call "%VS110COMNTOOLS%\..\..\VC\vcvarsall.bat" x64 8.1
		call buildwin 110 %POCO_COMMON% msbuild
	)
)

rem Build NuGet package
cd ..
IF NOT "%LatestVS%"=="" (
	call nuget pack POCO-Basic-v141.nuspec -NoPackageAnalysis -NonInteractive
) ELSE (
	IF NOT "%VS140COMNTOOLS%"=="" (
		call nuget pack POCO-Basic-v140.nuspec -NoPackageAnalysis -NonInteractive
	) ELSE (
		call nuget pack POCO-Basic-v110.nuspec -NoPackageAnalysis -NonInteractive
	)
)	
popd
endlocal
pause