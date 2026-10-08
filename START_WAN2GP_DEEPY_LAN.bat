@echo off
setlocal EnableExtensions EnableDelayedExpansion
set "ROOT=%~dp0"
set "PYTHON=%ROOT%runtime\Python311\python.exe"
set "WGP=%ROOT%Wan2GP\wgp.py"
set "PORT=7860"
call "%ROOT%_WAN2GP_LAN_COMMON.bat" :get_ip LAN_IP
if not defined LAN_IP set "LAN_IP=YOUR-PC-IP"

if not exist "%PYTHON%" (
  echo [ERROR] Portable Python not found: %PYTHON%
  pause
  exit /b 1
)
if not exist "%WGP%" (
  echo [ERROR] Wan2GP source not found: %WGP%
  pause
  exit /b 1
)
call "%ROOT%_WAN2GP_LAN_COMMON.bat" :port_status %PORT%
if errorlevel 1 (
  echo [ERROR] Port %PORT% is already in use.
  pause
  exit /b 2
)

echo ============================================================
echo Wan2GP RTX 5060 Ti - Standalone Deepy Web LAN
 echo ============================================================
echo Local Web : http://127.0.0.1:%PORT%/
echo LAN Web   : http://%LAN_IP%:%PORT%/
echo.
echo Public share : OFF
 echo ============================================================
echo.
pushd "%ROOT%Wan2GP"
"%PYTHON%" "%WGP%" --deepy-server --listen --server-port %PORT%
set "RC=%ERRORLEVEL%"
popd
echo.
echo Deepy server exited with code !RC!.
pause
exit /b !RC!
