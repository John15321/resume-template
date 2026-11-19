#!/usr/bin/env sh
set -eu

. "$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)/common.sh"

ensure_repo_root
require_container_engine

"$ENGINE" build -t "$IMAGE" -f Containerfile .
