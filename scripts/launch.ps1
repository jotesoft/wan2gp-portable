[CmdletBinding()]
param([switch]$Safe)
$ErrorActionPreference='Stop'
$Root=Split-Path -Parent $PSScriptRoot
$Runtime=Join-Path $Root 'runtime'
$PythonExe=Join-Path $Runtime 'Python311\python.exe'
$UvExe=Join-Path $Runtime 'uv\uv.exe'
$GitDir=Join-Path $Runtime 'Git'
$FFmpegDir=Join-Path $Runtime 'ffmpeg'
$Aria2Dir=Join-Path $Runtime 'aria2'
$WanDir=Join-Path $Root 'Wan2GP'
$ConfigDir=Join-Path $Root 'config'
$OutputsDir=Join-Path $Root 'outputs'
$ModelDir=Join-Path $Root 'models'
$CacheDir=Join-Path $Root 'cache'
if(-not(Test-Path $PythonExe) -or -not(Test-Path $UvExe) -or -not(Test-Path (Join-Path $WanDir 'wgp.py'))){
  & (Join-Path $PSScriptRoot 'bootstrap.ps1')
  if($LASTEXITCODE -ne 0){exit $LASTEXITCODE}
}
Remove-Item Env:PYTHONHOME -ErrorAction SilentlyContinue
Remove-Item Env:PYTHONPATH -ErrorAction SilentlyContinue
Remove-Item Env:VIRTUAL_ENV -ErrorAction SilentlyContinue
Remove-Item Env:CONDA_PREFIX -ErrorAction SilentlyContinue
Remove-Item Env:CONDA_DEFAULT_ENV -ErrorAction SilentlyContinue
$env:PYTHONNOUSERSITE='1'
$env:PATH="$(Join-Path $GitDir 'cmd');$(Join-Path $GitDir 'usr\bin');$(Join-Path $Runtime 'Python311');$(Join-Path $Runtime 'Python311\Scripts');$(Join-Path $FFmpegDir 'bin');$Aria2Dir;$(Join-Path $Runtime 'uv');$env:PATH"
$env:HF_HOME=Join-Path $ModelDir 'huggingface'
$env:HF_HUB_CACHE=Join-Path $ModelDir 'huggingface\hub'
$env:HUGGINGFACE_HUB_CACHE=$env:HF_HUB_CACHE
$env:TORCH_HOME=Join-Path $ModelDir 'torch'
$env:TRITON_CACHE_DIR=Join-Path $CacheDir 'triton'
$env:TORCH_EXTENSIONS_DIR=Join-Path $CacheDir 'torch_extensions'
$env:PIP_CACHE_DIR=Join-Path $CacheDir 'pip'
$env:UV_CACHE_DIR=Join-Path $CacheDir 'uv'
$env:UV_NO_CONFIG='1'
$env:UV_NO_MODIFY_PATH='1'
$env:PYTORCH_CUDA_ALLOC_CONF='expandable_segments:True'
$env:CUDA_MODULE_LOADING='LAZY'
$env:PYTHONUTF8='1'
$env:GRADIO_ANALYTICS_ENABLED='False'
New-Item -ItemType Directory -Force -Path $ConfigDir,$OutputsDir,$ModelDir,$CacheDir | Out-Null
$LaunchArgs=@('wgp.py','--profile','4','--config',$ConfigDir,'--output-dir',$OutputsDir,'--open-browser','--fp16')
if($Safe){$LaunchArgs += @('--attention','sdpa')} else {$LaunchArgs += @('--attention','sage2')}
Write-Host ''
Write-Host 'Launching Wan2GP RTX 5060 Ti 16GB' -ForegroundColor Cyan
if($Safe){$mode='Mode: Profile 4 + SDPA'}else{$mode='Mode: Profile 4 + Sage2 + FP16'}
Write-Host $mode -ForegroundColor Green
Write-Host ''
Set-Location $WanDir
& $PythonExe -E -s @LaunchArgs
exit $LASTEXITCODE
