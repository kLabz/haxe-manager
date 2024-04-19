@ECHO OFF

SET ROOT=%~dp0

MKDIR "releases"
MKDIR "versions"
MKDIR "bin"

ECHO F | XCOPY /S /Q /Y /F "extra/haxe.bat" "bin/haxe.bat"
ECHO F | XCOPY /S /Q /Y /F "extra/haxelib.bat" "bin/haxelib.bat"
ECHO F | XCOPY /S /Q /Y /F "extra/hx-download.bat" "bin/hx-download.bat"
ECHO F | XCOPY /S /Q /Y /F "extra/hx-select.bat" "bin/hx-select.bat"

MKLINK /D "versions/5.0.0-alpha.1+569e52e" "%ROOT%/build/windows64_569e52e"
MKLINK /D "current" "%ROOT%/build/windows64_569e52e"

ECHO "Please add %ROOT%/bin to your PATH"
ECHO "Please set HAXE_STD_PATH to %ROOT%/current/std"
