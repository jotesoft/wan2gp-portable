@echo off
setlocal EnableExtensions EnableDelayedExpansion
set "ROOT=%~dp0"
set "PYTHON=%ROOT%runtime\Python311\python.exe"
set "WGP=%ROOT%Wan2GP\wgp.py"
set "PORT=7860"
call "%ROOT%_WAN2GP_LAN_COMMON.bat" :get_ip LAN_IP
if not defined LAN_IP set "LAN_IP=YOUR-PC-IP"
if not exist "%PYTHON%" (echo [ERROR] Portable Python not found.&pause&exit /b 1)
if not exist "%WGP%" (echo [ERROR] Wan2GP source not found.&pause&exit /b 1)
call "%ROOT%_WAN2GP_LAN_COMMON.bat" :port_status %PORT%
if errorlevel 1 (echo [ERROR] Port %PORT% is already in use.&pause&exit /b 2)
echo.
echo Gradio LAN: http://%LAN_IP%:%PORT%/
echo Local     : http://127.0.0.1:%PORT%/
echo.
cd /d "%ROOT%Wan2GP"
"%PYTHON%" "%WGP%" --listen --server-port %PORT%
set "RC=%ERRORLEVEL%"
echo.
echo Wan2GP exited with code !RC!.
pause
exit /b !RC!
