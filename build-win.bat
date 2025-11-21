@echo off
REM Build script for Microsoft Visual C++ compiler
REM This script builds jr.exe (Java Runner) using MSVC

echo Setting up MSVC environment...
REM We are assuming that there is batch file called devcmd.bat which if run, will initialize this cmd's environment variables to support building using MSVC Build tools.
REM MS VC build tools are installable portably, this is far easier from downloading the full massive bundle, which takes space, wastes time, requires admin access (which not everyone always has).
REM I used this - https://github.com/Data-Oriented-House/PortableBuildTools (the repo is now archived ... but it works for me)
call devcmd.bat >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Warning: devcmd.bat not found in PATH, assuming MSVC env is already set
    echo.
)

echo Building jr.exe (dynamic CRT) with MSVC...
echo.

REM Build 1: Dynamic CRT version (small, requires VCREDIST)
REM Optimize for size: /O1 (size) /GS- (no security checks) /Gy (function-level linking) /MD (dynamic CRT)
REM Link flags: /OPT:REF (remove unused) /OPT:ICF (merge identical) /MERGE:.rdata=.text
cl /nologo /O1 /GS- /Gy /MD /Fe:jr.exe launcher.c /link /SUBSYSTEM:CONSOLE /OPT:REF /OPT:ICF /MERGE:.rdata=.text user32.lib kernel32.lib

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ========================================
    echo BUILD FAILED: jr.exe
    echo ========================================
    echo Please ensure Visual Studio/MSVC is installed.
    echo Run from "Developer Command Prompt for VS" or ensure devcmd.bat is in PATH.
    echo.
    exit /b 1
)

echo.
echo ========================================
echo BUILD 1 SUCCESSFUL: jr.exe (dynamic)
echo ========================================
dir jr.exe
echo.

REM Clean up intermediate files
if exist launcher.obj del launcher.obj

echo Building jr-standalone.exe (static CRT) with MSVC...
echo.

REM Build 2: Static CRT version (standalone, no dependencies)
REM /MT = static CRT (no VCREDIST needed)
cl /nologo /O1 /GS- /Gy /MT /Fe:jr-standalone.exe launcher.c /link /SUBSYSTEM:CONSOLE /OPT:REF /OPT:ICF /MERGE:.rdata=.text user32.lib kernel32.lib

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ========================================
    echo BUILD FAILED: jr-standalone.exe
    echo ========================================
    exit /b 1
)

echo.
echo ========================================
echo BUILD 2 SUCCESSFUL: jr-standalone.exe
echo ========================================
dir jr-standalone.exe
echo.

REM Clean up intermediate files
if exist launcher.obj del launcher.obj

echo.
echo ========================================
echo ALL BUILDS SUCCESSFUL
echo ========================================
echo jr.exe            - Dynamic CRT (~23KB, requires VC++ Redistributable)
echo jr-standalone.exe - Static CRT (~200KB, no dependencies)
echo.
