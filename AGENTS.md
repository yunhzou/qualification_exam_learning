# Repository Working Agreement

## Required PDF verification

- After every repository change, run `.\.venv\Scripts\python.exe scripts\build.py all` from the repository root.
- Do not finish a task while either Tectonic build is running or failing.
- In the final response, provide local links to `build/main.pdf` and `build/presentation.pdf` so the updated documents are immediately available for review.
- After changes to LaTeX sources, bibliography entries, or document structure, render the affected PDF pages and inspect them for clipping, overlap, broken references, and other layout problems.
- After notebook or Python changes, run the relevant executable checks in addition to the mandatory PDF build.
- Keep generated build artifacts out of Git; `build/` is intentionally ignored.

## LaTeX architecture

- Treat the report as a modular codebase. Keep `main.tex` as a thin composition root and place substantive writing under `tex/report/`.
- Keep `presentation.tex` as a thin composition root and place individual frames under `tex/presentation/frames/`.
- Use one descriptively named module per concept or selected source. Filenames must identify the content directly; do not introduce generic numbered names such as `paper-06.tex`.
- Put cross-source comparisons under `tex/report/synthesis/` rather than appending them to whichever source file is convenient.
- Update `tex/README.md` whenever the source-tree convention changes.
