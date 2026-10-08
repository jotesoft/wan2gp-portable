from __future__ import annotations
import importlib
import os
import platform
import subprocess
import sys
import traceback
from pathlib import Path

ROOT = Path(__file__).resolve().parent
PYTHON = ROOT / 'runtime' / 'Python311' / 'python.exe'
FFMPEG = ROOT / 'runtime' / 'ffmpeg' / 'bin' / 'ffmpeg.exe'
FFPROBE = ROOT / 'runtime' / 'ffmpeg' / 'bin' / 'ffprobe.exe'
WAN = ROOT / 'Wan2GP'

fails = []
passes = []

def ok(label, detail=''):
    passes.append(label)
    print(f'[PASS] {label}' + (f' - {detail}' if detail else ''))

def fail(label, exc=None, detail=''):
    fails.append(label)
    print(f'[FAIL] {label}' + (f' - {detail}' if detail else ''))
    if exc is not None:
        print(f'       {type(exc).__name__}: {exc}')

print('=' * 72)
print(' Wan2GP RTX 5060 Ti Portable - FINAL VERIFICATION (v8 repair)')
print('=' * 72)
print(f'Root: {ROOT}')
print()

# Python executable sanity
try:
    if Path(sys.executable).resolve() != PYTHON.resolve():
        # This verifier may be started by the included Python executable; otherwise we can
        # still verify the interpreter identity below.
        print(f'[INFO] Verifier executable: {sys.executable}')
    if sys.version_info[:2] == (3, 11):
        ok('Python 3.11', platform.python_version())
    else:
        fail('Python 3.11', detail=platform.python_version())
except Exception as e:
    fail('Python', e)

# Core Python packages
for label, modname in [
    ('PyTorch', 'torch'),
    ('torchvision', 'torchvision'),
    ('torchaudio', 'torchaudio'),
    ('Triton', 'triton'),
    ('SageAttention', 'sageattention'),
]:
    try:
        m = importlib.import_module(modname)
        ver = getattr(m, '__version__', 'installed')
        ok(label, str(ver))
    except Exception as e:
        fail(label, e)
        if label == 'SageAttention':
            # The traceback is especially valuable for binary/ABI failures.
            traceback.print_exc()

# PyTorch CUDA / GPU checks
try:
    import torch
    ok('PyTorch import', torch.__version__)
    cuda_ver = getattr(torch.version, 'cuda', None)
    if cuda_ver:
        ok('PyTorch CUDA runtime', str(cuda_ver))
    else:
        fail('PyTorch CUDA runtime', detail='torch.version.cuda is None')

    if torch.cuda.is_available():
        ok('CUDA available')
        try:
            n = torch.cuda.device_count()
            if n < 1:
                fail('CUDA device count', detail='0')
            else:
                name = torch.cuda.get_device_name(0)
                cc = torch.cuda.get_device_capability(0)
                ok('GPU detected', name)
                ok('Compute capability', f'{cc[0]}.{cc[1]}')
                # Basic device operation catches lazy driver/runtime failures.
                x = torch.ones((8, 8), device='cuda', dtype=torch.float32)
                y = x @ x
                torch.cuda.synchronize()
                if float(y[0, 0].item()) == 8.0:
                    ok('CUDA tensor operation')
                else:
                    fail('CUDA tensor operation', detail=f'unexpected result {y[0,0].item()}')
        except Exception as e:
            fail('CUDA device test', e)
            traceback.print_exc()
    else:
        fail('CUDA available', detail='torch.cuda.is_available() returned False')
except Exception as e:
    fail('PyTorch CUDA verification', e)
    traceback.print_exc()

# FFmpeg checks
for label, exe in [('FFmpeg', FFMPEG), ('FFprobe', FFPROBE)]:
    try:
        if not exe.exists():
            fail(label, detail=f'not found: {exe}')
        else:
            p = subprocess.run([str(exe), '-version'], capture_output=True, text=True, timeout=20)
            if p.returncode == 0:
                first = (p.stdout or p.stderr).splitlines()[0] if (p.stdout or p.stderr) else 'OK'
                ok(label, first)
            else:
                fail(label, detail=f'process exit {p.returncode}: {(p.stderr or p.stdout).strip()[:300]}')
    except Exception as e:
        fail(label, e)

# Wan2GP source tree checks; don't import the whole application because it can pull optional
# dependencies and produce false negatives unrelated to the installed runtime stack.
try:
    if not WAN.is_dir():
        fail('Wan2GP source', detail=f'not found: {WAN}')
    else:
        required = ['wgp.py', 'requirements.txt']
        missing = [x for x in required if not (WAN / x).exists()]
        if missing:
            fail('Wan2GP source', detail='missing: ' + ', '.join(missing))
        else:
            ok('Wan2GP source', f'{WAN}')
except Exception as e:
    fail('Wan2GP source', e)

print()
print('=' * 72)
print(f' Passed: {len(passes)}    Failed: {len(fails)}')
if fails:
    print(' RESULT: INSTALLATION NEEDS ATTENTION')
    print(' Failed checks: ' + ', '.join(fails))
    print('=' * 72)
    sys.exit(1)
else:
    print(' RESULT: INSTALLATION OK')
    print('=' * 72)
    sys.exit(0)
