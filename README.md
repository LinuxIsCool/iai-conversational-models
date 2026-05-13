# IAI Conversational Models

Custom Jupyter notebook image curated for Indigenomics AI conversational +
speech model experiments. Targets the TELUS AI Factory custom service profile
pattern proven by Roshan on 2026-04-27.

## Base

`nvcr.io/nvidia/pytorch:24.10-py3` — CUDA 12.6, PyTorch 2.5, JupyterLab
pre-installed, Ubuntu 22.04. We add on top of the working base instead of
building CUDA + Jupyter from scratch.

## Curated Models

The image ships with the client/runtime libraries for these models:

| Model | Role | Library | Notes |
|---|---|---|---|
| OpenAI Whisper large-v3-turbo | Fast ASR | `faster-whisper` | Default fast ASR |
| NVIDIA Parakeet | Top-leaderboard ASR | `nemo_toolkit[asr]` | RNNT + TDT variants |
| NVIDIA Canary | Multilingual ASR + translation | `nemo_toolkit[asr]` | 4-language |
| NVIDIA Riva (client) | Full speech suite (ASR/TTS/diarization) | `nvidia-riva-client` | Connects to Riva server |
| NVIDIA PersonaPlex | Full-duplex conversational AI | `git+github.com/NVIDIA/personaplex` | Single voice/role/listen+speak model |

Weights are NOT baked into the image. Pull at runtime from Hugging Face Hub.

## Surfaces

- **JupyterLab** on port `8888` (no token, container-internal use)
- **FastAPI** template on `8000` for serving model endpoints from notebooks
- **Gradio** on `7860` for demos

## Run Locally (smoke)

```bash
docker run --rm -it --gpus all \
  -p 8888:8888 -p 8000:8000 -p 7860:7860 \
  -v $(pwd)/data:/workspace/data \
  ghcr.io/linuxiscool/iai-conversational-models:latest
```

## TELUS AI Factory Deploy

Hand the image reference to Roshan:

```
ghcr.io/linuxiscool/iai-conversational-models:latest
```

Roshan creates a custom service profile against the Indigenomics AI tenant
using this image as the notebook base. Re-pushes here become available on
the next notebook redeploy in the TELUS console.

## Build

```bash
cd ~/iai-conversational-models
docker buildx build \
  --builder iai-builder \
  --platform linux/amd64 \
  --cache-from type=local,src=./.buildx-cache \
  --cache-to type=local,dest=./.buildx-cache,mode=max \
  --push \
  -t ghcr.io/linuxiscool/iai-conversational-models:latest \
  -t ghcr.io/linuxiscool/iai-conversational-models:$(date +%Y%m%d) \
  .
```

## Smoke Inside Container

```bash
iai-doctor
```

Reports: GPU presence, CUDA/PyTorch version, model-lib versions,
endpoint usage hints.

## Provenance

- 2026-04-27 — Roshan sync: custom Docker image pattern proven via
  `roshanrajx64/pytorch-ffmpeg-notebook`. He asked Shawn to build a similar
  public image so a custom Indigenomics service profile could be created.
- 2026-05-13 — First Indigenomics image built ahead of Wed Roshan sync.
