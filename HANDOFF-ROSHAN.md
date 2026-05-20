# Handoff — Indigenomics AI custom notebook image (v0.1)

**Date:** 2026-05-13
**For:** Roshan (TELUS AI Factory)
**Pattern:** Apr 27 sync — public image stitched into Indigenomics custom service profile

## Image (live now)

**Primary — Docker Hub (per Roshan 2026-05-14):**

```
docker.io/gaiaai/iai-conversational-models:latest
docker.io/gaiaai/iai-conversational-models:v0.1
docker.io/gaiaai/iai-conversational-models:20260513
```

**Mirror — GHCR:**

```
ghcr.io/linuxiscool/iai-conversational-models:latest
ghcr.io/linuxiscool/iai-conversational-models:v0.1
ghcr.io/linuxiscool/iai-conversational-models:20260513
```

Manifest sha: `sha256:40f11432a18ece7ae8635d80dd00d91b165b2c5a355036479eebc265ffff7f40` (identical across both registries)

Pull (anonymous, public):

```bash
docker pull docker.io/gaiaai/iai-conversational-models:latest
# or
docker pull ghcr.io/linuxiscool/iai-conversational-models:latest
```

## Source repository

https://github.com/LinuxIsCool/iai-conversational-models

Public repo. Dockerfile, examples, scripts, changelog, CI all visible.

CI: `.github/workflows/build-push.yml` rebuilds on every push to main →
auto-tags `:latest`, `:YYYYMMDD`, `:sha-<sha>` + optional manual tag.

Nightly anonymous-pull regression smoke at 03:00 PDT.

## What is in v0.1

Built on `pytorch/pytorch:2.5.1-cuda12.4-cudnn9-devel` (Docker Hub public,
swap to `nvcr.io/nvidia/pytorch` on your side if preferred — layer stack
above is portable).

| Layer | Versions |
|---|---|
| Base | PyTorch 2.5.1 + CUDA 12.4 + cuDNN 9 + Python 3.11 + Ubuntu 22.04 |
| System | ffmpeg, libsndfile1, sox, libsox-fmt-all, git-lfs, jq |
| ASR | faster-whisper >=1.0.3, openai-whisper |
| Riva | nvidia-riva-client >=2.16.0 |
| HF / LLM | transformers >=4.45, huggingface_hub, accelerate |
| Web | fastapi, uvicorn[standard], gradio, httpx, openai |
| Jupyter | jupyterlab >=4.2, ipywidgets, jupyterlab-git |

## v0.2 plan (next push, this week)

Deferred from v0.1 due to local build constraints (now resolved):

| Add | For |
|---|---|
| `nemo_toolkit[asr]>=2.0` | `nvidia/parakeet-tdt-1.1b-v2` (top open ASR), `nvidia/canary-1b` (multilingual + translation) |
| `git+https://github.com/NVIDIA/personaplex@main` | Full-duplex conversational AI (`nvidia/personaplex-7b-v1`) |

## Seed notebooks shipped (`/workspace/examples/`)

1. `01-whisper-turbo.ipynb` — faster-whisper large-v3-turbo, file → transcript
2. `02-parakeet.ipynb` — placeholder (NeMo lib lands in v0.2)
3. `03-canary.ipynb` — placeholder (NeMo lib lands in v0.2)
4. `04-riva-client.ipynb` — Riva ASR + TTS client, talks to deployed Riva server (set `RIVA_URI` env)
5. `05-personaplex.ipynb` — placeholder (PersonaPlex lib lands in v0.2)

Weights NOT baked into image. Each notebook pulls from HuggingFace Hub at runtime.

## Built-in diagnostic

```bash
docker run --rm --gpus all ghcr.io/linuxiscool/iai-conversational-models:latest iai-doctor
```

Reports: GPU presence, CUDA/PyTorch versions, installed model libs,
endpoint hints. Runs automatically on container start.

## Container ports

| Port | Service |
|---|---|
| 8888 | JupyterLab (default CMD) |
| 8000 | FastAPI template for model endpoints |
| 7860 | Gradio demo |

## Iteration loop (what we agreed Apr 27)

```
Indigenomics edit → git push → GH Actions buildx push → ghcr.io:latest updated
  → TELUS profile redeploy picks up latest → notebook spawns with new image
```

End-to-end: <20 min for a notebook-only change, <30 min for a new pip dep.

When changes needed: edit the Dockerfile or notebooks, commit + push,
Roshan redeploys the profile when ready. No manual handshake unless the
change is breaking.

## Provenance

- 2026-04-27 sync: Roshan proved the pattern via `roshanrajx64/pytorch-ffmpeg-notebook`
- 2026-05-13: First Indigenomics image built ahead of Wed Roshan sync
- Image maintained by Indigenomics AI
