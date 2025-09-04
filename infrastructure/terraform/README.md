# BlueBrick Terraform

This Terraform stack provisions a minimal Azure + Databricks foundation for the
BlueBrick template:

- Azure Resource Group
- Azure Data Lake Storage Gen2 (StorageV2 with HNS), containers: `coal` (raw landing), `silver` (optional)
- Azure Databricks Workspace (SKU configurable)
- Optional: Log Analytics + Diagnostic Settings
- Optional: Databricks workspace-level resources (cluster, example UC grants)
- Optional: Hub-and-Spoke networking with VNet peering and Storage private endpoints
- Optional: Azure Data Factory (one per environment + one in Hub for Integration Runtimes)

Notes
- Databricks workspace-level resources are behind a feature flag (`enable_databricks`)
  and require authenticating the Databricks provider (either via PAT or Azure auth).
- Consider using a remote backend for state. A sample block is commented in `providers.tf`.

Usage
1. Export or configure Azure credentials for Terraform (Service Principal):
   - `ARM_CLIENT_ID`, `ARM_CLIENT_SECRET`, `ARM_TENANT_ID`, `ARM_SUBSCRIPTION_ID`
2. (Optional) Provide Databricks auth via variables or environment:
   - `TF_VAR_databricks_host`, `TF_VAR_databricks_token`
3. Initialize and plan:
   ```bash
   terraform -chdir=infrastructure/terraform init
   terraform -chdir=infrastructure/terraform plan -var-file=examples/terraform.tfvars.example
   ```
4. Apply (when ready):
   ```bash
  terraform -chdir=infrastructure/terraform apply -var-file=examples/terraform.tfvars.example

Multi-subscription (Hub & Spoke)
- Use a single Service Principal with RBAC in all subscriptions (Hub + each Spoke env).
- Login once in CI (`azure/login`) with any env’s subscription; the Terraform azurerm provider alias handles the Hub subscription.
- Provide `hub_subscription_id` via tfvars. The default (spoke) subscription comes from `ARM_SUBSCRIPTION_ID`.
- For multiple environments (one subscription per environment), run Terraform per environment, changing `ARM_SUBSCRIPTION_ID` and any env-specific vars (e.g., `tags.env`).

Hub-and-Spoke (optional)
- Toggle `enable_hub_spoke = true` to create:
  - Hub VNet, Data Spoke VNet (with a subnet for private endpoints), Databricks Spoke VNet
  - VNet peering between Hub ↔ Data and Hub ↔ Databricks
  - Private DNS zones (`privatelink.blob.core.windows.net`, `privatelink.dfs.core.windows.net`) linked to Hub and Data Spoke
  - Private Endpoints for the storage account (Blob + DFS) in the Data Spoke
- Enable `enable_vnet_injection = true` to inject the Databricks workspace into the Databricks Spoke
  - Two subnets are created (`dbx-public`, `dbx-private`) with required delegations and NSGs
  - Workspace `custom_parameters` is set automatically
  - Note: You may need to review NSG rules per your security requirements

Azure Data Factory (optional)
- Toggle `enable_adf = true` to provision:
  - An ADF in the environment (spoke) subscription
  - An ADF in the Hub subscription
  - A Self-hosted Integration Runtime (SHIR) in the Hub ADF
  - A linked Self-hosted IR in the environment ADF referencing the Hub SHIR
- You can install SHIR nodes on your network using the keys from the Hub SHIR resource in the Azure Portal.

Data Layers
- Coal: Raw, 1:1 persistence of source data. Stored under the `coal` container, with one folder per ingestion tool (e.g., `adf/`, `lakeflow/`, `upload/`). Define a data contract per data source.
- Bronze: Unity Catalog managed Delta tables. Append-only; no deletes. 1:1 with coal artifacts but typed, deduplicated, with metadata columns. Optionally preserve history (SCD2).
- Silver: Unity Catalog managed Delta tables enriched with business logic and standardization.
- Gold: Unity Catalog managed Delta tables serving downstream use cases; one schema per use case with read/write permissions per interface contract.
   ```
