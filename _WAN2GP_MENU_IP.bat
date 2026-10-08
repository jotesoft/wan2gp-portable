@echo off
set "LAN_IP="
for /f "usebackq delims=" %%I in (`powershell -NoProfile -ExecutionPolicy Bypass -Command "$x=Get-NetIPConfiguration ^| Where-Object { $_.NetAdapter.Status -eq 'Up' -and $_.IPv4DefaultGateway -ne $null } ^| ForEach-Object { $_.IPv4Address.IPAddress } ^| Where-Object { $_ -match '^(10\.|192\.168\.|172\.(1[6-9]|2[0-9]|3[0-1])\.)' } ^| Select-Object -First 1; if($x){$x}"`) do set "LAN_IP=%%I"
if not defined LAN_IP set "LAN_IP=Not detected"
exit /b 0
