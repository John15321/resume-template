#!/usr/bin/env python3
"""Pre-generation hook: validate cookiecutter answers before rendering."""

import re
import sys


def fail(msg):
    print(f"❌ Error: {msg}")
    sys.exit(1)


def main():
    print("🔍 Validating cookiecutter parameters...")

    project_slug = "{{ cookiecutter.project_slug }}"
    if not re.match(r"^[a-zA-Z][a-zA-Z0-9_-]*$", project_slug):
        fail(
            f"project slug '{project_slug}' must start with a letter and contain "
            "only letters, numbers, hyphens, and underscores."
        )

    full_name = """{{ cookiecutter.full_name }}""".strip()
    if not full_name:
        fail("full_name must not be empty.")

    location = """{{ cookiecutter.location }}""".strip()
    if not location:
        fail("location must not be empty (it is printed on the CV and cover letter).")

    email = "{{ cookiecutter.email }}"
    if not re.match(r"^[^@\s]+@[^@\s]+\.[^@\s]+$", email):
        fail(f"'{email}' does not look like an email address.")

    linkedin_url = "{{ cookiecutter.linkedin_url }}"
    if linkedin_url and not linkedin_url.startswith(("http://", "https://")):
        fail("linkedin_url must be a full URL (https://...) or empty.")

    github_username = "{{ cookiecutter.github_username }}"
    if github_username and not re.match(r"^[A-Za-z0-9-]+$", github_username):
        fail(f"'{github_username}' is not a valid GitHub username.")

    print(f"✅ Project slug '{project_slug}' is valid.")
    print("✅ All parameters are valid. Generating project...")


if __name__ == "__main__":
    main()
