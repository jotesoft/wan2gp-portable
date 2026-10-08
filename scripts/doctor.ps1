$ErrorActionPreference='Continue'
$Root=Split-Path -Parent $PSScriptRoot
$Runtime=Join-Path $Root 'runtime'
$PythonExe=Join-Path $Runtime 'Python311\python.exe'
$GitExe=Join-Path $Runtime 'Git\cmd\git.exe'
$UvExe=Join-Path $Runtime 'uv\uv.exe'
$Aria2Exe=Join-Path $Runtime 'aria2\aria2c.exe'
$FFmpegExe=Join-Path $Runtime 'ffmpeg\bin\ffmpeg.exe'
$FFprobeExe=Join-Path $Runtime 'ffmpeg\bin\ffprobe.exe'
$Wan=Join-Path $Root 'Wan2GP\wgp.py'
Write-Host '=== Wan2GP RTX 5060 Ti Doctor v8 ===' -ForegroundColor Cyan
Write-Host "Root: $Root"
if(Test-Path $GitExe){& $GitExe --version}
if(Test-Path $UvExe){& $UvExe --version}
if(Test-Path $Aria2Exe){& $Aria2Exe --version 2>$null | Select-Object -First 1}
if(Test-Path $FFmpegExe){& $FFmpegExe -hide_banner -version 2>$null | Select-Object -First 1}else{Write-Host 'FFmpeg: MISSING' -ForegroundColor Red}
if(Test-Path $FFprobeExe){& $FFprobeExe -hide_banner -version 2>$null | Select-Object -First 1}else{Write-Host 'ffprobe: MISSING' -ForegroundColor Red}
if(Test-Path $PythonExe){
  Remove-Item Env:PYTHONHOME,Env:PYTHONPATH,Env:VIRTUAL_ENV,Env:CONDA_PREFIX,Env:CONDA_DEFAULT_ENV -ErrorAction SilentlyContinue
  $env:PYTHONNOUSERSITE='1';$env:UV_NO_CONFIG='1';$env:UV_NO_MODIFY_PATH='1'
  & $PythonExe -E -s --version
  & $PythonExe -E -s -m pip --version
  $code=@'
import torch
try:
 print('Torch:',torch.__version__)
 print('Torch CUDA:',torch.version.cuda)
 print('CUDA available:',torch.cuda.is_available())
 if torch.cuda.is_available():
  print('GPU:',torch.cuda.get_device_name(0));print('VRAM GB:',round(torch.cuda.get_device_properties(0).total_memory/1024**3,2))
except Exception as e:print('Torch ERROR:',e)
for n in ['triton','sageattention']:
 try:
  m=__import__(n);print(n+':',getattr(m,'__version__','OK'))
 except Exception as e:print(n+': ERROR',e)
'@
  & $PythonExe -E -s -c $code
}
Write-Host "Wan2GP entry: $(Test-Path $Wan)"
$nvsmi=Get-Command nvidia-smi.exe -ErrorAction SilentlyContinue
if($nvsmi){& $nvsmi.Source}
