#!/usr/bin/env bash
# Render every template variant into _test/ and compile it in the container.
#
#   scripts/test-template.sh                    # render + build all variants
#   scripts/test-template.sh --render           # render only (no container)
#   scripts/test-template.sh classic sidebar    # only the named variants
#
# Set IMAGE to reuse one prebuilt TeX Live image for every variant instead of
# building one per project (the Containerfile is identical across variants).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="${OUT:-$ROOT/_test}"
ALL=(sidebar sidebar-nophoto sidebar-full classic classic-full)

RENDER_ONLY=0
if [[ "${1:-}" == "--render" ]]; then
  RENDER_ONLY=1
  shift
fi
VARIANTS=("$@")
((${#VARIANTS[@]})) || VARIANTS=("${ALL[@]}")

# The "full" variants stress escaping, diacritics, letter paper and every
# optional block.
variant_args() {
  local full=(include_cover_letter=yes include_gdpr_clause=yes paper_size=letter
    "full_name=Łukasz Gęśla" "headline=R&D Lead_1 50%")
  case "$1" in
    sidebar) args=(cv_style=sidebar) ;;
    sidebar-nophoto) args=(cv_style=sidebar include_photo=no) ;;
    sidebar-full) args=(cv_style=sidebar "${full[@]}") ;;
    classic) args=(cv_style=classic) ;;
    classic-full) args=(cv_style=classic "${full[@]}" linkedin_url=) ;;
    *) echo "Unknown variant: $1 (known: ${ALL[*]})" >&2; exit 2 ;;
  esac
}

mkdir -p "$OUT"
failed=()
for name in "${VARIANTS[@]}"; do
  variant_args "$name"
  rm -rf "${OUT:?}/$name" "$OUT/$name.log"

  echo "==> [$name] rendering"
  cookiecutter --no-input --output-dir "$OUT/$name" "$ROOT" "${args[@]}" >/dev/null
  project="$(find "$OUT/$name" -mindepth 1 -maxdepth 1 -type d | head -n1)"

  [[ "$RENDER_ONLY" == 1 ]] && continue

  echo "==> [$name] building"
  make_args=()
  [[ -n "${IMAGE:-}" ]] && make_args+=("IMAGE=$IMAGE")
  if ! make -C "$project" ci-artifacts "${make_args[@]}" >"$OUT/$name.log" 2>&1; then
    echo "    FAILED, see $OUT/$name.log"
    failed+=("$name")
    continue
  fi
  for pdf in "$project"/artifacts/*.pdf; do
    pages="$(pdfinfo "$pdf" 2>/dev/null | awk '/^Pages:/ {print $2}' || true)"
    echo "    $(basename "$pdf"): ${pages:-?} page(s)"
    if [[ -n "$pages" && "$pages" != 1 ]]; then
      echo "    FAILED, expected a single page"
      failed+=("$name")
    fi
  done
done

if ((${#failed[@]})); then
  echo "Failed variants: ${failed[*]}"
  exit 1
fi
echo "All variants OK."
