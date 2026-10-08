[CmdletBinding()]
param([switch]$InstallOnly)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$Root = Split-Path -Parent $PSScriptRoot
$Runtime = Join-Path $Root 'runtime'
$GitDir = Join-Path $Runtime 'Git'
$PythonDir = Join-Path $Runtime 'Python311'
$FFmpegDir = Join-Path $Runtime 'ffmpeg'
$Aria2Dir = Join-Path $Runtime 'aria2'
$Aria2Exe = Join-Path $Aria2Dir 'aria2c.exe'
$UvDir = Join-Path $Runtime 'uv'
$UvExe = Join-Path $UvDir 'uv.exe'
$Downloads = Join-Path $Root 'downloads'
$WanDir = Join-Path $Root 'Wan2GP'
$ConfigDir = Join-Path $Root 'config'
$OutputsDir = Join-Path $Root 'outputs'
$LogsDir = Join-Path $Root 'logs'
$ModelDir = Join-Path $Root 'models'
$CacheDir = Join-Path $Root 'cache'
$LogFile = Join-Path $LogsDir 'installer.log'
$VCRedistExe = Join-Path $Downloads 'VC_redist.x64.exe'
$Marker = Join-Path $Root '.installed.json'

New-Item -ItemType Directory -Force -Path $Runtime,$Downloads,$ConfigDir,$OutputsDir,$LogsDir,$ModelDir,$CacheDir,$Aria2Dir,$UvDir | Out-Null

function Log([string]$Text,[string]$Color='White') {
  $stamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
  Add-Content -LiteralPath $LogFile -Value "[$stamp] $Text"
  Write-Host $Text -ForegroundColor $Color
}
function Fail([string]$Text) {
  Log "[ERROR] $Text" 'Red'
  Log "See $LogFile" 'DarkGray'
  exit 1
}
function Get-Sha256([string]$File) {
  return (Get-FileHash -Algorithm SHA256 -LiteralPath $File).Hash.ToLowerInvariant()
}
function Download-File([string[]]$Urls,[string]$OutFile,[string]$Sha256='',[switch]$Small) {
  if(Test-Path $OutFile -PathType Leaf) {
    if($Sha256) {
      $h=Get-Sha256 $OutFile
      if($h -eq $Sha256.ToLowerInvariant()) { return }
      Log "  Existing file has wrong SHA256; replacing: $OutFile" 'Yellow'
      Remove-Item -LiteralPath $OutFile -Force
    } else { return }
  }
  $part=$OutFile+'.part'
  $dir=Split-Path -Parent $OutFile
  $leaf=Split-Path -Leaf $part
  $curl=(Get-Command curl.exe -ErrorAction SilentlyContinue)
  $attemptUrls=@($Urls | Where-Object {$_ -and $_.Trim()})
  if(-not $attemptUrls.Count){Fail "No download URL supplied for $OutFile"}
  foreach($url in $attemptUrls) {
    Log "  Downloading $url" 'DarkCyan'
    for($try=1;$try -le 5;$try++) {
      try {
        $usedAria2=$false
        if((Test-Path $Aria2Exe) -and -not $Small) {
          $a=@('--allow-overwrite=true','--auto-file-renaming=false','--continue=true','--file-allocation=none','--max-tries=5','--retry-wait=2','--connect-timeout=30','--timeout=180','--summary-interval=5','--split=8','--max-connection-per-server=8','--min-split-size=1M','--dir',$dir,'--out',$leaf,$url)
          & $Aria2Exe @a
          if($LASTEXITCODE -eq 0 -and (Test-Path $part)){ $usedAria2=$true }
        }
        if(-not $usedAria2) {
          if($curl) {
            & $curl.Source '--fail' '--location' '--retry' '5' '--retry-all-errors' '--continue-at' '-' '--connect-timeout' '30' '--max-time' '1800' '--user-agent' 'Wan2GP-RTX5060Ti-Portable/8.0' '--output' $part $url
            if($LASTEXITCODE -eq 0 -and (Test-Path $part)){ $usedAria2=$true }
          } else {
            Invoke-WebRequest -UseBasicParsing -Uri $url -OutFile $part
            if(Test-Path $part){$usedAria2=$true}
          }
        }
        if($usedAria2) {
          if($Sha256) {
            $h=Get-Sha256 $part
            if($h -ne $Sha256.ToLowerInvariant()) {
              Log "  SHA256 mismatch on attempt $try. Expected $Sha256; got $h" 'Yellow'
              Remove-Item -LiteralPath $part -Force -ErrorAction SilentlyContinue
              throw 'checksum mismatch'
            }
          }
          Move-Item -Force $part $OutFile
          return
        }
      } catch {
        Log "  Download attempt $try failed: $($_.Exception.Message)" 'Yellow'
      }
      Start-Sleep -Seconds (2*$try)
    }
    Log "  Source failed after retries, trying next source if available." 'Yellow'
  }
  Fail "Download failed after all retries: $OutFile"
}
function Invoke-Native([string]$Exe,[string[]]$NativeArgs,[string]$Cwd=$Root) {
  if($null -eq $NativeArgs){ $NativeArgs=@() }
  Log ("  > " + $Exe + $(if($NativeArgs.Count){ ' ' + ($NativeArgs -join ' ') } else { '' })) 'DarkGray'
  $old=Get-Location
  try { Set-Location $Cwd; & $Exe @NativeArgs; $rc=[int]$LASTEXITCODE }
  finally { Set-Location $old }
  if($rc -ne 0) { Fail "Command failed with exit code ${rc}: $Exe" }
}
function Set-Env {
  $paths=@(
    (Join-Path $GitDir 'cmd')
    (Join-Path $GitDir 'usr\bin')
    $PythonDir
    (Join-Path $PythonDir 'Scripts')
    (Join-Path $FFmpegDir 'bin')
    $Aria2Dir
    $UvDir
  )
  Remove-Item Env:PYTHONHOME -ErrorAction SilentlyContinue
  Remove-Item Env:PYTHONPATH -ErrorAction SilentlyContinue
  Remove-Item Env:VIRTUAL_ENV -ErrorAction SilentlyContinue
  Remove-Item Env:CONDA_PREFIX -ErrorAction SilentlyContinue
  Remove-Item Env:CONDA_DEFAULT_ENV -ErrorAction SilentlyContinue
  $env:PYTHONNOUSERSITE='1'
  $env:PIP_PREFER_BINARY='1'
  $env:PATH=($paths + $env:PATH) -join ';'
  $env:PIP_DISABLE_PIP_VERSION_CHECK='1'
  $env:PIP_NO_INPUT='1'
  $env:PIP_NO_WARN_SCRIPT_LOCATION='1'
  $env:PIP_DEFAULT_TIMEOUT='180'
  $env:PIP_RETRIES='10'
  $env:PIP_CACHE_DIR=(Join-Path $CacheDir 'pip')
  $env:HF_HOME=(Join-Path $ModelDir 'huggingface')
  $env:HF_HUB_CACHE=(Join-Path $ModelDir 'huggingface\hub')
  $env:HUGGINGFACE_HUB_CACHE=$env:HF_HUB_CACHE
  $env:TORCH_HOME=(Join-Path $ModelDir 'torch')
  $env:TRITON_CACHE_DIR=(Join-Path $CacheDir 'triton')
  $env:TORCH_EXTENSIONS_DIR=(Join-Path $CacheDir 'torch_extensions')
  $env:UV_CACHE_DIR=(Join-Path $CacheDir 'uv')
  $env:UV_NO_CONFIG='1'
  $env:UV_NO_MODIFY_PATH='1'
  $env:UV_SYSTEM_PYTHON='false'
  $env:PYTORCH_CUDA_ALLOC_CONF='expandable_segments:True'
  $env:CUDA_MODULE_LOADING='LAZY'
  $env:PYTHONUTF8='1'
  $env:GRADIO_ANALYTICS_ENABLED='False'
}
function Ensure-Aria2 {
  if(Test-Path $Aria2Exe) {
    & $Aria2Exe '--version' 2>$null | Select-Object -First 1 | ForEach-Object { Log "  [aria2] $_" 'DarkGray' }
    if($LASTEXITCODE -eq 0){ return }
    Remove-Item $Aria2Dir -Recurse -Force -ErrorAction SilentlyContinue
    New-Item -ItemType Directory -Force -Path $Aria2Dir | Out-Null
  }
  Log '[1/8] Preparing portable aria2 1.37.0 (Windows x64)...' 'Yellow'
  $zip=Join-Path $Downloads 'aria2-1.37.0-win-64bit-build1.zip'
  Download-File @('https://github.com/aria2/aria2/releases/download/release-1.37.0/aria2-1.37.0-win-64bit-build1.zip') $zip '67d015301eef0b612191212d564c5bb0a14b5b9c4796b76454276a4d28d9b288' -Small
  $tmp=Join-Path $Runtime 'aria2_extract'
  Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
  New-Item -ItemType Directory -Force -Path $tmp | Out-Null
  Expand-Archive -LiteralPath $zip -DestinationPath $tmp -Force
  $src=Get-ChildItem $tmp -File -Recurse -Filter 'aria2c.exe' | Select-Object -First 1
  if(-not $src){Fail 'aria2 archive did not contain aria2c.exe.'}
  Copy-Item -LiteralPath $src.FullName -Destination $Aria2Exe -Force
  Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
  if(-not(Test-Path $Aria2Exe)){Fail 'Portable aria2 extraction failed.'}
  & $Aria2Exe '--version' 2>$null | Select-Object -First 1 | ForEach-Object { Log "  [aria2] $_" 'DarkGray' }
  if($LASTEXITCODE -ne 0){Fail 'Portable aria2.exe cannot execute.'}
}
function Ensure-UV {
  Set-Env
  if(Test-Path $UvExe){
    & $UvExe '--version' 2>$null | ForEach-Object { Log "  [uv] $_" 'DarkGray' }
    if($LASTEXITCODE -eq 0){ return }
    Remove-Item $UvExe -Force -ErrorAction SilentlyContinue
  }
  Log '[4/8] Preparing portable uv 0.12.23 (Windows x64)...' 'Yellow'
  $url1='https://releases.astral.sh/github/uv/releases/download/0.12.23/uv-x86_64-pc-windows-msvc.zip'
  $url2='https://github.com/astral-sh/uv/releases/download/0.12.23/uv-x86_64-pc-windows-msvc.zip'
  $zip=Join-Path $Downloads 'uv-0.12.23-x86_64-pc-windows-msvc.zip'
  Download-File @($url1,$url2) $zip '75d05de6762778c31ee183398de7dd15093fad0ed90b1f236d8205ea5ec00c90' -Small
  $tmp=Join-Path $Runtime 'uv_extract'
  Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
  New-Item -ItemType Directory -Force -Path $tmp | Out-Null
  Expand-Archive -LiteralPath $zip -DestinationPath $tmp -Force
  $src=Get-ChildItem $tmp -File -Recurse -Filter 'uv.exe' | Select-Object -First 1
  if(-not $src){Fail 'uv archive did not contain uv.exe.'}
  Copy-Item -LiteralPath $src.FullName -Destination $UvExe -Force
  Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
  if(-not(Test-Path $UvExe)){Fail 'Portable uv extraction failed.'}
  & $UvExe '--version' 2>$null | ForEach-Object { Log "  [uv] $_" 'DarkGray' }
  if($LASTEXITCODE -ne 0){Fail 'Portable uv.exe cannot execute.'}
}
function Invoke-UvPip([string[]]$NativeArgs,[string]$Cwd=$Root) {
  Set-Env
  $all=@('pip','install','--python',$PythonExe,'--no-python-downloads') + $NativeArgs
  Invoke-Native $UvExe $all $Cwd
}
function Get-BtbNFFmpegInfo {
  $ua='Wan2GP-RTX5060Ti-Portable/8.0'
  try {
    $rel=Invoke-RestMethod -Headers @{'User-Agent'=$ua} 'https://api.github.com/repos/BtbN/FFmpeg-Builds/releases/latest'
    $asset=$rel.assets | Where-Object {$_.name -match '^ffmpeg-n9\.0-latest-win64-gpl-shared-9\.0\.zip$'} | Select-Object -First 1
    if(-not $asset){ $asset=$rel.assets | Where-Object {$_.name -match '^ffmpeg-n9\.0-latest-win64-gpl-shared.*\.zip$'} | Select-Object -First 1 }
    $sum=$rel.assets | Where-Object {$_.name -eq 'checksums.sha256'} | Select-Object -First 1
    if($asset -and $sum){
      $sumFile=Join-Path $Downloads 'btbn-checksums.sha256'
      Download-File @($sum.browser_download_url) $sumFile -Small
      $escaped=[regex]::Escape($asset.name)
      $line=Get-Content -LiteralPath $sumFile | Where-Object {$_ -match "^\s*[0-9A-Fa-f]{64}\s+\*?$escaped\s*$"} | Select-Object -First 1
      if($line) {
        $parts=$line -split '\s+'
        $hash=$parts[0].Trim()
        return @{Url=$asset.browser_download_url;Sha256=$hash;Name=$asset.name;Tag=$rel.tag_name}
      }
    }
  } catch { Log "  BtbN release API lookup failed: $($_.Exception.Message)" 'Yellow' }
  # Known current fallback release checked on 2026-10-08.
  return @{Url='https://github.com/BtbN/FFmpeg-Builds/releases/download/autobuild-2026-10-05-13-07/ffmpeg-n9.0-latest-win64-gpl-shared-9.0.zip';Sha256='';Name='ffmpeg-n9.0-latest-win64-gpl-shared-9.0.zip';Tag='autobuild-2026-10-05-13-07'}
}
function Install-FFmpeg {
  $FFmpegExe=Join-Path $FFmpegDir 'bin\ffmpeg.exe'
  $FFprobeExe=Join-Path $FFmpegDir 'bin\ffprobe.exe'
  if((Test-Path $FFmpegExe) -and (Test-Path $FFprobeExe)) { return }
  Log '[6/8] Preparing portable FFmpeg (BtbN/GitHub; aria2 accelerated)...' 'Yellow'
  $info=Get-BtbNFFmpegInfo
  $zip=Join-Path $Downloads $info.Name
  if($info.Sha256){ Download-File @($info.Url) $zip $info.Sha256 } else { Download-File @($info.Url) $zip }
  $tmp=Join-Path $Runtime 'ffmpeg_extract'
  Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
  New-Item -ItemType Directory -Force -Path $tmp | Out-Null
  Expand-Archive -LiteralPath $zip -DestinationPath $tmp -Force
  $srcDir=Get-ChildItem $tmp -Directory -Recurse | Where-Object { (Test-Path (Join-Path $_.FullName 'bin\ffmpeg.exe')) -and (Test-Path (Join-Path $_.FullName 'bin\ffprobe.exe')) } | Select-Object -First 1
  if(-not $srcDir){Fail 'BtbN FFmpeg archive did not contain both bin\ffmpeg.exe and bin\ffprobe.exe.'}
  Remove-Item $FFmpegDir -Recurse -Force -ErrorAction SilentlyContinue
  New-Item -ItemType Directory -Force -Path $FFmpegDir | Out-Null
  Copy-Item (Join-Path $srcDir.FullName 'bin') $FFmpegDir -Recurse -Force
  if(Test-Path (Join-Path $srcDir.FullName 'LICENSE.txt')){Copy-Item (Join-Path $srcDir.FullName 'LICENSE.txt') $FFmpegDir -Force}
  Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
  if(-not(Test-Path $FFmpegExe) -or -not(Test-Path $FFprobeExe)){Fail 'Portable FFmpeg installation failed.'}
  Log "  FFmpeg source: BtbN/$($info.Tag)" 'DarkGray'
  & $FFmpegExe '-hide_banner' '-version' 2>$null | Select-Object -First 1 | ForEach-Object { Log "  [ffmpeg] $_" 'DarkGray' }
  & $FFprobeExe '-hide_banner' '-version' 2>$null | Select-Object -First 1 | ForEach-Object { Log "  [ffprobe] $_" 'DarkGray' }
}

Log '============================================================' 'Cyan'
Log ' Wan2GP RTX 5060 Ti 16GB Portable Setup v8' 'Cyan'
Log ' No Miniconda / No system Python / No permanent PATH changes' 'Cyan'
Log ' uv-managed dependencies + aria2 segmented downloads' 'Cyan'
Log '============================================================' 'Cyan'
if(-not [Environment]::Is64BitOperatingSystem){Fail '64-bit Windows is required.'}

$nvsmi=Get-Command nvidia-smi.exe -ErrorAction SilentlyContinue
$gpuName=''
if($nvsmi){try{$gpuName=(& $nvsmi.Source '--query-gpu=name' '--format=csv,noheader'|Select-Object -First 1).Trim();Log "Detected GPU: $gpuName" 'Green'}catch{Log 'Could not query NVIDIA GPU with nvidia-smi.' 'Yellow'}}

Ensure-Aria2

$GitExe=Join-Path $GitDir 'cmd\git.exe'
$GitZip=Join-Path $Downloads 'MinGit-2.56.0.2-64-bit.zip'
if(-not(Test-Path $GitExe)){
  Log '[2/8] Preparing portable Git (MinGit 2.56.0.2 x64)...' 'Yellow'
  Download-File @('https://github.com/git-for-windows/git-snapshots/releases/download/2.56.0.2/MinGit-2.56.0.2-64-bit.zip') $GitZip 'ab2543fea7eebdc8476b63af2ff8acec10fce72fc9f72a40c9123df94c6ac1ae'
  Remove-Item $GitDir -Recurse -Force -ErrorAction SilentlyContinue
  Expand-Archive -LiteralPath $GitZip -DestinationPath $GitDir -Force
  if(-not(Test-Path $GitExe)){$inner=Get-ChildItem $GitDir -Directory|Select-Object -First 1;if($inner -and(Test-Path(Join-Path $inner.FullName 'cmd\git.exe'))){Get-ChildItem $inner.FullName|Move-Item -Destination $GitDir -Force;Remove-Item $inner.FullName -Recurse -Force}}
  if(-not(Test-Path $GitExe)){Fail 'Portable Git extraction did not produce cmd\git.exe.'}
}else{Log '[2/8] Portable Git already ready.' 'Green'}
Set-Env

$PythonExe=Join-Path $PythonDir 'python.exe'
if(-not(Test-Path $PythonExe)){
  Log '[3/8] Preparing portable CPython 3.11.14...' 'Yellow'
  $pbs='https://github.com/astral-sh/python-build-standalone/releases/download/20251031/cpython-3.11.14%2B20251031-x86_64-pc-windows-msvc-install_only.tar.gz'
  $pyArchive=Join-Path $Downloads 'cpython-3.11.14+20251031-x86_64-pc-windows-msvc-install_only.tar.gz'
  try{$api=Invoke-RestMethod -Headers @{'User-Agent'='Wan2GP-RTX5060Ti-Portable/8.0'} 'https://api.github.com/repos/astral-sh/python-build-standalone/releases/tags/20251031';$asset=$api.assets|Where-Object{$_.name -eq 'cpython-3.11.14+20251031-x86_64-pc-windows-msvc-install_only.tar.gz'}|Select-Object -First 1;if(-not $asset){Fail 'Could not find the pinned CPython 3.11.14 Windows x64 asset.'};$digest='';if($asset.digest -match 'sha256:(.+)'){$digest=$Matches[1]}}catch{Fail "Unable to query the pinned CPython release metadata: $($_.Exception.Message)"}
  Download-File @($pbs) $pyArchive $digest
  $tmp=Join-Path $Runtime 'py_extract';Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue;New-Item -ItemType Directory -Force -Path $tmp|Out-Null
  tar.exe -xzf $pyArchive -C $tmp;if($LASTEXITCODE -ne 0){Fail 'CPython archive extraction failed.'}
  $src=Join-Path $tmp 'python';if(-not(Test-Path(Join-Path $src 'python.exe'))){$src=Get-ChildItem $tmp -Directory -Recurse|Where-Object{Test-Path(Join-Path $_.FullName 'python.exe')}|Select-Object -First 1 -ExpandProperty FullName};if(-not$src){Fail 'Could not locate python.exe after CPython extraction.'}
  Remove-Item $PythonDir -Recurse -Force -ErrorAction SilentlyContinue;Move-Item $src $PythonDir;Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue;if(-not(Test-Path $PythonExe)){Fail 'Portable CPython installation failed.'}
}else{Log '[3/8] Portable CPython already ready.' 'Green'}
Set-Env

Ensure-UV

Log '[5/8] Verifying portable Python + pip...' 'Yellow'
function Test-PortablePython {
  $stdout=Join-Path $LogsDir 'python_test.stdout.txt';$stderr=Join-Path $LogsDir 'python_test.stderr.txt';$testScript=Join-Path $LogsDir 'python_test.py';Remove-Item $stdout,$stderr -Force -ErrorAction SilentlyContinue
  @'
import sys
print("Python", sys.version)
print("Executable", sys.executable)
print("Platform", sys.platform)
'@|Set-Content -LiteralPath $testScript -Encoding UTF8
  & $PythonExe -E -s $testScript 1>$stdout 2>$stderr;$rc=[int]$LASTEXITCODE
  if(Test-Path $stdout){Get-Content $stdout|ForEach-Object{Log("  [python] "+$_) 'DarkGray'}}
  if(Test-Path $stderr){Get-Content $stderr|ForEach-Object{Log("  [python:stderr] "+$_) 'Yellow'}}
  return $rc
}
$pyRc=Test-PortablePython
if($pyRc -ne 0){
  $pyHex=('0x{0:X8}'-f([uint32]$pyRc));Log "  Python startup failed: exit code $pyRc ($pyHex). Applying automatic Microsoft VC++ runtime repair and retrying..." 'Yellow'
  Download-File @('https://aka.ms/vc14/vc_redist.x64.exe') $VCRedistExe
  Log '  Installing/updating Microsoft Visual C++ v14 x64 runtime silently...' 'Yellow'
  $vc=Start-Process -FilePath $VCRedistExe -ArgumentList @('/install','/quiet','/norestart') -Wait -PassThru -NoNewWindow
  Log "  VC++ redistributable exit code: $($vc.ExitCode)" 'DarkGray'
  if($vc.ExitCode -notin @(0,3010,1638)){Fail "Microsoft Visual C++ runtime repair failed with exit code $($vc.ExitCode)."}
  $pyRc=Test-PortablePython
  if($pyRc -ne 0){$pyHex=('0x{0:X8}'-f([uint32]$pyRc));Fail "Portable Python cannot execute even after VC++ runtime repair. Exit code: $pyRc ($pyHex). See python_test.stderr.txt and installer.log."}
}
& $PythonExe -E -s -m pip --version 1>$null 2>&1;$pipRc=[int]$LASTEXITCODE
if($pipRc -ne 0){
  Log '  pip missing; downloading official get-pip.py and bootstrapping automatically...' 'Yellow'
  $gp=Join-Path $Downloads 'get-pip.py';Download-File @('https://bootstrap.pypa.io/get-pip.py') $gp -Small;Invoke-Native $PythonExe @('-E','-s',$gp,'--no-warn-script-location') $Root
}

Install-FFmpeg
Set-Env

$WanEntry=Join-Path $WanDir 'wgp.py'
if(-not(Test-Path $WanEntry)){
  Log '[7/8] Downloading latest Wan2GP main branch...' 'Yellow'
  Remove-Item $WanDir -Recurse -Force -ErrorAction SilentlyContinue
  Invoke-Native $GitExe @('clone','--depth','1','--single-branch','--branch','main','https://github.com/deepbeepmeep/Wan2GP.git',$WanDir) $Root
  if(-not(Test-Path $WanEntry)){Fail 'Wan2GP clone completed but wgp.py is missing.'}
}else{Log '[7/8] Wan2GP source already present.' 'Green'}

Set-Env
$pkgMarker=Join-Path $Root '.python_stack_ready'
$NeedStack=$true
if(Test-Path $pkgMarker){
  try{
    $check=@'
import torch,sys
ok=(torch.__version__.startswith("2.10.0") and torch.version.cuda=="13.0")
print(ok)
sys.exit(0 if ok else 1)
'@
    & $PythonExe -E -s -c $check 1>$null 2>&1
    if($LASTEXITCODE -eq 0){$NeedStack=$false}
  }catch{}
}
if($NeedStack){
  Log '[8/8] Installing RTX 50-series stack with portable uv...' 'Yellow'
  Invoke-UvPip @('torch==2.10.0','torchvision==0.25.0','torchaudio==2.10.0','--index-url','https://download.pytorch.org/whl/cu130') $WanDir
  Log '  Installing Wan2GP requirements with uv...' 'Yellow'
  Invoke-UvPip @('-r',(Join-Path $WanDir 'requirements.txt')) $WanDir
  Log '  Installing Triton 3.6.x with uv...' 'Yellow'
  Invoke-UvPip @('triton-windows>=3.6,<3.7') $WanDir
  Log '  Installing SageAttention 2.2.0 post4 with uv...' 'Yellow'
  $sage='https://github.com/woct0rdho/SageAttention/releases/download/v2.2.0-windows.post4/sageattention-2.2.0+cu130torch2.9.0andhigher.post4-cp39-abi3-win_amd64.whl'
  Invoke-UvPip @($sage) $WanDir
  Set-Content -LiteralPath $pkgMarker -Value (Get-Date -Format o) -Encoding UTF8
}else{Log '[8/8] RTX Python stack already verified.' 'Green'}

Log 'Verifying GPU / CUDA / Sage2 / FFmpeg / Wan2GP...' 'Yellow'
Set-Env
$verify=@'
import json,sys,subprocess,os
out={"python":sys.version.split()[0]}
try:
 import torch
 out.update({"torch":torch.__version__,"cuda":torch.version.cuda,"cuda_available":torch.cuda.is_available()})
 if torch.cuda.is_available():
  p=torch.cuda.get_device_properties(0);out.update({"gpu":torch.cuda.get_device_name(0),"vram_gb":round(p.total_memory/1024**3,2),"capability":f"{p.major}.{p.minor}"})
except Exception as e: out["torch_error"]=str(e)
try:
 import triton;out["triton"]=getattr(triton,'__version__','unknown')
except Exception as e: out["triton_error"]=str(e)
try:
 import sageattention;out["sageattention"]='OK'
except Exception as e: out["sageattention_error"]=str(e)
print(json.dumps(out))
'@
$verifyOut=& $PythonExe -E -s -c $verify
if($LASTEXITCODE -ne 0){Fail 'Python verification process failed.'}
Log "  $verifyOut" 'Gray'
if($verifyOut -notmatch '"cuda_available": true'){Fail 'CUDA is not available in PyTorch. Update the NVIDIA driver and rerun INSTALL_OR_REPAIR.bat.'}
$FFmpegExe=Join-Path $FFmpegDir 'bin\ffmpeg.exe';$FFprobeExe=Join-Path $FFmpegDir 'bin\ffprobe.exe'
if(-not(Test-Path $FFmpegExe) -or -not(Test-Path $FFprobeExe)){Fail 'FFmpeg/ffprobe verification failed.'}
& $FFmpegExe '-hide_banner' '-version' 2>$null | Select-Object -First 1 | ForEach-Object { Log "  $_" 'DarkGray' }
& $FFprobeExe '-hide_banner' '-version' 2>$null | Select-Object -First 1 | ForEach-Object { Log "  $_" 'DarkGray' }

$cfg=Join-Path $ConfigDir 'wgp_config.json'
if(-not(Test-Path $cfg)){
  @{attention_mode='sage2';transformer_quantization='int8';text_encoder_quantization='int8';save_path=(Join-Path $Root 'outputs');image_save_path=(Join-Path $Root 'outputs');audio_save_path=(Join-Path $Root 'outputs');profile=4;video_profile=4;image_profile=4;audio_profile=3.5;int8_kernels='auto';kernel_precision='fast'}|ConvertTo-Json|Set-Content -LiteralPath $cfg -Encoding UTF8
}

$record=[ordered]@{installed=(Get-Date -Format o);target_gpu='NVIDIA GeForce RTX 5060 Ti 16GB';python='3.11.14';uv='0.12.23';pytorch='2.10.0+cu130';torchvision='0.25.0';torchaudio='2.10.0';triton='3.6.x';sageattention='2.2.0 post4';git='MinGit 2.56.0.2';aria2='1.37.0';ffmpeg='BtbN n9.0 latest win64 gpl shared';gpu_detected=$gpuName};$record|ConvertTo-Json|Set-Content -LiteralPath $Marker -Encoding UTF8

if(-not $InstallOnly){& (Join-Path $PSScriptRoot 'launch.ps1');exit $LASTEXITCODE}
Log 'Installation completed successfully.' 'Green';exit 0
