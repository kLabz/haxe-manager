@ECHO OFF

SET ROOT=%~dp0
SET CALL_SITE=%CD%
CD "%ROOT%../current"
haxelib.exe --cwd %CALL_SITE% %*
