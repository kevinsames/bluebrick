# Quickstart

Follow these steps to provision Azure, deploy Databricks assets, and run the example ETL in under 30 minutes.

## Prerequisites

- Azure subscription(s) and a Service Principal with Contributor in target subs
- Databricks workspace or permissions to create one via Terraform
- Python 3.10+ (tested on 3.10 and 3.12 with Spark 3.5.x)
- JDK 11 installed and `JAVA_HOME` set
- GitHub repository with the following secrets set:
  - `ARM_CLIENT_ID`, `ARM_TENANT_ID`, (optional: `ARM_CLIENT_SECRET` if not using OIDC)
  - `ARM_SUBSCRIPTION_ID` (or environment‑specific IDs for multi‑sub)
  - `DATABRICKS_HOST`, `DATABRICKS_TOKEN`

## Local setup

- Create a venv and install deps
  - macOS/Linux: `python -m venv .venv && source .venv/bin/activate`
  - Windows: `python -m venv .venv; .\.venv\Scripts\Activate.ps1`
  - Install: `pip install -r requirements.txt`
- Optional: Jupyter
  - Launch: `jupyter notebook` and open `src/notebooks/00_quickstart_etl.ipynb`

## Provision Azure with Terraform

- From GitHub Actions, run workflow: `Deploy Azure (Hub/Envs)`
  - Choose environment (dev/test/prod or hub)
  - Set `apply=true` when ready to apply
- Or locally:
  - `terraform -chdir=infrastructure/terraform init`
  - `terraform -chdir=infrastructure/terraform plan -var-file=infrastructure/terraform/examples/terraform.tfvars.example`
  - `terraform -chdir=infrastructure/terraform apply -var-file=infrastructure/terraform/examples/terraform.tfvars.example`

## Deploy Databricks assets

- Dev (main branch): workflow `Deploy Databricks (dev)` triggers on changes to `src/**` on main
- Release (tags): workflow `Deploy Databricks (release)` triggers on tag pushes; deploys code at the tag

## Run the example

- In Databricks, view job `bluebrick-quickstart` and open the latest run
- Verify the managed Unity Catalog table exists and returns counts and schema as expected

## Validate locally

- Lint: `ruff src tests` and `black --check --line-length 100 .`
- Test: `pytest -q`

