# Copilot instructions

Read `AGENTS.md` at the repository root before making changes. It describes
the layout, how to build and verify the PDF in the container (`make`), how to
edit content safely, and how to swap in a different LaTeX CV design.

Short version: the CV is `src/cv.tex`; always run `make` after editing and
check the PDF still builds and fits the intended page count; never install TeX
on the host; keep third-party template license notices.
