# CI/CD Workflows

This repo uses GitHub Actions. All workflows live under `.github/workflows/`.

## Workflows

- `ci.yml`
  - Runs on push/PR to `main`
  - Sets up Python + Java 11, installs deps
  - Lints with Ruff, checks formatting with Black, runs pytest

- `deploy-azure-envs.yml` (manual only)
  - Input `environment`: `hub|dev|test|prod`
  - Selects subscription via secrets and runs Terraform `init`, `fmt`, `validate`, `plan`, optional `apply`

- `deploy-data-factory.yml` (manual only)
  - Input `environment`: `hub|dev|test|prod`
  - Sets `TF_VAR_enable_adf=true`
  - For `dev`, enables ADF GitHub integration to this repository at `data-factory/`

- `deploy-databricks-dev.yml`
  - Triggers on push to `main` when `src/**` or `databricks.yml` changes
  - Deploys the Databricks Asset Bundle to target `dev` and runs `bluebrick-quickstart`

- `deploy-databricks.yml`
  - Triggers on tag push or release publish
  - Deploys the bundle to target `release`, using the Git tag as the source

## Required secrets

- Azure: `ARM_CLIENT_ID`, `ARM_TENANT_ID`, subscription IDs per environment
- Databricks: `DATABRICKS_HOST`, `DATABRICKS_TOKEN`

