@echo off
setlocal EnableExtensions
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\bootstrap.ps1" -InstallOnly
set "RC=%ERRORLEVEL%"
if not "%RC%"=="0" (
  echo.
  echo [FAILED] Installation/repair failed. See logs\installer.log
  pause
) else (
  echo.
  echo [OK] Installation/repair completed.
  echo Run START_WAN2GP_5060Ti.bat
  pause
)
exit /b %RC%
