ECHO "Test bat file"

%ROOT% = %0\..
%VERSION% = "windows64_569e52e"
%HAXE_STD_PATH% = "%ROOT%\build\%VERSION%\std"

CALL %ROOT%\build\%VERSION\haxe.exe --cwd %ROOT% run-select.hxml %*
