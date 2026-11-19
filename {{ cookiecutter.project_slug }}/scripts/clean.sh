#!/usr/bin/env sh
set -eu

. "$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)/common.sh"

ensure_repo_root
rm -rf "$OUT_DIR" "$ARTIFACTS_DIR"
