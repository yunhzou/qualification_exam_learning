# Running the learning notebooks in VS Code

## One-time setup

From the repository root in PowerShell:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/bootstrap.ps1
.\.venv\Scripts\python.exe -m pip install -r requirements-learning.txt
```

Install the recommended Microsoft **Python** and **Jupyter** extensions when VS Code prompts. They are recorded in `.vscode/extensions.json`.

## Select the project kernel

1. Open the repository folder itself in VS Code, not only the notebook file.
2. Open `notebooks/01_transformer_and_sft.ipynb`.
3. Click **Select Kernel** in the notebook's upper-right corner.
4. Choose **Python Environments** and then the interpreter under this repository's `.venv` directory. On Windows it ends in `.venv\Scripts\python.exe`.
5. Run the first cell and verify that it prints a CPU PyTorch version.
6. Use **Run All** to execute the complete notebook from a clean kernel.

The named kernel **Python (.venv - qualification exam)** may also appear in the picker when it has been registered on the current machine. Prefer the `.venv` interpreter if both choices appear; they point to the same environment.

## Troubleshooting

- If `.venv` does not appear, run **Python: Select Interpreter** from the Command Palette and choose `.venv\Scripts\python.exe`, then reopen the kernel picker.
- If imports fail, rerun the `pip install -r requirements-learning.txt` command using the `.venv` Python shown above. Do not install packages into the Windows Store Python alias.
- If the kernel is stale after installing dependencies, use **Restart Kernel** and then **Run All**.
- The notebook is CPU-only. CUDA, Transformers, TRL, and external model downloads are not required.

## Notebook sequence

1. `01_transformer_and_sft.ipynb`: decoder-only Transformer mechanics and response-masked SFT.
2. `02_deepseek_r1_grpo.ipynb`: DeepSeek-R1-inspired grouped rollouts, verifiable rewards, and GRPO.
3. `03_on_policy_distillation.ipynb`: Thinking Machines Lab-inspired on-policy distillation and state-distribution coverage.

All notebooks use the same `.venv` kernel and CPU-only dependency set.

## Side studies

`side_studies/` contains small, self-contained notebooks created from individual learning questions. These notebooks are intentionally outside the numbered core curriculum: they preserve useful examples without changing the main post-training sequence.

A side study should focus on one question, include an executable minimal example when appropriate, state the important tensor shapes or algorithm steps, and end with a short takeaway. Create one when it is explicitly requested rather than converting every discussion into a notebook.
