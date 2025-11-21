@echo off
REM Build script for Microsoft Visual C++ compiler
REM This script builds jarrunner.exe using MSVC

echo Setting up MSVC environment...
REM We are assuming that there is batch file called devcmd.bat which if run, will initialize this cmd's environment variables to support building using MSVC Build tools. 
REM MS VC build tools are installable portably, this is far easier from downloading the full massive bundle, which takes space, wastes time, requires admin access (which not everyone always has).
REM I used this - https://github.com/Data-Oriented-House/PortableBuildTools (the repo is now archived ... but it works for me)
call devcmd.bat >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Warning: devcmd.bat not found in PATH, assuming MSVC env is already set
    echo.
)

echo Building jarrunner.exe with MSVC...
echo.

REM NOTE: Using /SUBSYSTEM:CONSOLE instead of WINDOWS so parent shell waits for us
REM We'll handle GUI mode by FreeConsole() in the code
cl /nologo /O2 /Fe:jarrunner.exe launcher.c /link /SUBSYSTEM:CONSOLE user32.lib kernel32.lib

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo BUILD SUCCESSFUL!
    echo ========================================
    echo Output: jarrunner.exe
    echo.
    dir jarrunner.exe
    echo.

    REM Clean up intermediate files
    if exist launcher.obj del launcher.obj

) else (
    echo.
    echo ========================================
    echo BUILD FAILED!
    echo ========================================
    echo Please ensure Visual Studio/MSVC is installed.
    echo Run from "Developer Command Prompt for VS" or ensure devcmd.bat is in PATH.
    echo.
    exit /b 1
)
