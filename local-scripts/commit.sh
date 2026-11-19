#!/usr/bin/env bash
# Initial commit + push for the resume-template cookiecutter.
set -euo pipefail
cd "$(dirname "$0")/.."

git checkout -B main
git add -A
git status --short
git commit -s -S -m "Add LaTeX CV cookiecutter template

Two designs (sidebar, classic), optional photo, cover letter and Polish
RODO clause, Podman/Docker build via make, GitHub Actions releases, and a
CI matrix that renders and builds every variant. Generated projects are
design-agnostic (engine and search path in latexmkrc) and ship AGENTS.md,
CLAUDE.md and Copilot instructions for coding agents."
git push -u origin main
