Wan2GP RTX 5060 Ti Portable v8
================================

Target: NVIDIA GeForce RTX 5060 Ti 16GB (Blackwell / SM120)

This bundle uses a private runtime folder and makes no permanent PATH or Python/Conda configuration changes.

Target software stack:
- CPython 3.11.14 (python-build-standalone, Windows x64)
- uv 0.12.12 (Windows x64, isolated under runtime\uv)
- PyTorch 2.10.0 + CUDA 13.0
- torchvision 0.25.0
- torchaudio 2.10.0
- triton-windows 3.6.x
- SageAttention 2.2.0 post4
- MinGit 2.56.0.2 x64
- FFmpeg (portable, private)

IMPORTANT v7 changes
- Adds uv 0.12.12 as the dependency manager.
- uv is downloaded from Astral's signed Windows x64 release archive, SHA-256 verified, and extracted to runtime\uv\uv.exe.
- All Python package installation is performed by that local uv against the bundled CPython interpreter.
- uv is isolated with UV_NO_CONFIG and a local UV_CACHE_DIR.
- uv is forbidden from downloading another Python (uses --no-python-downloads).
- Clears inherited PYTHONHOME/PYTHONPATH/VIRTUAL_ENV/Conda variables.
- Keeps the working RTX 50-series PyTorch/Triton/Sage2 configuration.
- No Miniconda, no system Python requirement, no permanent PATH edits.

FIRST RUN
1. Extract this ZIP.
2. Run START_WAN2GP_5060Ti.bat.
3. Everything else is automatic. Internet is required for first setup and model downloads.

The build environment used to produce this ZIP cannot embed Microsoft's/third-party Windows binary payloads directly. Therefore the bootstrap downloads the exact pinned uv/Git/Python payloads automatically. After first setup, runtime\uv\uv.exe physically exists inside the package and is included by BUILD_OFFLINE_BUNDLE.bat.

For a fully populated portable copy, run BUILD_OFFLINE_BUNDLE.bat after installation completes.
