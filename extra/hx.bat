@ECHO OFF

SET ROOT=%~dp0
SET ROOT=%ROOT%..
SET VERSION=windows64_569e52e
SET HAXE_STD_PATH=%ROOT%\build\%VERSION%\std
SET CALL_SITE=%CD%

CALL %ROOT%\build\%VERSION%\haxe.exe --cwd %ROOT% run-hx.hxml %*
