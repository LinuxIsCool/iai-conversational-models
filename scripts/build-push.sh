#!/usr/bin/env bash
# One-line buildx wrapper. Run from repo root.
# Usage:  bash scripts/build-push.sh [tag]
#         scripts/build-push.sh v0.2
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

OWNER="linuxiscool"
PKG="iai-conversational-models"
TAG="${1:-latest}"
DATESTAMP="$(date +%Y%m%d)"
SHA="$(git rev-parse --short HEAD 2>/dev/null || echo nogit)"

BUILDER=iai-builder
docker buildx inspect "$BUILDER" >/dev/null 2>&1 || \
  docker buildx create --name "$BUILDER" --driver docker-container --bootstrap

echo "Building → ghcr.io/${OWNER}/${PKG}"
echo "  tags: ${TAG}, ${DATESTAMP}, sha-${SHA}"
echo

docker buildx build \
  --builder "$BUILDER" \
  --platform linux/amd64 \
  --cache-to "type=registry,ref=ghcr.io/${OWNER}/${PKG}:buildcache,mode=max" \
  --cache-from "type=registry,ref=ghcr.io/${OWNER}/${PKG}:buildcache" \
  --push \
  --provenance=false \
  -t "ghcr.io/${OWNER}/${PKG}:${TAG}" \
  -t "ghcr.io/${OWNER}/${PKG}:${DATESTAMP}" \
  -t "ghcr.io/${OWNER}/${PKG}:sha-${SHA}" \
  .

echo
echo "Done."
echo "  ghcr.io/${OWNER}/${PKG}:${TAG}"
echo "  ghcr.io/${OWNER}/${PKG}:${DATESTAMP}"
echo "  ghcr.io/${OWNER}/${PKG}:sha-${SHA}"
