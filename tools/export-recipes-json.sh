#!/usr/bin/env bash
set -euo pipefail

# Export evaluated recipes.ncl to canonical JSON for diffing/comparison.
# Usage:
#   tools/export-recipes-json.sh [output-file]

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
OUT_PATH="${1:-${REPO_ROOT}/recipes.json}"

cd "${REPO_ROOT}"

nickel export recipes.ncl --format json | jq -S . > "${OUT_PATH}"

echo "ok: wrote ${OUT_PATH}"
