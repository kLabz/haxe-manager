@ECHO OFF

SET ROOT=%~dp0
SET ROOT=%ROOT%..
SET VERSION=windows64_569e52e

CALL %ROOT%\build\%VERSION%\haxelib.exe %*
