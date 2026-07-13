# LLM Post-Training and Qualification Exam

This repository is a combined workspace for two connected goals:

1. Learn how large language models are trained, with an emphasis on post-training techniques such as supervised fine-tuning, preference optimization, reinforcement learning, evaluation, and alignment.
2. Prepare for the PhD qualification exam by selecting 5-10 papers with the supervisor (currently targeting five), recording a critical understanding of each paper, synthesizing their shared themes, and preparing both a written report and an oral presentation.

Experiments and reading notes should inform the exam deliverables, while the exam's five-paper structure provides a focused path through the post-training literature.

The concrete milestones and handbook-based exam constraints are recorded in [GOALS.md](GOALS.md).

## Repository layout

- `main.tex`: written qualification-exam report; this is the main file to select in Overleaf.
- `presentation.tex`: Beamer presentation.
- `GOALS.md`: learning goals, deliverables, and qualification-exam requirements.
- `learning_list.md`: the evolving topic map for the LLM training curriculum.
- `notebooks/`: algorithm-focused, executable learning modules.
- `tex/papers/`: structured notes for each of the five papers.
- `references.bib`: shared bibliography for the report and presentation.
- `papers/`: local paper PDFs (ignored by Git to avoid redistributing copyrighted files).
- `notes/`: working reading and learning notes.
- `experiments/`: code and results from post-training exercises.
- `scripts/build.py`: reproducible Tectonic build command.
- `scripts/bootstrap.ps1`: Windows setup for the Python environment and pinned Tectonic binary.

## Local setup (Windows)

Python 3.12 and [Tectonic](https://tectonic-typesetting.github.io/) are used for the local workflow. From PowerShell:

```powershell
# Install Python first if it is not already available.
winget install --id Python.Python.3.12 --exact

# Create .venv and install Tectonic 0.16.9 under .tools/.
powershell -ExecutionPolicy Bypass -File scripts/bootstrap.ps1

# Compile both documents.
.\.venv\Scripts\python.exe scripts/build.py all
```

Generated PDFs are written to `build/main.pdf` and `build/presentation.pdf`. Compile only one target with `scripts/build.py report` or `scripts/build.py presentation`.

GitHub Actions runs the same build for every push and pull request and uploads both PDFs as a workflow artifact.

## Learning notebooks

Install the lightweight CPU training environment into the existing virtual environment:

```powershell
.\.venv\Scripts\python.exe -m pip install -r requirements-learning.txt
```

Open `notebooks/01_transformer_and_sft.ipynb` in a notebook-capable editor and select `.venv` as the kernel. It implements causal multi-head attention and response-masked SFT directly with PyTorch tensors; it does not use Transformers, TRL, datasets, or a training framework.

For the exact VS Code workflow and troubleshooting steps, see `notebooks/README.md`. The repository recommends the official Microsoft Python and Jupyter extensions and points VS Code to the local `.venv` interpreter.

On macOS or Linux, create a Python 3.12 virtual environment, install Tectonic using its official installation instructions, and run:

```bash
python3 -m venv .venv
.venv/bin/python scripts/build.py all
```

The build driver checks `TECTONIC`, then the repository's portable binary, then `PATH`.

## Overleaf workflow

The LaTeX sources use standard packages supported by both Tectonic and Overleaf. Upload or synchronize the repository with Overleaf, choose `main.tex` or `presentation.tex` as the main document, and use the pdfLaTeX compiler. Keep generated `build/` files out of Overleaf and Git.

## Git remote

The repository uses the SSH remote:

```text
git@github.com:yunhzou/qualification_exam_learning.git
```
