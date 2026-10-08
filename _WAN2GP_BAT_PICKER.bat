@echo off
setlocal EnableExtensions EnableDelayedExpansion
set "LIST=%TEMP%\wan2gp_bat_list_%RANDOM%.txt"
set "SEL="
powershell -NoProfile -ExecutionPolicy Bypass -Command "$me='WAN2GP_MENU.bat'; Get-ChildItem -LiteralPath '%~dp0' -Filter '*.bat' | Where-Object { $_.Name -ne $me -and $_.Name -notlike '_WAN2GP_*' } | Sort-Object Name | ForEach-Object -Begin {$i=1} -Process { '{0}|{1}' -f $i,$_.Name; $i++ }" > "%LIST%"
if not exist "%LIST%" goto none
findstr /r /c:"^[0-9][0-9]*|" "%LIST%" >nul 2>&1
if errorlevel 1 goto none
:show
cls
echo.
echo ================= Existing BAT files =====================
for /f "tokens=1,* delims=|" %%A in (%LIST%) do echo  [%%A] %%B
echo  [0] Back
echo.
set /p "N=Choose BAT number: "
if "%N%"=="0" goto done
set "MATCH="
for /f "tokens=1,* delims=|" %%A in (%LIST%) do if "%%A"=="%N%" set "MATCH=%%B"
if not defined MATCH (
  echo Invalid selection.
  pause
  goto show
)
set "SELECTED_BAT=%MATCH%"
goto done
:none
echo.
echo No other BAT files found.
pause
:done
del "%LIST%" >nul 2>&1
endlocal & set "SELECTED_BAT=%SELECTED_BAT%"
exit /b 0
