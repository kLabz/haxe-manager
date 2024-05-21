@ECHO OFF

SET ROOT=%~dp0
REM TODO: from res/.current
SET HAXE_VER=5e4e368

MKDIR "releases"
MKDIR "versions"
MKDIR "bin"

REM Install base tools
ECHO F | XCOPY /S /Q /Y /F "res/haxe.bat" "bin/haxe.bat"
ECHO F | XCOPY /S /Q /Y /F "res/haxelib.bat" "bin/haxelib.bat"
ECHO F | XCOPY /S /Q /Y /F "res/hx.bat" "bin/hx.bat"
ECHO F | XCOPY /S /Q /Y /F "res/hxlib.bat" "bin/hxlib.bat"

REM Setup included Haxe version
MKLINK /D "versions/5.0.0-alpha.1+%HAXE_VER%" "%ROOT%/res/windows64_%HAXE_VER%"
MKLINK /D "current" "%ROOT%/res/windows64_%HAXE_VER%"

REM Prebuild cli
%ROOT%/res/windows64_%HAXE_VER%/haxe.exe --cwd %ROOT% build.hxml --hxb res/hx.hxb

ECHO "Please add %ROOT%/bin to your PATH"
ECHO "Please set HAXE_STD_PATH to %ROOT%/current/std"
