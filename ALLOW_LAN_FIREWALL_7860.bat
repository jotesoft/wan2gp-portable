@echo off
setlocal EnableExtensions
set "RULE=Wan2GP Gradio LAN 7860"
net session >nul 2>&1
if not "%ERRORLEVEL%"=="0" (
  echo Requesting Administrator permission...
  powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
  exit /b
)
echo Removing old rule, if present...
netsh advfirewall firewall delete rule name="%RULE%" >nul 2>&1
echo Adding Private-network firewall rule for TCP 7860...
netsh advfirewall firewall add rule name="%RULE%" dir=in action=allow protocol=TCP localport=7860 profile=private
if errorlevel 1 (
  echo.
  echo [ERROR] Firewall rule could not be added.
) else (
  echo.
  echo [OK] Windows Firewall now allows TCP 7860 on the Private profile.
  echo      Wan2GP itself still needs to be started with --listen.
)
echo.
pause
