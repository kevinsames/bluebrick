# Local development

## Setup

- Python: 3.10+ (tested on 3.10 and 3.12)
- Java: JDK 11 (`java -version` should show 11.x)
- Create venv and install deps:
  - macOS/Linux: `python -m venv .venv && source .venv/bin/activate`
  - Windows: `python -m venv .venv; .\\.venv\\Scripts\\Activate.ps1`
  - `pip install -r requirements.txt`

## Lint/Test

- Lint: `ruff src tests`
- Format check: `black --check --line-length 100 .`
- Tests: `pytest -q`
- Pre-commit: `pre-commit install` then commit; run on all files with `pre-commit run --all-files`

## Notebooks

- Install Jupyter via requirements
- Launch: `jupyter notebook` and open `src/notebooks/00_quickstart_etl.ipynb`

