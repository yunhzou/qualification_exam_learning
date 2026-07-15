# LaTeX source architecture

The report is organized like a small codebase. `main.tex` is the composition root: it owns packages, document startup, module order, and the bibliography, but it should not accumulate substantive prose.

## Report modules

- `report/front_matter/`: title metadata, abstract, and table of contents.
- `report/scope/`: research scope, guiding questions, working position, and the complete source corpus.
- `report/foundations/`: prerequisite model architecture, training, and inference material.
- `report/post_training/`: algorithm explanations that cut across individual sources.
- `report/selected_sources/`: one file per paper, technical report, or research article, plus a small composition file.
- `report/synthesis/`: comparisons organized by research question rather than by source.
- `report/experiments/`: connections between claims in the literature and repository experiments.
- `report/conclusion/`: final claims, qualifications, and open questions.

## Presentation modules

`presentation.tex` is also a composition root. Presentation metadata lives in
`presentation/document_metadata.tex`, and every slide lives in its own descriptively
named file under `presentation/frames/`. Keep a frame's title and content together so
reordering the talk only requires moving an `\input{...}` line.

## Naming rules

Use descriptive snake-case filenames that state both the subject and its role, for example `composer2_5_targeted_textual_feedback.tex`. Do not use names such as `paper-06.tex`, `notes.tex`, or `misc.tex`. A reader should know which file to edit without opening it.

Each selected source gets its own file. Technical reports, lab research articles, and peer-reviewed papers are all valid source modules; record the source type explicitly in the module. Cross-source interpretation belongs under `synthesis/`, not inside an unrelated source summary.

## Adding a source

1. Add a precise BibTeX entry to `references.bib`.
2. Create one descriptively named file under `report/selected_sources/`.
3. Add its `\input{...}` line to `selected_post_training_sources.tex`.
4. Add it to the corpus in `report/scope/research_scope_guiding_questions_and_source_corpus.tex`.
5. Build both documents with `.\.venv\Scripts\python.exe scripts/build.py all` and inspect the affected PDF pages.

## Module boundaries

Files loaded directly by `main.tex` normally own a `\section`. Individual source and synthesis modules own a `\subsection`. Avoid redefining packages or document metadata inside content modules. Keep labels and citation keys semantic so moving a module does not break references.
