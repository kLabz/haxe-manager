@ECHO OFF

SET ROOT=%~dp0
SET ROOT=%ROOT%..

REM TODO: from res/.current
SET VERSION=windows64_5e4e368

SET HAXE_STD_PATH=%ROOT%\res\%VERSION%\std
SET CALL_SITE=%CD%

CALL %ROOT%\res\%VERSION%\haxe.exe --cwd %ROOT% run-hx.hxml %*
