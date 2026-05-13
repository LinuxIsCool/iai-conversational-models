#!/usr/bin/env bash
# Tier 2 + Tier 3 local smoke. Requires GPU.
# Usage: bash scripts/verify-local.sh [tag]
set -euo pipefail

OWNER="linuxiscool"
PKG="iai-conversational-models"
TAG="${1:-latest}"
IMAGE="ghcr.io/${OWNER}/${PKG}:${TAG}"
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo "==> Tier 1: anonymous pull"
docker logout ghcr.io >/dev/null 2>&1 || true
docker pull "$IMAGE"

echo
echo "==> Tier 2: container smoke (iai-doctor)"
docker run --rm --gpus all "$IMAGE" iai-doctor

echo
echo "==> Tier 3: per-notebook functional smoke"
if [[ ! -f "$REPO_ROOT/samples/sample.wav" ]]; then
  echo "  SKIP: $REPO_ROOT/samples/sample.wav not present."
  echo "  Drop a 30s audio fixture into samples/ then re-run."
  exit 0
fi

docker run --rm --gpus all \
  -v "$REPO_ROOT/samples:/workspace/data:ro" \
  -v "$REPO_ROOT/tests:/workspace/tests:ro" \
  "$IMAGE" \
  python -m pytest -x /workspace/tests/test_image_smoke.py
