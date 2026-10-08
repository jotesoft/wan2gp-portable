@echo off
setlocal EnableExtensions EnableDelayedExpansion
set "ROOT=%~dp0"
set "PORT=7860"
call "%ROOT%START_WAN2GP_GRADIO_URL.bat"
exit /b %ERRORLEVEL%
