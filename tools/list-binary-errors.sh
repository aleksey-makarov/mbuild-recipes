#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
RECIPES_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd)"

cd "${RECIPES_ROOT}"

nickel export recipes.ncl --format json \
  | jq -r '
      to_entries
      | map(select(.value.type == "binary" and .value.status != "ok"))
      | sort_by(.key)
      | .[]
      | [.key, .value.status]
      | @tsv
    '
