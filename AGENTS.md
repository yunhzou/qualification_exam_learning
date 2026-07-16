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

## Expository writing principles

- Write in conceptual dependency order. A section may use only ideas that it has already defined or that are genuine prerequisites established earlier in the document.
- Start with the requested algorithm itself. State its inputs, outputs, training unit, and high-level execution loop before introducing derivations, implementation details, systems variants, or related papers.
- Never use the name of another algorithm as an explanation. For example, do not explain GRPO by saying that it inherits PPO clipping before PPO clipping has been derived. Either teach the prerequisite first or defer the comparison until the GRPO mechanism is independently understandable.
- Separate explanation from attribution. Derive what a mechanism does and why it is needed before stating which earlier paper or algorithm introduced it. Historical lineage is not a substitute for technical explanation.
- Introduce each mathematical object by first stating the question it answers. Derive the formula from that question, define every symbol and unit, and then give a concrete numerical example.
- Make transitions causal. Before adding a ratio, baseline, clipping term, KL term, buffer, or asynchronous correction, explain which specific problem in the preceding construction requires it.
- Do not justify a design by calling it standard, typical, or common. State the computational or statistical rationale, the alternative design, and the tradeoff that selects between them.
- Keep the core algorithm separate from later systems complications and case studies. Topics such as asynchronous workers, agent harnesses, Polar trace reconstruction, critics, and process rewards belong after the foundational update is complete.
- Do not introduce broad motivation from adjacent topics unless it is required for the requested argument. An algorithm-learning section should not begin with an unrelated comparison such as the limitations of SFT.
- Keep one conceptual responsibility per module. If a module mixes derivation, buffering, asynchronous execution, and an unrelated paper discussion, split it according to the dependency order.
- Prefer the teaching sequence: direct algorithm overview; definitions and training units; step-by-step derivation; numerical example; executable implementation; compute and storage; execution variants; limitations; historical comparison and later papers.
- Treat reader confusion as evidence of a missing prerequisite or transition, not as a reason to add more formulas or terminology.
