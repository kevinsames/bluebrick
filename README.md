BlueBrick: Azure Databricks Template (Terraform + GitHub Actions)
===============================================================

BlueBrick is a production-ready GitHub template repository for Azure Databricks projects. It provides:

- Clean repo structure for Databricks on Azure
- Terraform infrastructure (RG, ADLS Gen2, Databricks Workspace, optional diagnostics)
- A minimal PySpark ETL notebook that writes a Delta table in Unity Catalog
- GitHub Actions for CI (lint/test), Terraform plan/apply, and Databricks deployment
- Clear environment separation and configuration via YAML (no secrets in code)

Why “BlueBrick”? Azure is blue, Databricks are the “bricks”, and this repo is your blueprint.


Quick Start (30 minutes)
-----------------------
1) Fork the repo and clone locally.

2) Create a Python virtual environment named `.venv` (optional, recommended):
- macOS/Linux:
  - `python -m venv .venv && source .venv/bin/activate`
- Windows PowerShell:
  - `python -m venv .venv; .\.venv\Scripts\Activate.ps1`
- Install deps:
  - `pip install -r requirements.txt`

3) Configure GitHub Secrets (Repository settings → Secrets and variables → Actions):
- ARM_CLIENT_ID, ARM_CLIENT_SECRET, ARM_TENANT_ID, ARM_SUBSCRIPTION_ID
- DATABRICKS_HOST, DATABRICKS_TOKEN

4) Provision Infra (Terraform):
- Run the workflow “Terraform Plan / Apply (Infra)” → Run workflow.
- Optionally set `apply=true` to apply via a protected “production” environment reviewer.
- Or run locally:
  - `terraform -chdir=infrastructure/terraform init`
  - `terraform -chdir=infrastructure/terraform plan -var-file=infrastructure/terraform/examples/terraform.tfvars.example`
  - `terraform -chdir=infrastructure/terraform apply -var-file=infrastructure/terraform/examples/terraform.tfvars.example`

5) Deploy Notebooks to Databricks:
- Run the workflow “Deploy Databricks Artifacts”.
- It uploads `src/notebooks` and `configs` to `/Users/<you>/bluebrick` in the workspace.
- It creates/updates a job named `bluebrick-quickstart` and triggers a run.

6) Verify in Unity Catalog:
- The notebook writes `main.bluebrick_dev.example_sales` by default (env = dev).
- In a SQL cell (or Data Explorer), run:
  - `SELECT count(*) FROM main.bluebrick_dev.example_sales;`
  - `DESCRIBE TABLE main.bluebrick_dev.example_sales;`


Configuration and Environments
------------------------------
- YAML files live under `configs/*.yaml` and include catalog/schema/table and sample storage paths.
- The loader uses:
  1. Databricks widget `bluebrick_env` (if present)
  2. `BLUEBRICK_ENV` environment variable
  3. Default: `dev`
- Example files: `configs/dev.yaml`, `configs/test.yaml`, `configs/prod.yaml`.


Local Development
-----------------
- Python 3.10+
- Optional: create a virtual environment
  - `python -m venv .venv && source .venv/bin/activate`
  - `pip install -r requirements.txt`
- Lint:
  - `ruff src tests`
  - `black --check --line-length 100 .`
- Test:
  - `pytest -q`

Note: Local tests use a lightweight Spark session (pyspark). Java is required on your machine.


CI/CD Overview
--------------
- `.github/workflows/ci.yml`: Runs on push/PR. Sets up Python, installs deps, runs ruff, black --check, and pytest.
- `.github/workflows/plan_apply_infra.yml`: On push to Terraform paths and on manual dispatch. Performs `terraform fmt`, `validate`, `plan` (artifacts uploaded). `apply` when manually requested and protected by the `production` environment.
- `.github/workflows/deploy_databricks.yml`: On main and on demand. Auths to Databricks via `DATABRICKS_HOST`/`DATABRICKS_TOKEN`, uploads notebooks and configs, and creates/triggers a simple job to run the quickstart notebook.


Infrastructure (Terraform)
--------------------------
Files under `infrastructure/terraform/`:
- `providers.tf`: azurerm + databricks providers; includes commented remote state example
- `variables.tf`: prefix, location, tags, workspace SKU, UC flags, etc.
- `main.tf`: resource group, ADLS Gen2 (HNS=true) with `raw` and `silver` containers, Databricks workspace, optional diagnostics → Log Analytics
- `databricks/*`: workspace-scoped examples (cluster, UC grants) gated by `enable_databricks` and `enable_uc`
- `examples/terraform.tfvars.example`: sane defaults to get started

Provider auth notes:
- Azure: use GitHub OIDC via `azure/login@v2` (as in workflow) or export ARM_ env vars locally
- Databricks: by default we use host + PAT via variables; set `enable_databricks=true` to create cluster/grants after the workspace exists


Sample Notebook (PySpark + SQL)
-------------------------------
File: `src/notebooks/00_quickstart_etl.py`
- Reads config (`BLUEBRICK_ENV` or widget)
- Builds a tiny in-memory dataset, cleans it using `bluebrick.transformations.clean_sales`, and writes Delta to `catalog.schema.table` via Unity Catalog
- Runs 2 simple SQL checks (counts + schema)


Secrets and Configuration
-------------------------
Required GitHub Secrets:
- ARM_CLIENT_ID, ARM_CLIENT_SECRET, ARM_TENANT_ID, ARM_SUBSCRIPTION_ID (Terraform Azure auth)
- DATABRICKS_HOST, DATABRICKS_TOKEN (Databricks CLI auth for deploy)

Optional Terraform variables (as secrets or `tfvars`):
- TF_VAR_prefix, TF_VAR_location, TF_VAR_enable_databricks, TF_VAR_databricks_host, TF_VAR_databricks_token, TF_VAR_enable_uc, etc.

Databricks secrets for storage access: use a Key Vault–backed secret scope or Managed Identity. Do not hardcode credentials.


Acceptance Criteria Mapping
---------------------------
1. Unit tests: `tests/test_transformations.py` validates deterministic transforms; runs in CI
2. Lint: `ruff` and `black --check` pass in CI
3. Terraform: `validate` passes; `plan` runs with example tfvars in workflow
4. Notebook: writes a Delta table to UC (`catalog.schema.table`) and verifies with follow-up SQL
5. CI pipelines: green on a fresh fork with secrets configured
6. Quickstart: end-to-end from fork → infra → run → verify in ~30 minutes


License
-------
MIT. See `LICENSE`.
