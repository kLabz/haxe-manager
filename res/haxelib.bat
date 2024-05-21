@ECHO OFF

SET ROOT=%~dp0
CD "%ROOT%../current"
haxelib.exe %*
