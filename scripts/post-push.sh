#!/usr/bin/env bash
# Post-push tasks: flip ghcr.io package to public, verify pull works,
# emit handoff URL.
set -euo pipefail

OWNER=linuxiscool
PKG=iai-conversational-models
PAT="${GH_PAT:-${GHCR_PAT:-}}"

if [[ -z "$PAT" ]]; then
  echo "FATAL: set GH_PAT or GHCR_PAT env before running."
  exit 1
fi

echo "[1/3] Flipping ghcr.io/${OWNER}/${PKG} visibility → public..."
curl -sS -X PATCH \
  -H "Authorization: Bearer ${PAT}" \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  "https://api.github.com/user/packages/container/${PKG}/visibility" \
  -d '{"visibility":"public"}' \
  | jq -r '.visibility // .message // "ok"'

echo ""
echo "[2/3] Anonymous pull smoke test..."
docker logout ghcr.io 2>&1 | tail -1
docker pull "ghcr.io/${OWNER}/${PKG}:latest" 2>&1 | tail -3
echo ""

echo "[3/3] Handoff URL:"
echo "  ghcr.io/${OWNER}/${PKG}:latest"
echo "  ghcr.io/${OWNER}/${PKG}:20260513"
echo "  https://github.com/${OWNER}/iai-conversational-models/pkgs/container/${PKG}"
echo ""
echo "Done."
