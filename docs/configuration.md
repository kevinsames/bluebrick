# Configuration

## App configuration

- Files under `configs/*.yaml` control catalogs, schema/table, and sample paths
- Use a top-level `catalogs` map per environment to define Unity Catalog catalogs
  for each data layer, for example (dev):

  ```yaml
  catalogs:
    coal: coal_dev
    bronze: bronze_dev
    silver: silver_dev
    gold: gold_dev
    metadata: metadata_dev
    logs: logs_dev
    config: config_dev
  schema: bluebrick
  table: example_sales
  ```

- The app derives a default `catalog` from `catalogs.bronze` for sample notebooks.

### Paths per data layer

Instead of a single `raw_path`, define explicit paths per layer. Example (dev):

```yaml
adls_account: "<adls-account-name>"
coal_path: "abfss://coal@<adls-account-name>.dfs.core.windows.net/sales/"
bronze_path: "abfss://bronze@<adls-account-name>.dfs.core.windows.net/sales_bronze/"
silver_path: "abfss://silver@<adls-account-name>.dfs.core.windows.net/sales_silver/"
gold_path: "abfss://gold@<adls-account-name>.dfs.core.windows.net/sales_gold/"
metadata_path: "abfss://metadata@<adls-account-name>.dfs.core.windows.net/metadata/"
logs_path: "abfss://logs@<adls-account-name>.dfs.core.windows.net/logs/"
config_path: "abfss://config@<adls-account-name>.dfs.core.windows.net/config/"
```

The app no longer uses `adls_container`; use the per-layer paths above.
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
