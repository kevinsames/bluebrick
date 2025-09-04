# Configuration

## App configuration

- Files under `configs/*.yaml` control catalog/schema/table and sample paths
- Selection precedence:
  1. Databricks widget `bluebrick_env` (if present)
  2. Env var `BLUEBRICK_ENV`
  3. Default: `dev`

## Secrets

Set as GitHub Actions secrets:

- Azure: `ARM_CLIENT_ID`, `ARM_TENANT_ID`, (optional) `ARM_CLIENT_SECRET`
- Subscriptions: `HUB_SUBSCRIPTION_ID`, `ARM_SUBSCRIPTION_ID_DEV`, `ARM_SUBSCRIPTION_ID_TEST`, `ARM_SUBSCRIPTION_ID_PROD`
- Databricks: `DATABRICKS_HOST`, `DATABRICKS_TOKEN`

Optional Terraform `TF_VAR_*` inputs for customization (examples file under `infrastructure/terraform/examples/`).

