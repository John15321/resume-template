IMAGE         := {{ cookiecutter.__image }}
SRC_DIR       := src
OUT_DIR       := build
MAIN          := cv
{%- if cookiecutter.include_cover_letter %}
COVER         := cover-letter
{%- endif %}
ARTIFACTS_DIR := artifacts

export IMAGE SRC_DIR OUT_DIR ARTIFACTS_DIR

.PHONY: all help image build pdf{% if cookiecutter.include_cover_letter %} cover{% endif %} watch shell clean setup artifacts test ci-build ci-artifacts nuke

.DEFAULT_GOAL := all

## Default target: build the container image (if needed) and compile the PDF{% if cookiecutter.include_cover_letter %}s{% endif %}.
all: pdf{% if cookiecutter.include_cover_letter %} cover{% endif %}
	@echo "Done. See $(OUT_DIR)/"

## Show this help message.
help:
	@echo "Usage: make [target]"
	@echo ""
	@awk 'BEGIN {FS = ":.*"} /^## / { help = substr($$0, 4) } /^[a-zA-Z0-9_-]+:/ && help { printf "  %-12s %s\n", $$1, help; help = "" }' $(MAKEFILE_LIST)

## Build (or refresh) the container image with the LaTeX toolchain.
image:
	./scripts/build-image.sh

## Alias for 'image' (kept for muscle memory).
build: image

## Ensure the container image is available for local or CI builds.
setup: image

## Compile the CV to PDF inside the container (output in build/).
pdf:
	MAIN=$(MAIN) ./scripts/build-pdf.sh
{%- if cookiecutter.include_cover_letter %}

## Compile the cover letter to PDF inside the container (output in build/).
cover:
	MAIN=$(COVER) ./scripts/build-pdf.sh
{%- endif %}

## Rebuild the CV on every save (use WATCH=cover-letter for the letter).
watch:
	MAIN=$(or $(WATCH),$(MAIN)) ./scripts/watch.sh

## Drop into an interactive shell inside the build container.
shell:
	./scripts/open-shell.sh

## Remove build/ and artifacts/.
clean:
	./scripts/clean.sh

## Copy the distribution-ready PDF{% if cookiecutter.include_cover_letter %}s{% endif %} and build info into artifacts/.
artifacts: pdf{% if cookiecutter.include_cover_letter %} cover{% endif %}
	./scripts/gather-artifacts.sh

## Build and verify the expected PDF{% if cookiecutter.include_cover_letter %}s{% endif %} exist.
test: pdf{% if cookiecutter.include_cover_letter %} cover{% endif %}
	test -f $(OUT_DIR)/$(MAIN).pdf
{%- if cookiecutter.include_cover_letter %}
	test -f $(OUT_DIR)/$(COVER).pdf
{%- endif %}

## CI pipeline: clean build + verification.
ci-build: clean test

## CI pipeline: clean build + verification + artifacts.
ci-artifacts: ci-build artifacts

## Remove the container image (next build recreates it).
nuke:
	-podman rmi -f $(IMAGE) 2>/dev/null || docker rmi -f $(IMAGE) 2>/dev/null || true
