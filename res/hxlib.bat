@ECHO OFF

SET ROOT=%~dp0
SET ROOT=%ROOT%..
SET VERSION=windows64_569e52e

CALL %ROOT%\res\%VERSION%\haxelib.exe %*
