#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "usage: $0 <package>" >&2
  exit 2
fi

PKG="$1"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
RECIPES_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
WORKSPACE_ROOT="$(cd -- "${RECIPES_ROOT}/.." && pwd)"

if [[ -x "${WORKSPACE_ROOT}/mbuild/mbuild/target/debug/mbuild" ]]; then
  MBUILD_BIN="${WORKSPACE_ROOT}/mbuild/mbuild/target/debug/mbuild"
else
  MBUILD_BIN="mbuild"
fi

src_keys="$({
  cd "${RECIPES_ROOT}"
  nickel export recipes.ncl --format json \
    | jq -r --arg pkg "$PKG" '
        to_entries
        | map(select(.key | startswith($pkg + "-src-")))
        | map(.key)
        | sort
        | .[]
      '
} )"

if [[ -z "${src_keys}" ]]; then
  echo "error: no source artifact found for package '${PKG}'" >&2
  exit 1
fi

count="$(printf '%s\n' "$src_keys" | sed '/^$/d' | wc -l | tr -d ' ')"
if [[ "$count" -ne 1 ]]; then
  echo "error: expected exactly one source artifact for package '${PKG}', got ${count}:" >&2
  printf '%s\n' "$src_keys" >&2
  exit 1
fi

artifact="$(printf '%s\n' "$src_keys" | head -n1)"
cd "${WORKSPACE_ROOT}"
exec "${MBUILD_BIN}" "$artifact" build
