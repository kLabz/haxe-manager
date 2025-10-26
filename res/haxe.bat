@ECHO OFF

SET ROOT=%~dp0
SET CALL_SITE=%CD%
CD "%ROOT%../current"
haxe.exe --cwd %CALL_SITE% %*
