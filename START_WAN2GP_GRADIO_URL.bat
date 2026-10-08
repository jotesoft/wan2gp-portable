@echo off
setlocal EnableExtensions EnableDelayedExpansion

set "ROOT=%~dp0"
set "PYTHON=%ROOT%runtime\Python311\python.exe"
set "WGP=%ROOT%Wan2GP\wgp.py"
set "PORT=7860"

title Wan2GP RTX 5060 Ti - Gradio LAN

REM ============================================================
REM Get LAN IP
REM ============================================================
call "%ROOT%_WAN2GP_LAN_COMMON.bat" :get_ip LAN_IP
if not defined LAN_IP set "LAN_IP=127.0.0.1"

REM ============================================================
REM Check files
REM ============================================================
if not exist "%PYTHON%" (
    echo.
    echo [ERROR] Portable Python not found:
    echo %PYTHON%
    pause
    exit /b 1
)

if not exist "%WGP%" (
    echo.
    echo [ERROR] Wan2GP wgp.py not found:
    echo %WGP%
    pause
    exit /b 1
)

REM ============================================================
REM Check whether port is already in use
REM ============================================================
call "%ROOT%_WAN2GP_LAN_COMMON.bat" :port_status %PORT%
if errorlevel 1 (
    echo.
    echo [ERROR] Port %PORT% is already in use.
    echo Use the menu to diagnose the port or edit PORT in this file.
    pause
    exit /b 2
)

echo ============================================================
echo Wan2GP RTX 5060 Ti - Gradio LAN
echo ============================================================
echo.
echo Local Gradio : http://127.0.0.1:%PORT%/
echo LAN Gradio   : http://%LAN_IP%:%PORT%/
echo Deepy Web    : http://%LAN_IP%:%PORT%/deepy/
echo.
echo Binding mode : --listen
echo Public share : OFF (no --share)
echo.
echo Wan2GP will start now.
echo The browser will open automatically when the server is ready.
echo ============================================================
echo.

pushd "%ROOT%Wan2GP"

REM ============================================================
REM START WAN2GP - ONLY ONCE
REM ============================================================
start "" /B "%PYTHON%" "%WGP%" --listen --server-port %PORT%

echo.
echo [INFO] Starting Wan2GP...
echo [INFO] Waiting for Gradio server on port %PORT%...

REM ============================================================
REM WAIT UNTIL PORT IS READY
REM ============================================================
set "READY=0"

for /L %%N in (1,1,120) do (
    powershell -NoProfile -Command ^
        "$r=Test-NetConnection -ComputerName 127.0.0.1 -Port %PORT% -InformationLevel Quiet -WarningAction SilentlyContinue; if($r){exit 0}else{exit 1}" ^
        >nul 2>&1

    if not errorlevel 1 (
        set "READY=1"
        goto SERVER_READY
    )

    timeout /t 1 /nobreak >nul
)

:SERVER_READY

echo.

if "%READY%"=="1" (
    echo ============================================================
    echo [OK] Wan2GP Gradio server is ready!
    echo ============================================================
    echo.
    echo Opening:
    echo http://%LAN_IP%:%PORT%/
    echo.

    REM ============================================================
    REM OPEN CORRECT LAN URL
    REM ============================================================
    start "" "http://%LAN_IP%:%PORT%/"

    echo Local  : http://127.0.0.1:%PORT%/
    echo LAN    : http://%LAN_IP%:%PORT%/
    echo Deepy  : http://%LAN_IP%:%PORT%/deepy/
    echo.
    echo Keep this window open while Wan2GP is running.
    echo ============================================================
) else (
    echo ============================================================
    echo [WARNING] Server did not become ready within 120 seconds.
    echo ============================================================
    echo.
    echo Try opening manually:
    echo http://127.0.0.1:%PORT%/
    echo http://%LAN_IP%:%PORT%/
    echo.
)

echo.
echo Wan2GP is running in the background.
echo Press any key to close this launcher window.
echo (Wan2GP itself will continue running.)
pause >nul

popd
exit /b 0