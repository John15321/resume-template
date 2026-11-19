#!/usr/bin/env sh
set -eu

. "$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)/common.sh"

ensure_repo_root
require_container_engine
ensure_image

mkdir -p "$OUT_DIR"

# -g forces a rebuild: latexmk does not track optional files probed with
# \IfFileExists (e.g. a photo added after the first build).
"$ENGINE" run --rm \
    -v "$(workspace_mount)" \
    -w /workspace \
    "$IMAGE" \
    latexmk -g -interaction=nonstopmode -halt-on-error \
        -outdir="$OUT_DIR" "$SRC_DIR/$MAIN.tex"

if [ ! -f "$OUT_DIR/$MAIN.pdf" ]; then
    printf '%s\n' "error: expected PDF not found at $OUT_DIR/$MAIN.pdf" >&2
    exit 1
fi
