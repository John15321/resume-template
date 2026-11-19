# Agent guide

This repo is {{ cookiecutter.full_name }}'s CV as LaTeX. It is built in a container
so nobody needs TeX installed locally. It was generated from
[John15321/resume-template](https://github.com/John15321/resume-template) with the
**{{ cookiecutter.cv_style }}** design, but nothing ties it to that design. Any
LaTeX CV template can replace it (see "Replacing the design" below).

`CLAUDE.md` and `.github/copilot-instructions.md` point here. Keep this file
as the single source of truth and update it when the build changes.

## Layout

| Path | Purpose |
| ---- | ------- |
| `src/cv.tex` | The CV. Design (preamble, macros) on top, content below `EDIT YOUR CV BELOW THIS LINE` |
{%- if cookiecutter.include_cover_letter %}
| `src/cover-letter.tex` | Cover letter in the same style |
{%- endif %}
{%- if cookiecutter.cv_style == "sidebar" and cookiecutter.include_photo %}
| `src/resources/photo.jpg` | Optional photo. An initials circle is drawn while it is missing |
{%- endif %}
| `latexmkrc` | TeX engine (`$pdf_mode`) and search path (`src/` and subdirectories) |
| `Containerfile` | Fedora + TeX Live image the build runs in |
| `Makefile`, `scripts/*.sh` | Build entry points. POSIX sh, auto-detect Podman or Docker |
| `scripts/common.sh` | Shared settings: image name, main file, distributed PDF names |
| `.github/workflows/build.yaml` | CI: `make ci-artifacts`, publishes releases on `main` and `v*` tags |
| `build/`, `artifacts/` | Output, gitignored |

## Build and verify

Always compile after changing a `.tex` file. Never install TeX on the host;
everything goes through the container.

```sh
make                 # image on first run (a few minutes), then build/cv.pdf
MAIN=other make pdf  # build src/other.tex instead
make shell           # debug inside the container (kpsewhich, texdoc, ...)
make ci-artifacts    # exactly what CI runs
```

A build is good when `make` exits 0 and the PDF has the intended page count
(`pdfinfo build/cv.pdf`, usually 1 page). On failure, read the first `!` error
in `build/<name>.log`, not the latexmk summary. Overfull hbox warnings that
come from the design itself are normal; do not chase them unless the output
visibly breaks.

## Editing content

- Reuse the macros the design already defines (look above the
  `EDIT YOUR CV BELOW THIS LINE` marker) instead of hand-formatting.
- Escape LaTeX special characters in content: `\&`, `\%`, `\$`, `\#`, `\_`.
  Write en dashes in date ranges as `--`.
- Non-ASCII names and places (ą, ę, ł, ü, ...) work as UTF-8 input.
- Keep it to one page. Shorten or drop bullets before shrinking fonts or
  margins.
- When tailoring to a job posting, keep facts truthful; rephrase and reorder,
  never invent experience.

## Replacing the design

The two shipped designs are just a starting point. Overleaf's CV gallery,
CTAN and GitHub have hundreds more (Awesome-CV, moderncv, AltaCV, Deedy,
Developer CV, and so on), and any of them works here:

1. Put the template's main file at `src/cv.tex` and any `.cls`, `.sty`,
   images or fonts it ships anywhere under `src/`. `latexmkrc` adds `src/`
   recursively to the search path, so `\documentclass{awesome-cv}` with
   `src/awesome-cv.cls` just works.
2. Set the engine in `latexmkrc`: `$pdf_mode = 1` pdflatex, `4` lualatex,
   `5` xelatex. Templates using `fontspec` or system fonts need 4 or 5.
   Fonts bundled in the repo should be loaded with fontspec's `Path=` option.
3. If a package or class is missing from the image, add
   `RUN dnf install -y 'tex(name.sty)'` to the `Containerfile` (Fedora
   resolves TeX file names to packages), then `make image`.
4. Move the existing content into the new template's macros.
5. Keep the third-party template's license notice in the source and update
   the credits line at the bottom of `README.md`.

## Adding documents

Any `src/<name>.tex` builds with `MAIN=<name> make pdf`. To publish it from CI,
add a Makefile target next to `pdf`, make `test` and `artifacts` depend on it,
and copy it in `scripts/gather-artifacts.sh` (distributed file names are set
in `scripts/common.sh`).

## Rules

- Do not commit `build/` or `artifacts/`; PDFs are published by CI.
- Keep scripts POSIX `sh` and working with both Podman and Docker, including
  Git Bash on Windows (see `scripts/common.sh`).
- Do not change the release logic in `.github/workflows/build.yaml` unless
  asked.
- Do not commit, tag or push unless the user asks you to.
