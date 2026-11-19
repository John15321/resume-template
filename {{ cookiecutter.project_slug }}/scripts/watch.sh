#!/usr/bin/env sh
# Rebuild the PDF every time the .tex source is saved (Ctrl+C to stop).
# Open build/$MAIN.pdf in any viewer that auto-reloads (Evince, Okular,
# VS Code, Firefox) to get a live preview.
set -eu

. "$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)/common.sh"

ensure_repo_root
require_container_engine
ensure_image

mkdir -p "$OUT_DIR"

exec "$ENGINE" run --rm -it \
    -v "$(workspace_mount)" \
    -w /workspace \
    "$IMAGE" \
    latexmk -pvc -view=none -interaction=nonstopmode \
        -outdir="$OUT_DIR" "$SRC_DIR/$MAIN.tex"
