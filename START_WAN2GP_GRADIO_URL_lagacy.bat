@echo off
setlocal EnableExtensions EnableDelayedExpansion
set "ROOT=%~dp0"
set "PYTHON=%ROOT%runtime\Python311\python.exe"
set "WGP=%ROOT%Wan2GP\wgp.py"
set "PORT=7860"

title Wan2GP RTX 5060 Ti - Gradio LAN
call "%ROOT%_WAN2GP_LAN_COMMON.bat" :get_ip LAN_IP
if not defined LAN_IP set "LAN_IP=YOUR-PC-IP"

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
echo Start the server, then the launcher will open the local page.
echo Keep this window open while Wan2GP is running.
echo ============================================================
echo.

pushd "%ROOT%Wan2GP"
"%PYTHON%" "%WGP%" --listen --server-port %PORT% 
REM Start Wan2GP without its broken 0.0.0.0 browser opener
start "" /B "%PYTHON%" "%WGP%" --listen --server-port %PORT%

echo.
echo Wan2GP exited with code !RC!.
pause
exit /b !RC!
