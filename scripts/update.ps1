[CmdletBinding()]
param()
$ErrorActionPreference='Stop'
$Root=Split-Path -Parent $PSScriptRoot
$Runtime=Join-Path $Root 'runtime'
$GitExe=Join-Path $Runtime 'Git\cmd\git.exe'
$PythonExe=Join-Path $Runtime 'Python311\python.exe'
$UvExe=Join-Path $Runtime 'uv\uv.exe'
$FFmpegExe=Join-Path $Runtime 'ffmpeg\bin\ffmpeg.exe'
$FFprobeExe=Join-Path $Runtime 'ffmpeg\bin\ffprobe.exe'
$WanDir=Join-Path $Root 'Wan2GP'
if(-not(Test-Path $GitExe) -or -not(Test-Path $PythonExe) -or -not(Test-Path $UvExe) -or -not(Test-Path $FFmpegExe) -or -not(Test-Path $FFprobeExe) -or -not(Test-Path(Join-Path $WanDir '.git'))){
  & (Join-Path $PSScriptRoot 'bootstrap.ps1') -InstallOnly
  if($LASTEXITCODE -ne 0){exit $LASTEXITCODE}
}
Remove-Item Env:PYTHONHOME -ErrorAction SilentlyContinue
Remove-Item Env:PYTHONPATH -ErrorAction SilentlyContinue
Remove-Item Env:VIRTUAL_ENV -ErrorAction SilentlyContinue
Remove-Item Env:CONDA_PREFIX -ErrorAction SilentlyContinue
Remove-Item Env:CONDA_DEFAULT_ENV -ErrorAction SilentlyContinue
$env:PATH="$(Join-Path $Runtime 'Git\cmd');$(Join-Path $Runtime 'Git\usr\bin');$(Join-Path $Runtime 'Python311');$(Join-Path $Runtime 'Python311\Scripts');$(Join-Path $Runtime 'uv');$(Join-Path $Runtime 'ffmpeg\bin');$(Join-Path $Runtime 'aria2');$env:PATH"
$env:UV_CACHE_DIR=Join-Path $Root 'cache\uv';$env:UV_NO_CONFIG='1';$env:UV_NO_MODIFY_PATH='1'
Push-Location $WanDir
try{
  Write-Host 'Updating Wan2GP source...' -ForegroundColor Cyan
  & $GitExe fetch --depth=1 origin main;if($LASTEXITCODE -ne 0){throw 'git fetch failed'}
  & $GitExe reset --hard FETCH_HEAD;if($LASTEXITCODE -ne 0){throw 'git reset failed'}
  Write-Host 'Updating Wan2GP requirements with uv...' -ForegroundColor Cyan
  & $UvExe pip install --python $PythonExe --no-python-downloads -r (Join-Path $WanDir 'requirements.txt');if($LASTEXITCODE -ne 0){throw 'requirements update failed'}
  Write-Host 'Re-enforcing RTX 50-series PyTorch 2.10 / CUDA 13.0...' -ForegroundColor Cyan
  & $UvExe pip install --python $PythonExe --no-python-downloads --reinstall 'torch==2.10.0' 'torchvision==0.25.0' 'torchaudio==2.10.0' --index-url https://download.pytorch.org/whl/cu130;if($LASTEXITCODE -ne 0){throw 'PyTorch reinstall failed'}
  & $UvExe pip install --python $PythonExe --no-python-downloads -U 'triton-windows>=3.6,<3.7';if($LASTEXITCODE -ne 0){throw 'Triton update failed'}
  & $UvExe pip install --python $PythonExe --no-python-downloads -U 'https://github.com/woct0rdho/SageAttention/releases/download/v2.2.0-windows.post4/sageattention-2.2.0+cu130torch2.9.0andhigher.post4-cp39-abi3-win_amd64.whl';if($LASTEXITCODE -ne 0){throw 'SageAttention update failed'}
}finally{Pop-Location}
Remove-Item (Join-Path $Root '.python_stack_ready') -Force -ErrorAction SilentlyContinue
Write-Host ''
Write-Host 'Update complete.' -ForegroundColor Green
