#!/usr/bin/env sh
set -eu

. "$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)/common.sh"

ensure_repo_root
require_container_engine
ensure_image

"$ENGINE" run --rm -it \
    -v "$(workspace_mount)" \
    -w /workspace \
    "$IMAGE" \
    bash
