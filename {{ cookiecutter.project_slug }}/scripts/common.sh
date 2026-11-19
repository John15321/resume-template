#!/usr/bin/env sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
REPO_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)

IMAGE=${IMAGE:-{{ cookiecutter.__image }}}
SRC_DIR=${SRC_DIR:-src}
OUT_DIR=${OUT_DIR:-build}
MAIN=${MAIN:-cv}
COVER=${COVER:-cover-letter}
ARTIFACTS_DIR=${ARTIFACTS_DIR:-artifacts}
DIST_PDF_NAME=${DIST_PDF_NAME:-{{ cookiecutter.__name_slug }}-cv.pdf}
DIST_COVER_PDF_NAME=${DIST_COVER_PDF_NAME:-{{ cookiecutter.__name_slug }}-cover-letter.pdf}
CONTAINER_ENGINE=${CONTAINER_ENGINE:-${ENGINE:-}}

detect_container_engine() {
    if [ -n "$CONTAINER_ENGINE" ]; then
        printf '%s\n' "$CONTAINER_ENGINE"
        return
    fi

    if command -v podman >/dev/null 2>&1; then
        printf '%s\n' "podman"
    elif command -v docker >/dev/null 2>&1; then
        printf '%s\n' "docker"
    else
        printf '\n'
    fi
}

ENGINE=$(detect_container_engine)

# Prevent Git Bash on Windows from converting container-side paths (e.g. /workspace)
# to Windows paths when calling docker/podman run.
case "$(uname -s)" in
    MINGW*|MSYS*|CYGWIN*)
        export MSYS_NO_PATHCONV=1
        export MSYS2_ARG_CONV_EXCL="*"
        ;;
esac

ensure_repo_root() {
    cd "$REPO_ROOT"
}

require_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        printf '%s\n' "error: required command not found: $1" >&2
        exit 1
    fi
}

require_container_engine() {
    if [ -z "$ENGINE" ]; then
        printf '%s\n' "error: neither podman nor docker is available" >&2
        exit 1
    fi

    require_command "$ENGINE"
}

host_workspace() {
    case "$(uname -s)" in
        MINGW*|MSYS*|CYGWIN*)
            (cd "$REPO_ROOT" && pwd -W)
            ;;
        *)
            printf '%s\n' "$REPO_ROOT"
            ;;
    esac
}

volume_suffix() {
    case "$(uname -s)" in
        Linux*)
            printf ':Z'
            ;;
        *)
            printf ''
            ;;
    esac
}

workspace_mount() {
    printf '%s:/workspace%s\n' "$(host_workspace)" "$(volume_suffix)"
}

image_exists() {
    case "$ENGINE" in
        podman)
            "$ENGINE" image exists "$IMAGE"
            ;;
        docker)
            "$ENGINE" image inspect "$IMAGE" >/dev/null 2>&1
            ;;
        *)
            return 1
            ;;
    esac
}

ensure_image() {
    if ! image_exists; then
        printf '%s\n' "Container image $IMAGE not found. Building it first..."
        "$SCRIPT_DIR/build-image.sh"
    fi
}
