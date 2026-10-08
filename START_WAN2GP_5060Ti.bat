@echo off
setlocal EnableExtensions
cd /d "%~dp0"

title Wan2GP RTX 5060 Ti 16GB Portable v8

set "ROOT=%~dp0"
set "PY=%ROOT%runtime\Python311\python.exe"
set "WAN=%ROOT%Wan2GP"
set "FFBIN=%ROOT%runtime\ffmpeg\bin"
set "GITBIN=%ROOT%runtime\Git\cmd"
set "VERIFY=%ROOT%verify_install.py"

if not exist "%PY%" (
    echo [ERROR] Portable Python not found:
    echo %PY%
    pause
    exit /b 1
)

if not exist "%WAN%\wgp.py" (
    echo [ERROR] Wan2GP source not found:
    echo %WAN%\wgp.py
    pause
    exit /b 1
)

if not exist "%VERIFY%" (
    echo [ERROR] verify_install.py not found.
    echo Copy the v8 FINAL-FIX files into this folder first.
    pause
    exit /b 1
)

rem Process-local PATH only. Nothing is permanently changed in Windows.
set "PATH=%FFBIN%;%GITBIN%;%ROOT%runtime\aria2;%ROOT%runtime\uv;%PATH%"

cls
echo ============================================================
echo  Wan2GP RTX 5060 Ti 16GB Portable v8
echo  FINAL FIXED LAUNCHER
echo  No Miniconda / No system Python / No permanent PATH changes
echo ============================================================
echo.
echo [1/2] Running final environment verification...
echo.
"%PY%" "%VERIFY%"
set "VERIFY_RC=%ERRORLEVEL%"

echo.
if not "%VERIFY_RC%"=="0" (
    echo [FAILED] Verification found a real problem.
    echo Wan2GP will NOT be launched.
    echo.
    pause
    exit /b %VERIFY_RC%
)

echo [2/2] Starting Wan2GP...
echo.
cd /d "%WAN%"

:launch
"%PY%" wgp.py
set "APP_RC=%ERRORLEVEL%"

rem Wan2GP uses exit code 42 for a requested restart.
if "%APP_RC%"=="42" (
    echo.
    echo [Wan2GP] Restart requested. Restarting...
    timeout /t 2 /nobreak >nul
    goto launch
)

echo.
if not "%APP_RC%"=="0" (
    echo [Wan2GP] Process exited with code %APP_RC%.
) else (
    echo [Wan2GP] Closed normally.
)
echo.
pause
exit /b %APP_RC%
