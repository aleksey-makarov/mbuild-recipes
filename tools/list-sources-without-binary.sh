#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
RECIPES_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd)"

cd "${RECIPES_ROOT}"

nickel export recipes.ncl --format json \
  | jq -r '
      to_entries as $all
      | [ $all[] | select(.value.type == "binary") | .key ] as $binary_keys
      | $all[]
      | select(.key | contains("-src-"))
      | .key as $src
      | ($src | split("-src-")[0]) as $pkg
      | select((any($binary_keys[]; startswith($pkg + "-"))) | not)
      | [$pkg, $src]
      | @tsv
    '
