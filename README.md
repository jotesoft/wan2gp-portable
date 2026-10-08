# Wan2GP-RTX50xx-Portable installer

Portable Windows Wan2GP package aimed at NVIDIA RTX 50-series GPUs, especially the RTX 5060 Ti 16GB and other RTX 50-series / Blackwell GPU. But it will work with RTX 20xx , 30xx, 40xx GPUs

## How to install

--->clone the repo or download repo as zip file or download from release.

---->Extract the zip file anywhere you one

----->run install_wan2gp.bat

------>it will now automatically download all the required files to run the latest version on wan2gp so wait until finish the download.

-------> run START_WAN2GP_5060Ti.bat or START_WAN2GP.bat or START_WAN2GP_LAN.bat to start wan2gp webui.

there many different bonus .bat file to run in different mode us them.

Important note: 
if you see any error (e.g [2026-10-08 22:44:51] [ERROR] Python verification process failed.) at the end don't worry you installation is complete. now just run START_WAN2GP.bat it will work.

## Features

* Portable Python 3.11
* Portable Git
* Portable uv
* Bundled FFmpeg / FFprobe
* Wan2GP source included locally
* PyTorch 2.10.0 + CUDA 13.0
* Triton 3.6.0
* SageAttention 2.2.0 Windows build
* No Miniconda required
* No system Python required
* No permanent PATH modification
* Can be placed under Stability Matrix `Data\\Packages`
* LAN/Gradio launchers
* Installation verification launcher

## Target GPUs

Primary target:

* RTX 5060 Ti 16GB ( Build/Test device)

Also intended for other RTX 50-series / Blackwell GPUs:

* RTX 5090
* RTX 5080
* RTX 5070 Ti
* RTX 5070
* RTX 5060 Ti
* RTX 5060

Other NVIDIA GPUs may work depending on architecture, driver, CUDA/PyTorch compatibility, VRAM, Triton and SageAttention support. The package is not hard-locked to the RTX 5060 Ti.

## Software Stack

|Component|Version|
|-|-|
|Python|3.11.14|
|pip|25.3|
|PyTorch|2.10.0 + cu130|
|torchvision|0.25.0 + cu130|
|torchaudio|2.10.0 + cu130|
|Triton|3.6.0|
|SageAttention|2.2.0 Windows post4|
|uv|0.12.23|
|MinGit|2.56.0.2|
|Wan2GP|Installed source|
|FFmpeg|BtbN Windows build|

> Keep the tested dependency versions unless there is a specific reason to change them.

## Requirements

### Hardware

Recommended:

* NVIDIA RTX 50-series GPU
* 16GB VRAM is ideal for the RTX 5060 Ti configuration
* 32GB system RAM recommended
* SSD recommended

### Software

* Windows 10/11 64-bit
* Suitable current NVIDIA driver
* Internet for initial installation, models and plugins

No Miniconda, Anaconda, system Python or permanent PATH configuration is required.

## Typical Folder Layout

```text
Wan2GP-RTX50xx-Portable/
├─ runtime/
│  └─ Python311/
│     └─ python.exe
├─ git/
├─ uv/
├─ ffmpeg/
│  └─ bin/
│     ├─ ffmpeg.exe
│     └─ ffprobe.exe
├─ Wan2GP/
│  ├─ wgp.py
│  └─ ...
├─ START\_WAN2GP\_5060Ti.bat
├─ START\_WAN2GP\_GRADIO\_URL.bat
├─ START\_WAN2GP\_LAN.bat
├─ START\_WAN2GP\_DEEPY\_LAN.bat
├─ VERIFY\_WAN2GP\_5060Ti.bat
└─ WAN2GP\_MENU.bat
```

Exact filenames can vary between releases.

## Launching Wan2GP

### Main Menu

Run:

```text
WAN2GP\_MENU.bat
```

Use this as the central launcher for the available Wan2GP functions.

### Normal Launch

Run:

```text
START\_WAN2GP\_5060Ti.bat
```

This starts Wan2GP using the bundled Python runtime.

### Gradio / LAN

Run:

```text
START\_WAN2GP\_GRADIO\_URL.bat
```

or:

```text
START\_WAN2GP\_LAN.bat
```

The LAN launcher binds the server for access from other devices on the same local network.

Typical addresses:

```text
Local:
http://127.0.0.1:7860/

LAN:
http://YOUR-PC-IP:7860/
```

Example:

```text
http://192.168.0.100:7860/
```

Use the PC's actual LAN IP from another computer, phone or tablet. Do not type `0.0.0.0` into the client browser.

### Deepy Web

Run:

```text
START\_WAN2GP\_DEEPY\_LAN.bat
```

Typical address:

```text
http://YOUR-PC-IP:7860/deepy/
```

The LAN launchers use local binding and do not use Gradio's public `--share` tunnel.

## Windows Firewall

Windows Firewall may block LAN access even when Wan2GP works locally.

Typical symptom:

* `127.0.0.1:7860` works on the Wan2GP PC
* another device cannot open `PC-IP:7860`

Use the firewall option supplied by the launcher when necessary. Prefer a Private-network rule and only open the required local port.

Do not expose the Gradio server directly to the public Internet.

## Verification

Run:

```text
VERIFY\_WAN2GP\_5060Ti.bat
```

A healthy installation should verify Python, PyTorch, torchvision, torchaudio, Triton, SageAttention, CUDA, GPU detection, CUDA tensor operation, FFmpeg, FFprobe and the Wan2GP source.

The tested RTX 5060 Ti environment reached:

```text
Passed: 15
Failed: 0
RESULT: INSTALLATION OK
```

Fix the specific failed component before attempting a full reinstall.

## Pip Update Notice

You may see:

```text
\[notice] A new release of pip is available:
25.3 -> 26.2.1
```

This is normally only an informational notice, not an installation failure.

The tested v8 environment uses pip 25.3. Do not upgrade pip merely because the notice appears.

The same notice can appear while installing Wan2GP plugins. Look for an actual `ERROR:`, `Failed`, or `ResolutionImpossible` message to determine whether the plugin installation really failed.

## Plugins

Plugins may download additional Python packages and assets.

Plugin downloads are extra storage and network usage beyond the base package.

The bundled Python environment already contains pip and uv for package management. Avoid unnecessary upgrades of the core environment just to remove pip's update notice.

## Models and Storage

Models are separate from the Python environment and can require many additional gigabytes.

Plan space for:

* Wan2GP models
* VAEs and text encoders
* LoRAs
* Plugin assets
* Generated images and videos

The size of the portable Python package is not the total storage requirement for Wan2GP.

## Moving the Installation

Copy the entire portable folder together.

Example:

```text
Stability\_Matrix/
└─ Data/
   └─ Packages/
      └─ Wan2GP-RTX50xx-Portable/
```

Do not move only the `Wan2GP` source folder and leave the portable runtime behind.

## GPU Compatibility

The package is named **RTX50xx** because the primary target is the NVIDIA RTX 50-series / Blackwell generation. It is **not hard-coded to the RTX 5060 Ti**.

The bundled PyTorch 2.10.0 + CUDA 13.0 environment is intended for modern NVIDIA GPUs. Actual Wan2GP performance and individual acceleration features still depend on GPU architecture, VRAM, NVIDIA driver, Triton and SageAttention compatibility.

### Recommended / Supported GPU Families

|GPU family|Examples|Status with this package|
|-|-|-|
|**RTX 50-series / Blackwell**|RTX 5090, 5080, 5070 Ti, 5070, 5060 Ti, 5060|**Recommended / primary target**|
|**RTX 40-series / Ada**|RTX 4090, 4080, 4070 Ti, 4070, 4060 Ti, 4060|**Supported / recommended**|
|**RTX 30-series / Ampere**|RTX 3090 Ti, 3090, 3080, 3070 Ti, 3070, 3060 Ti, 3060|**Supported**|
|**RTX 20-series / Turing**|RTX 2080 Ti, 2080, 2070, 2060|**Supported; VRAM/performance dependent**|
|**GTX 16-series / Turing**|GTX 1660 Ti, 1660 Super, 1650|**May work; limited by VRAM/workload**|
|**Turing workstation / data-center**|T4 and similar SM 7.5 GPUs|**CUDA-compatible; not the primary Windows target**|
|**Hopper**|H100, H200 and related SM 9.0 GPUs|**CUDA-compatible; not the intended consumer configuration**|

NVIDIA's current CUDA documentation lists Turing (SM 7.5), Ampere (SM 8.x), Ada (SM 8.9), Hopper (SM 9.0) and Blackwell (SM 10.x/12.x families) in current CUDA toolchains.

### Older NVIDIA GPUs

This package uses a **CUDA 13.0** PyTorch environment. Older Pascal and Volta GPUs should **not** be treated as compatible with this exact build. NVIDIA's current CUDA architecture matrix lists Pascal and Volta as ending with CUDA 12.x support, while CUDA 13 targets Turing and newer architectures.

|Older family|Examples|Status|
|-|-|-|
|**Volta**|Titan V, V100|**Use a CUDA 12.x-based environment instead**|
|**Pascal**|GTX 1080 Ti, GTX 1080, GTX 1070, GTX 1060, P100|**Use a CUDA 12.x-based environment instead**|
|**Maxwell and older**|GTX 980 Ti, GTX 970 and older|**Not supported by this package**|
|**Kepler and older**|GTX 780, GTX 770 and older|**Not supported by this package**|

This does **not** mean Wan2GP can never run on older cards. It means they need a different Python/PyTorch/CUDA package rather than this RTX50xx portable environment.

### VRAM Considerations

Architecture support does not guarantee that a particular Wan2GP workflow will fit in VRAM. As a practical guide:

|VRAM|Expectation|
|-:|-|
|4 GB|Very limited; many modern workflows will not fit|
|6 GB|Limited; aggressive memory saving likely|
|8 GB|Usable for lighter workflows|
|12 GB|Good starting point|
|**16 GB**|**Excellent for the RTX 5060 Ti configuration**|
|24 GB+|Excellent headroom for larger workflows|

These are practical guidelines rather than hard minimums; individual models and settings can require significantly different amounts of VRAM.

### How to Test Another NVIDIA GPU

For a different NVIDIA GPU:

1. Run the verification BAT.
2. Confirm **CUDA available**.
3. Confirm **GPU detected**.
4. Confirm **CUDA tensor operation**.
5. Run a small Wan2GP generation.
6. Reduce resolution, frame count, batch size or enable memory-saving options when VRAM is limited.

The verifier detects the installed GPU rather than assuming it is an RTX 5060 Ti.

### Triton / SageAttention

The portable environment includes Triton and SageAttention because they are part of the tested RTX 50-series configuration. On another NVIDIA architecture, Wan2GP may work even when one accelerated kernel does not. If SageAttention or another optimization fails, test with that optimization disabled before replacing the entire environment.

### NVIDIA References

CUDA Compiler / GPU architecture documentation:
https://docs.nvidia.com/cuda/cuda-compiler-driver-nvcc/

CUDA Toolkit, Driver and Architecture Matrix:
https://docs.nvidia.com/datacenter/tesla/drivers/latest/cuda-toolkit-driver-and-architecture-matrix.html

PyTorch 2.10.0 previous versions / CUDA 13.0 wheels:
https://pytorch.org/get-started/previous-versions/

## Performance

Generation speed is primarily affected by:

* GPU model and clocks
* VRAM
* CUDA/PyTorch build
* Triton
* SageAttention
* Resolution
* Frame count
* Steps
* Model
* CPU/RAM
* Storage speed

Upgrading pip should not be expected to increase Wan2GP generation speed.

## Troubleshooting

### Wan2GP does not start

Run:

```text
VERIFY\_WAN2GP\_5060Ti.bat
```

Check the first failed component.

### CUDA unavailable

Check:

* NVIDIA driver
* GPU detection
* PyTorch CUDA test
* The portable Python executable being used

### LAN access fails

First test:

```text
http://127.0.0.1:7860/
```

If local access works but another device cannot connect, check Windows Firewall and confirm both devices are on the same network.

### Plugin installation shows a pip update notice

Ignore the notice unless an actual package installation error follows it.

## Design Goals

This portable distribution is designed to remain:

```text
Portable
Self-contained
Reproducible
GPU-aware
Easy to launch
Easy to verify
Easy to move
```

The preferred approach is to preserve a known-good environment instead of repeatedly upgrading core dependencies without a specific need.

## Credits

Wan2GP: https://github.com/deepbeepmeep/Wan2GP

PyTorch: https://pytorch.org/

Triton: https://github.com/triton-lang/triton

SageAttention: https://github.com/woct0rdho/SageAttention

uv: https://github.com/astral-sh/uv

Git for Windows: https://gitforwindows.org/

FFmpeg: https://ffmpeg.org/

