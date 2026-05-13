# syntax=docker/dockerfile:1.7
# IAI Conversational Models — Custom Jupyter Notebook Image (v0.1 — lean)
# v0.1: Whisper turbo + Riva client + FastAPI + Jupyter. ~4GB.
# v0.2 (deferred): + NeMo (Parakeet/Canary) + PersonaPlex. Needs relocated docker data-root.
# Target: TELUS AI Factory custom service profile (Roshan Apr 27 pattern)

ARG BASE_IMAGE=pytorch/pytorch:2.5.1-cuda12.4-cudnn9-devel
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.title="IAI Conversational Models v0.1"
LABEL org.opencontainers.image.description="Jupyter notebook image curated for Indigenomics AI conversational + speech model experiments. v0.1: Whisper turbo + Riva client."
LABEL org.opencontainers.image.source="https://github.com/LinuxIsCool/legion-plugins"
LABEL org.opencontainers.image.vendor="Longtail Financial Corp."
LABEL org.opencontainers.image.licenses="Apache-2.0"
LABEL legion.purpose="telus-ai-factory-custom-profile"
LABEL legion.target-tenant="indigenomics-ai"
LABEL legion.version="0.1"

ENV DEBIAN_FRONTEND=noninteractive \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1 \
    PYTHONUNBUFFERED=1

# System: ffmpeg + audio
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ffmpeg libsndfile1 sox libsox-fmt-all \
        git-lfs ca-certificates curl jq \
    && git lfs install --system \
    && rm -rf /var/lib/apt/lists/*

# Single pip layer — minimize snapshot churn
RUN pip install --upgrade pip setuptools wheel && \
    pip install \
        "faster-whisper>=1.0.3" \
        "openai-whisper" \
        "soundfile" \
        "librosa" \
        "pydub" \
        "ffmpeg-python" \
        "nvidia-riva-client>=2.16.0" \
        "huggingface_hub>=0.24" \
        "transformers>=4.45" \
        "accelerate>=0.34" \
        "fastapi>=0.115" \
        "uvicorn[standard]>=0.32" \
        "gradio>=5.0" \
        "httpx>=0.27" \
        "openai>=1.50" \
        "jupyterlab>=4.2" \
        "ipywidgets>=8.1" \
        "jupyterlab-git" \
        "ipykernel"

RUN mkdir -p /workspace/examples /workspace/data /workspace/models
COPY examples/ /workspace/examples/
COPY README.md /workspace/README.md
COPY HANDOFF-ROSHAN.md /workspace/HANDOFF-ROSHAN.md

WORKDIR /workspace

# Smoke diagnostic
RUN cat > /usr/local/bin/iai-doctor <<'DOC'
#!/usr/bin/env bash
echo "=== IAI Conversational Models v0.1 — Doctor ==="
echo "Date: $(date)"
nvidia-smi --query-gpu=name,driver_version,memory.total --format=csv 2>&1 | head -3
python -c "import torch; print(f'torch={torch.__version__} cuda={torch.cuda.is_available()} devices={torch.cuda.device_count()}')"
python -c "
import importlib
for lib in ['faster_whisper', 'whisper', 'riva.client', 'transformers', 'fastapi', 'jupyterlab']:
    try:
        m = importlib.import_module(lib)
        v = getattr(m, '__version__', 'unknown')
        print(f'  {lib:20s} {v}')
    except ImportError as e:
        print(f'  {lib:20s} MISSING ({e})')
"
echo ""
echo "v0.2 (pending docker data-root relocate): + nemo_toolkit[asr], + personaplex"
DOC
RUN chmod +x /usr/local/bin/iai-doctor

# Smoke before push
RUN python -c "import torch, transformers, fastapi, faster_whisper; print('smoke OK')"

EXPOSE 8888 8000 7860
CMD ["bash","-lc","iai-doctor && jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root --ServerApp.token='' --ServerApp.password=''"]
