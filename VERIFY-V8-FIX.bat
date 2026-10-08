@echo off
setlocal
cd /d "%~dp0"
set "PY=%~dp0runtime\Python311\python.exe"
if not exist "%PY%" (
  echo [ERROR] Portable Python not found:
  echo %PY%
  pause
  exit /b 1
)
echo.
echo Running repaired final verification...
echo.
"%PY%" "%~dp0verify_install.py"
set "RC=%ERRORLEVEL%"
echo.
if not "%RC%"=="0" (
  echo Verification found a real problem. The exact component and Python exception are above.
  echo No packages were reinstalled.
) else (
  echo Verification passed. Your v8 installation is usable.
)
echo.
pause
exit /b %RC%
