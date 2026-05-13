# Roshan handoff — Indigenomics AI custom notebook image

**Date built:** 2026-05-13
**For:** Roshan (TELUS AI Factory)
**Pattern:** Apr 27 sync — public image stitched into Indigenomics custom service profile

## Image

```
ghcr.io/linuxiscool/iai-conversational-models:latest
ghcr.io/linuxiscool/iai-conversational-models:20260513
```

Public package on GitHub Container Registry. Pullable anonymously:

```bash
docker pull ghcr.io/linuxiscool/iai-conversational-models:latest
```

## What is in the image

Built on `pytorch/pytorch:2.5.1-cuda12.4-cudnn9-devel` (public Docker Hub).
The TELUS AI Factory custom profile can swap to `nvcr.io/nvidia/pytorch:24.10-py3`
on Roshan's side if preferred — the layer stack is portable.

| Layer | Versions |
|---|---|
| Base | PyTorch 2.5.1 + CUDA 12.4 + cuDNN 9 + Python 3.11 + Ubuntu 22.04 |
| System | ffmpeg, libsndfile1, sox, git-lfs, jq |
| ASR | faster-whisper >=1.0.3, openai-whisper, whisperx |
| NeMo | nemo_toolkit[asr] >=2.0.0 (Parakeet + Canary access) |
| Riva | nvidia-riva-client >=2.16.0 |
| PersonaPlex | `git+https://github.com/NVIDIA/personaplex@main` |
| LLM | transformers >=4.45, huggingface_hub, accelerate, datasets |
| Web | fastapi, uvicorn[standard], gradio, httpx, openai, anthropic |
| Jupyter | jupyterlab >=4.2, ipywidgets, jupyterlab-git, jupyter-archive |

## Seed notebooks shipped

`/workspace/examples/`

1. `01-whisper-turbo.ipynb` — faster-whisper large-v3-turbo, file → transcript
2. `02-parakeet.ipynb` — `nvidia/parakeet-tdt-1.1b-v2`, top open-ASR leaderboard
3. `03-canary.ipynb` — `nvidia/canary-1b`, 4-language ASR + translation
4. `04-riva-client.ipynb` — Riva ASR + TTS client (talks to deployed Riva server)
5. `05-personaplex.ipynb` — `nvidia/personaplex-7b-v1` full-duplex conversational AI

Weights are NOT baked into the image. Each notebook pulls weights from
Hugging Face Hub at runtime.

## Built-in diagnostic

The image ships with `/usr/local/bin/iai-doctor`. Runs at container start.
Reports GPU presence, CUDA/PyTorch versions, model-lib versions, endpoint
hints.

## Container ports

| Port | Service |
|---|---|
| 8888 | JupyterLab (default CMD) |
| 8000 | FastAPI template for model endpoints |
| 7860 | Gradio demo |

## Iteration loop with Roshan

When changes are needed:

1. Edit `Dockerfile` here.
2. Re-run the buildx push (cache is on data-24tb, fast incremental).
3. Roshan redeploys the notebook profile → latest image picked up automatically.

This is the exact loop Roshan described on 2026-04-27:

> "If something is not working, you have to contact me and then I have a
> few debug … that can be saved. If you want, we can give that a try."

The image now belongs to Indigenomics / LinuxIsCool. Roshan stitches it into
a custom profile under the Indigenomics tenant. Modify-image → redeploy =
fastest possible iteration cycle on the TELUS AI Factory.

## Source

Build sources live at `/mnt/data-24tb/docker-builds/legion-jupyter-ai/` on the
Legion machine. Will be promoted into the `legion-plugins` repo as a published
artifact once Roshan confirms the profile is wired.

## Why these models

- **Whisper turbo** — Legion's existing transcription default; performance baseline
- **Parakeet** — current open-leaderboard top ASR; comparison anchor vs Whisper turbo
- **Canary** — multilingual ASR + translation, useful for IndigenomicsAI multilingual outreach
- **Riva** — full speech stack including TTS; voice surface for IAI Gateway demos
- **PersonaPlex** — full-duplex conversational AI; the model that finally lets a TELUS-sovereign IAI conversational agent feel natural — selectable voice + role + interrupt-aware

PersonaPlex is the strategic centerpiece. A sovereign Indigenous conversational
agent — Elder voice, Indigenomics Tutor role, real-time turn-taking, no
ASR→LLM→TTS cascade — is now technically reachable on TELUS infrastructure
the moment Roshan's custom profile mounts this image.
