# Azure Data Factory

Use Azure Data Factory (ADF) to ingest raw data into the ADLS `coal` container. For dev, ADF Studio can be linked to this repo for Git authoring.

## Git root (dev)

- Folder: `data-factory/` in this repository (excluded from pre-commit)
- Enable Terraform variables:
  - `enable_adf = true`
  - `enable_adf_github = true`
  - `github_account_name`, `github_repository_name`, `github_branch`, `github_root_folder = data-factory`

## Hub SHIR and linked SHIR

- Hub subscription: ADF hosts a Self‑Hosted Integration Runtime (SHIR)
- Environment (spoke): ADF links a SHIR referencing the hub SHIR resource ID

## Recommended layout

- `data-factory/`
  - `pipeline/`
  - `dataset/`
  - `linkedService/`
  - `trigger/`

## Deployment

- ADF‑only workflow: `.github/workflows/deploy-data-factory.yml` (manual)
- General infra workflow: `.github/workflows/deploy-azure-envs.yml` (manual)

