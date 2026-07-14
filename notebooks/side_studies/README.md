# Side Studies

This directory stores small, self-contained notebooks for fragmented learning questions that are useful to preserve but do not belong in the numbered post-training curriculum.

## Convention

- Use descriptive snake-case filenames, for example `how_tokenization_works.ipynb`.
- Address one primary question per notebook.
- Begin with the question and the expected learning outcome.
- Prefer a minimal CPU-executable example over framework-heavy code.
- Show intermediate representations, tensor shapes, or algorithm state explicitly.
- Separate exact behavior from illustrative or tokenizer/model-dependent output.
- End with a concise takeaway and links to any relevant main notebook.
- Use the repository kernel: **Python (.venv - qualification exam)**.

Side studies are not automatically part of the five-paper report or the ordered curriculum. They may later be promoted into a main notebook when they become necessary prerequisites for a larger module.

## Studies

- `how_tokenization_works.ipynb`: text to subword pieces, token IDs, masks, and embedding tensors.
- `tokenizer-design-and-determinism.md`: why tokenizers exist, how their vocabularies are learned, and why normal encoding is deterministic.
- `exact-token-trajectories-in-rl-and-opd.md`: why RL must retain sampled token IDs and how token-equivalent text can still create a distillation penalty.
- `flash-attention-memory-and-complexity.md`: how implicit causal masks and tiled exact attention reduce memory traffic without removing dense attention's quadratic arithmetic.
