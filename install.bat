@ECHO OFF

SET ROOT=%~dp0
SET HAXE_VER=569e52e

MKDIR "releases"
MKDIR "versions"
MKDIR "bin"

REM Install base tools
ECHO F | XCOPY /S /Q /Y /F "extra/haxe.bat" "bin/haxe.bat"
ECHO F | XCOPY /S /Q /Y /F "extra/haxelib.bat" "bin/haxelib.bat"
ECHO F | XCOPY /S /Q /Y /F "extra/hx.bat" "bin/hx.bat"

REM Setup included Haxe version
MKLINK /D "versions/5.0.0-alpha.1+%HAXE_VER%" "%ROOT%/build/windows64_%HAXE_VER%"
MKLINK /D "current" "%ROOT%/build/windows64_%HAXE_VER%"

REM Prebuild cli
%ROOT%/build/windows64_%HAXE_VER%/haxe.exe --cwd %ROOT% build-hx.hxml

ECHO "Please add %ROOT%/bin to your PATH"
ECHO "Please set HAXE_STD_PATH to %ROOT%/current/std"
