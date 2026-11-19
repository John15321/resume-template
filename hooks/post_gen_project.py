#!/usr/bin/env python3
"""Post-generation hook: select the chosen CV design, prune unused files,
make scripts executable, and print next steps."""

import os
import shutil
import stat

STYLE = "{{ cookiecutter.cv_style }}"
STYLES = ("sidebar", "classic")
INCLUDE_PHOTO = "{{ cookiecutter.include_photo }}" == "True"
INCLUDE_COVER = "{{ cookiecutter.include_cover_letter }}" == "True"
SRC = "src"


def select_variant(stem, keep):
    """Rename src/<stem>-<STYLE>.tex to src/<stem>.tex (if keep) and delete the rest."""
    for style in STYLES:
        path = os.path.join(SRC, f"{stem}-{style}.tex")
        if keep and style == STYLE:
            os.replace(path, os.path.join(SRC, f"{stem}.tex"))
        elif os.path.exists(path):
            os.remove(path)


def make_scripts_executable():
    for name in os.listdir("scripts"):
        path = os.path.join("scripts", name)
        if path.endswith(".sh") and os.path.isfile(path):
            st = os.stat(path)
            os.chmod(path, st.st_mode | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)
    print("✅ Made scripts/*.sh executable")


def check_tool(name, install_hint):
    if shutil.which(name):
        print(f"✅ Found: {name}")
        return True
    print(f"⚠️  Missing: {name} ({install_hint})")
    return False


def main():
    print("🚀 Setting up your LaTeX CV project...")

    select_variant("cv", keep=True)
    select_variant("cover-letter", keep=INCLUDE_COVER)
    print(f"✅ CV design: {STYLE}" + (" + cover letter" if INCLUDE_COVER else ""))

    uses_photo = STYLE == "sidebar" and INCLUDE_PHOTO
    if not uses_photo:
        shutil.rmtree(os.path.join(SRC, "resources"), ignore_errors=True)
        if INCLUDE_PHOTO:
            print("ℹ️  The classic design has no photo slot, so include_photo was ignored.")

    make_scripts_executable()

    print("\n🔍 Checking required tools...")
    if not check_tool("podman", "sudo dnf install podman, or use Docker"):
        check_tool("docker", "install Docker, or use Podman")
    check_tool("make", "optional, the scripts/ can be run directly")

    if uses_photo:
        print(
            "\n🖼️  Drop your portrait at src/resources/photo.jpg "
            "(until then a circle with your initials is shown)."
        )

    print("\n📋 Next steps:")
    print("  cd {{ cookiecutter.project_slug }}")
    print("  make pdf             # first run builds the TeX Live image (a few minutes)")
    print("  make watch           # rebuild on every save")
    print("  make help            # show all targets")
    print("\n✏️  Edit src/cv.tex" + (" and src/cover-letter.tex" if INCLUDE_COVER else "") + ", then push: CI publishes the PDF as a GitHub Release.")
    print("\n🎉 Good luck with the applications!")


if __name__ == "__main__":
    main()
