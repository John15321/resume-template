#!/usr/bin/env sh
set -eu

. "$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)/common.sh"

ensure_repo_root

SOURCE_PDF="$OUT_DIR/$MAIN.pdf"
TARGET_PDF="$ARTIFACTS_DIR/$DIST_PDF_NAME"

if [ ! -f "$SOURCE_PDF" ]; then
    printf '%s\n' "error: source PDF not found at $SOURCE_PDF" >&2
    exit 1
fi

mkdir -p "$ARTIFACTS_DIR"
cp "$SOURCE_PDF" "$TARGET_PDF"

# The cover letter is optional: only gathered if its source exists.
if [ -f "$SRC_DIR/$COVER.tex" ]; then
    SOURCE_COVER_PDF="$OUT_DIR/$COVER.pdf"
    if [ ! -f "$SOURCE_COVER_PDF" ]; then
        printf '%s\n' "error: cover letter PDF not found at $SOURCE_COVER_PDF" >&2
        exit 1
    fi
    cp "$SOURCE_COVER_PDF" "$ARTIFACTS_DIR/$DIST_COVER_PDF_NAME"
fi

cat > "$ARTIFACTS_DIR/build-info.txt" <<EOF
{{ cookiecutter.project_slug }} build information
==================================
Build Date: $(date -u '+%Y-%m-%d %H:%M:%S UTC')
Git Branch: $(git branch --show-current 2>/dev/null || echo "unknown")
Git Commit: $(git rev-parse HEAD 2>/dev/null || echo "unknown")
Git Commit Short: $(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
EOF

ls -1 "$ARTIFACTS_DIR"
