@echo off
if /i "%~1"==":get_ip" goto get_ip
if /i "%~1"==":port_status" goto port_status
exit /b 0

:get_ip
set "IP_RESULT="
for /f "usebackq delims=" %%I in (`powershell -NoProfile -ExecutionPolicy Bypass -Command "$x=Get-NetIPConfiguration ^| Where-Object { $_.NetAdapter.Status -eq 'Up' -and $_.IPv4DefaultGateway -ne $null } ^| ForEach-Object { $_.IPv4Address.IPAddress } ^| Where-Object { $_ -match '^(10\.|192\.168\.|172\.(1[6-9]|2[0-9]|3[0-1])\.)' } ^| Select-Object -First 1; if($x){$x}"`) do set "IP_RESULT=%%I"
if not defined IP_RESULT (
  for /f "usebackq delims=" %%I in (`powershell -NoProfile -ExecutionPolicy Bypass -Command "$x=Get-NetIPAddress -AddressFamily IPv4 -PrefixOrigin Dhcp -ErrorAction SilentlyContinue ^| Where-Object { $_.IPAddress -notmatch '^(127\.|169\.254\.)' } ^| Select-Object -First 1 -ExpandProperty IPAddress; if($x){$x}"`) do set "IP_RESULT=%%I"
)
for /f "tokens=1,* delims= " %%A in ("%~2 %IP_RESULT%") do set "%%A=%%B"
exit /b 0

:port_status
set "CHECK_PORT=%~2"
powershell -NoProfile -ExecutionPolicy Bypass -Command "$x=Get-NetTCPConnection -LocalPort %CHECK_PORT% -State Listen -ErrorAction SilentlyContinue; if($x){exit 1}else{exit 0}"
exit /b %ERRORLEVEL%
