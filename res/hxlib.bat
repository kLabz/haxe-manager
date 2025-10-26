@ECHO OFF

SET ROOT=%~dp0
SET CALL_SITE=%CD%
CD "%ROOT%..\res\windows64_569e52e"

haxelib.exe --cwd %CALL_SITE% %*
