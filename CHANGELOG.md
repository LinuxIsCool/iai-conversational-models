# Changelog

All notable changes to `iai-conversational-models`. Tagged in
`ghcr.io/linuxiscool/iai-conversational-models`.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/);
this project follows [SemVer](https://semver.org/) with MAJOR.MINOR semantics:
- MAJOR = base image / CUDA / PyTorch shift
- MINOR = model or library addition / removal

## [Unreleased]

### Planned for v0.2
- `nemo_toolkit[asr]` for `nvidia/parakeet-tdt-1.1b-v2` + `nvidia/canary-1b`
- PersonaPlex from `git+https://github.com/NVIDIA/personaplex@main`
- Tier 3 functional smoke for all 5 notebooks
- Sample audio fixtures under `samples/`

## [0.1] — 2026-05-13

### Added
- Initial public image push to `ghcr.io/linuxiscool/iai-conversational-models`
- Base: `pytorch/pytorch:2.5.1-cuda12.4-cudnn9-devel` (CUDA 12.4, cuDNN 9,
  PyTorch 2.5.1, Python 3.11, Ubuntu 22.04)
- Light pip stack:
  - `faster-whisper>=1.0.3` (Whisper large-v3-turbo entry point)
  - `openai-whisper` (reference Whisper)
  - `nvidia-riva-client>=2.16.0` (Riva ASR + TTS client)
  - `transformers>=4.45`, `huggingface_hub>=0.24`, `accelerate>=0.34`
  - `fastapi>=0.115`, `uvicorn[standard]>=0.32`, `gradio>=5.0`
  - `jupyterlab>=4.2`, `ipywidgets>=8.1`, `jupyterlab-git`, `ipykernel`
- System: ffmpeg, libsndfile1, sox, libsox-fmt-all, git-lfs
- 5 seed notebooks under `/workspace/examples/`:
  - `01-whisper-turbo.ipynb`
  - `02-parakeet.ipynb` (lib not yet present; placeholder)
  - `03-canary.ipynb` (lib not yet present; placeholder)
  - `04-riva-client.ipynb`
  - `05-personaplex.ipynb` (lib not yet present; placeholder)
- `/usr/local/bin/iai-doctor` smoke diagnostic — reports GPU, CUDA,
  torch, installed model libs, port hints. Runs at container start.
- Default CMD: `jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root`
- Exposed ports: 8888 (JupyterLab), 8000 (FastAPI), 7860 (Gradio)
- Image labels: title, description, source, vendor, licenses,
  legion.purpose, legion.target-tenant, legion.version

### Notes
- Tagged: `:latest`, `:v0.1`, `:20260513`
- Built via 'docker buildx' (buildx, docker-container driver)
  from local build host at 2026-05-13
- v0.1 deferred NeMo + PersonaPlex layers due to Legion-side disk
  pressure; resolved in Phase 1 (relocate docker data-root to
  data-24tb) before v0.2
- HANDOFF: `HANDOFF-ROSHAN.md`
- Vision + roadmap: `~/.claude/local/backlog/task-485 - iai-conversational-models-image-system.md`

### Provenance
- Pattern proven by Roshan 2026-04-27 (`roshanrajx64/pytorch-ffmpeg-notebook`)
- First image built ahead of 2026-05-13 12:00 PDT sync with Roshan
