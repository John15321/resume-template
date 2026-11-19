# {{ cookiecutter.full_name }}, CV

Your CV lives in one file: **`src/cv.tex`**.
{%- if cookiecutter.include_cover_letter %} A matching cover letter lives in **`src/cover-letter.tex`**.{% endif %}
Edit, push to GitHub, and the PDF{% if cookiecutter.include_cover_letter %}s are{% else %} is{% endif %} built and published automatically.

## Getting the PDF

Every push to `main` builds the PDF{% if cookiecutter.include_cover_letter %}s{% endif %} and attaches {% if cookiecutter.include_cover_letter %}them{% else %}it{% endif %} to the **Latest CV** release on the
[Releases page](https://github.com/{{ cookiecutter.github_repo_owner }}/{{ cookiecutter.project_slug }}/releases/tag/latest).
Pushing a tag such as `v2026.1` additionally creates a frozen, versioned release
(handy for keeping track of what you sent where). Pull requests build the PDF
as a workflow artifact without publishing anything.

You don't need to install anything to get a PDF. The sections below are only
for building it on your own machine.

## Building locally

The LaTeX toolchain runs inside a container (`Containerfile`, Fedora + TeX
Live), so the only requirements are **Git**, **Podman** (or Docker) and,
optionally, **make**. The first build creates the image, which takes a few
minutes; every build after that takes seconds.

### Linux / macOS

```sh
sudo dnf install -y podman make        # Fedora; use apt/brew elsewhere
git clone https://github.com/{{ cookiecutter.github_repo_owner }}/{{ cookiecutter.project_slug }}.git
cd {{ cookiecutter.project_slug }}
make                                   # -> build/cv.pdf{% if cookiecutter.include_cover_letter %} and build/cover-letter.pdf{% endif %}
```

On macOS, run `podman machine init && podman machine start` once after
installing Podman.

### Windows

<details>
<summary>Step-by-step setup (Git for Windows, WSL2, Podman Desktop, VS Code)</summary>

**1. Git for Windows.** Install from <https://gitforwindows.org>. The defaults
are fine, with two exceptions worth checking: pick **Visual Studio Code** as the
default editor instead of Vim, and keep **Git Credential Manager** selected so
GitHub logins happen in the browser. Then, in a new terminal:

```sh
git config --global user.name "{{ cookiecutter.full_name }}"
git config --global user.email "{{ cookiecutter.email }}"
```

**2. WSL2.** Podman needs it. In PowerShell **as Administrator** run
`wsl --install --no-distribution`, restart, then check `wsl --status` shows
*Default Version: 2* (try `wsl --update` if it fails). If virtualization is
disabled (Task Manager, Performance, CPU), enable Intel VT-x / AMD-V in the BIOS.

**3. Podman Desktop.** Install from <https://podman-desktop.io/downloads> and
follow the onboarding wizard (Install Podman, then Create the machine). The
machine download can take 5 to 20 minutes with little progress shown; that is
normal. In *Settings, Preferences* enable starting the engine automatically.
`podman machine ls` should then report *Currently running*.

**4. VS Code.** Install from <https://code.visualstudio.com>, then clone the
repo from Git Bash and open the folder:

```sh
git clone https://github.com/{{ cookiecutter.github_repo_owner }}/{{ cookiecutter.project_slug }}.git
```

Accept the recommended LaTeX Workshop extension when prompted; it lets you view
the PDF inside VS Code. Press **`Ctrl+Shift+B`** to build; the PDF appears in
`build/cv.pdf`. `make` is not needed on Windows, the VS Code tasks call the
scripts directly.

</details>

## Editing

All content is in **`src/cv.tex`**, below the line marked
`EDIT YOUR CV BELOW THIS LINE`. Everything above it is the design (colours,
margins, helper commands); comments next to each section explain the building
blocks. Keep it to one page: if it spills over, trim bullets first.
{%- if cookiecutter.cv_style == "sidebar" and cookiecutter.include_photo %}

To set your photo, save it as **`src/resources/photo.jpg`** (a square-ish crop
works best; it is cropped to a circle). Until that file exists a circle with
your initials is shown.
{%- endif %}
{%- if cookiecutter.include_cover_letter %}

**`src/cover-letter.tex`** is a one-page letter in the same style. Treat it as a
template: update the recipient, reference number and body for each application.
{%- endif %}

Then commit and push:

```sh
git add .
git commit -m "Update CV"
git push
```

## Make targets

| Target | What it does |
| --- | --- |
| `make` / `make pdf` | Build `build/cv.pdf` (builds the image first if needed) |
{%- if cookiecutter.include_cover_letter %}
| `make cover` | Build `build/cover-letter.pdf` |
{%- endif %}
| `make watch` | Rebuild on every save (`WATCH=cover-letter` for the letter) |
| `make artifacts` | Copy the named, distributable PDF{% if cookiecutter.include_cover_letter %}s{% endif %} into `artifacts/` |
| `make clean` | Remove `build/` and `artifacts/` |
| `make shell` | Interactive shell inside the build container |
| `make image` | (Re)build the container image |
| `make nuke` | Delete the container image |
| `make help` | List all targets |

The scripts auto-detect Podman or Docker (Podman wins if both exist). Force one
with `CONTAINER_ENGINE=docker make`.

---

<sub>Generated from [John15321/resume-template](https://github.com/John15321/resume-template).
{%- if cookiecutter.cv_style == "sidebar" %} Design based on
[modern-latex-cv](https://www.overleaf.com/latex/templates/modern-latex-cv/qmdwjvcrcrph)
by Philip Empl (MIT).
{%- else %} Design based on [Jake's Resume](https://github.com/jakegut/resume)
by Jake Gutierrez (MIT).
{%- endif %}</sub>
