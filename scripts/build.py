"""Compile the qualification-exam documents with Tectonic."""

from __future__ import annotations

import argparse
import os
from pathlib import Path
import shutil
import subprocess
import sys


ROOT = Path(__file__).resolve().parents[1]
BUILD_DIR = ROOT / "build"
DOCUMENTS = {
    "report": ROOT / "main.tex",
    "presentation": ROOT / "presentation.tex",
    "hinted-sft-proposal": ROOT / "hinted_sft_proposal.tex",
}


def find_tectonic() -> str:
    candidates = [
        os.environ.get("TECTONIC"),
        str(ROOT / ".tools" / "tectonic" / "tectonic.exe"),
        str(ROOT / ".tools" / "tectonic" / "tectonic"),
        shutil.which("tectonic"),
    ]
    for candidate in candidates:
        if candidate and Path(candidate).is_file():
            return candidate
    raise FileNotFoundError(
        "Tectonic was not found. On Windows run scripts/bootstrap.ps1, "
        "or install Tectonic and add it to PATH."
    )


def compile_document(tectonic: str, source: Path) -> None:
    BUILD_DIR.mkdir(exist_ok=True)
    command = [
        tectonic,
        "--keep-logs",
        "--synctex",
        "--outdir",
        str(BUILD_DIR),
        str(source),
    ]
    print(f"Compiling {source.name}...", flush=True)
    subprocess.run(command, cwd=ROOT, check=True)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "target",
        nargs="?",
        choices=["all", *DOCUMENTS],
        default="all",
        help="document to build (default: all)",
    )
    args = parser.parse_args()

    try:
        tectonic = find_tectonic()
        targets = DOCUMENTS.values() if args.target == "all" else [DOCUMENTS[args.target]]
        for source in targets:
            compile_document(tectonic, source)
    except (FileNotFoundError, subprocess.CalledProcessError) as error:
        print(f"error: {error}", file=sys.stderr)
        return 1

    print(f"PDF output: {BUILD_DIR}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
