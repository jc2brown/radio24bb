cd /d %~dp0
rem cmd.exe /K "set PATH=bin;%PATH% && %XILINX_SDK_ROOT%/settings64.bat"
cmd.exe /K "set PATH=%MSYS2_BIN%;%SystemRoot%\system32 && %XILINX_SDK_ROOT%/settings64.bat"