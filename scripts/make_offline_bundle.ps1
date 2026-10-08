$ErrorActionPreference='Stop'
$Root=Split-Path -Parent $PSScriptRoot
$Python=Join-Path $Root 'runtime\Python311\python.exe'
$Git=Join-Path $Root 'runtime\Git\cmd\git.exe'
$Wan=Join-Path $Root 'Wan2GP\wgp.py'
if(-not(Test-Path $Python) -or -not(Test-Path $Git) -or -not(Test-Path $Wan)){throw 'Install Wan2GP successfully before making an offline bundle.'}
$parent=Split-Path $Root -Parent
$name=(Split-Path $Root -Leaf)+'-OFFLINE'
$out=Join-Path $parent ($name+'.zip')
if(Test-Path $out){Remove-Item $out -Force}
Write-Host 'Creating populated offline bundle...' -ForegroundColor Cyan
Compress-Archive -Path (Join-Path $Root '*') -DestinationPath $out -Force
Write-Host "Created: $out" -ForegroundColor Green
