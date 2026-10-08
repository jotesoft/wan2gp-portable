@echo off
setlocal EnableExtensions
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\bootstrap.ps1"
set "RC=%ERRORLEVEL%"
if not "%RC%"=="0" (
  echo.
  echo [FAILED] Wan2GP setup should complete but launch failed use START_WAN2GP_5060Ti.bat or START_WAN2GP.bat to launch wan2gp See logs\installer.log
  pause
)
exit /b %RC%
