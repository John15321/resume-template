# Agent guide (template repo)

This repo is a cookiecutter template. `{{ cookiecutter.project_slug }}/` is
rendered with Jinja into a LaTeX CV project; everything else (this file,
`hooks/`, `scripts/`, `preview/`, `.github/`) belongs to the template itself.
The generated project has its own `AGENTS.md`, which is what end users' agents
read. Keep it accurate whenever the generated build changes.

## Layout

| Path | Purpose |
| ---- | ------- |
| `cookiecutter.json` | Prompts, derived private vars (`__name_slug`, `__image`), `_copy_without_render` |
| `hooks/pre_gen_project.py` | Validates answers (slug, name, location, email, LinkedIn URL, GitHub user) |
| `hooks/post_gen_project.py` | Picks `src/cv-<style>.tex` / `cover-letter-<style>.tex` and renames to `cv.tex` / `cover-letter.tex`, prunes unused files |
| `{{ cookiecutter.project_slug }}/src/cv-{sidebar,classic}.tex` | The two designs, each with a matching cover letter |
| `scripts/test-template.sh` | Renders and builds every variant into `_test/` |
| `.github/workflows/test-template.yml` | Runs the same matrix in CI |
| `preview/` | PNG/PDF previews shown in `README.md` |

## Verify every change

```sh
scripts/test-template.sh --render          # fast: Jinja only
scripts/test-template.sh                   # render + compile all variants
scripts/test-template.sh classic-full      # one variant
IMAGE=<prebuilt-image> scripts/test-template.sh   # reuse one TeX Live image
```

All variants must compile to single-page PDFs. The `*-full` variants cover
Polish diacritics, LaTeX special characters in answers, letter paper, cover
letter and the RODO clause. Add a variant to the script and the workflow
matrix when you add a prompt that changes output.

If the default output changes visibly, regenerate `preview/`: render with
`--no-input cv_style=<style> include_cover_letter=yes`, run `make`, copy
`build/*.pdf` and convert with `pdftoppm -png -r 110 -singlefile`.

## Jinja inside LaTeX

LaTeX collides with Jinja on `{{`, `}}`, `{%` (brace followed by a comment)
and `{#` (macro arguments). Rules used throughout `src/*.tex`:

- Keep LaTeX preambles and macro definitions inside `{% raw %}` blocks.
- Insert user values as `{ {{- tex(x) -}} }`. `tex()` escapes `\ & % $ # _`,
  `url()` escapes `% #`; both are macros defined at the top of each file.
- Use `{%- if %}` (whitespace control) so conditionals do not leave blank
  lines, which would break paragraphs and `\\` sequences.
- Booleans arrive in hooks as the strings `"True"` / `"False"`.
- `.github/workflows/*.yaml` and `src/resources/*` are copied without
  rendering (GitHub's `${{ }}` syntax).

## Rules

- Generated scripts are POSIX `sh` and must work with Podman, Docker and
  Git Bash on Windows.
- Keep the MIT notices of the upstream designs intact.
- Prose: concise, no em dashes.
- Do not commit, tag or push unless the user asks you to.
