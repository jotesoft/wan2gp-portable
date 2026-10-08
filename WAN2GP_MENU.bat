@echo off
setlocal EnableExtensions EnableDelayedExpansion
title Wan2GP RTX 5060 Ti - Portable Launcher Menu
set "ROOT=%~dp0"
set "PORT=7860"

:menu
cls
echo.
echo ============================================================
echo       Wan2GP RTX 5060 Ti - Portable Launcher Menu
 echo ============================================================
echo.
call "%ROOT%_WAN2GP_MENU_IP.bat"
echo   PC LAN IP : !LAN_IP!
echo   Gradio    : http://127.0.0.1:%PORT%/
echo   LAN URL   : http://!LAN_IP!:%PORT%/
echo   Deepy URL : http://!LAN_IP!:%PORT%/deepy/
echo.
echo ------------------------------------------------------------
echo  [1] Start Gradio + LAN access + open browser
 echo  [2] Start Gradio + LAN access (no browser)
echo  [3] Start standalone Deepy Web + LAN access
 echo  [4] Show / open Gradio URLs
 echo  [5] Verify RTX 5060 Ti installation
 echo  [6] Run the existing main Wan2GP launcher
 echo  [7] Run another BAT in this folder
 echo  [8] Allow TCP 7860 through Windows Firewall (Private)
 echo  [9] Open the Wan2GP project folder
 echo  [0] Exit
 echo ------------------------------------------------------------
set "CHOICE="
choice /c 1234567890 /n /m "Select an option: "
if errorlevel 10 goto end
if errorlevel 9 goto open_folder
if errorlevel 8 goto firewall
if errorlevel 7 goto other_bat
if errorlevel 6 goto existing_launcher
if errorlevel 5 goto verify
if errorlevel 4 goto urls
if errorlevel 3 goto deepy
if errorlevel 2 goto gradio_no_browser
if errorlevel 1 goto gradio

goto menu

:gradio
call "%ROOT%START_WAN2GP_GRADIO_URL.bat"
goto menu

:gradio_no_browser
call "%ROOT%_WAN2GP_GRADIO_NO_BROWSER.bat"
goto menu

:deepy
call "%ROOT%START_WAN2GP_DEEPY_LAN.bat"
goto menu

:urls
cls
echo.
echo ===================== Wan2GP URLs ==========================
call "%ROOT%_WAN2GP_MENU_IP.bat"
echo.
echo Local Gradio : http://127.0.0.1:%PORT%/
echo LAN Gradio   : http://!LAN_IP!:%PORT%/
echo LAN Deepy    : http://!LAN_IP!:%PORT%/deepy/
echo.
echo These URLs are valid while the Wan2GP server is running.
echo Do NOT use 0.0.0.0 in your phone/tablet browser.
echo.
choice /c OB /n /m "Open browser or Back? [O/B]: "
if errorlevel 2 goto menu
start "" "http://127.0.0.1:%PORT%/"
goto menu

:verify
if exist "%ROOT%VERIFY_WAN2GP_5060Ti.bat" (
  call "%ROOT%VERIFY_WAN2GP_5060Ti.bat"
) else if exist "%ROOT%VERIFY_WAN2GP.bat" (
  call "%ROOT%VERIFY_WAN2GP.bat"
) else (
  echo.
  echo No verification BAT was found in this folder.
  echo The menu can still launch Wan2GP normally.
  pause
)
goto menu

:existing_launcher
if exist "%ROOT%START_WAN2GP_5060Ti.bat" (
  call "%ROOT%START_WAN2GP_5060Ti.bat"
) else (
  echo.
  echo START_WAN2GP_5060Ti.bat was not found.
  pause
)
goto menu

:firewall
call "%ROOT%ALLOW_LAN_FIREWALL_7860.bat"
goto menu

:open_folder
start "" explorer.exe "%ROOT%Wan2GP"
goto menu

:other_bat
call "%ROOT%_WAN2GP_BAT_PICKER.bat"
if defined SELECTED_BAT (
  call "%ROOT%!SELECTED_BAT!"
  set "SELECTED_BAT="
)
goto menu

:end
endlocal
exit /b 0
