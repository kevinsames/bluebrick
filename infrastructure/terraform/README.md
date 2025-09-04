# BlueBrick Terraform

This Terraform stack provisions a minimal Azure + Databricks foundation for the
BlueBrick template:

- Azure Resource Group
- Azure Data Lake Storage Gen2 (StorageV2 with HNS), containers: `raw`, `silver`
- Azure Databricks Workspace (SKU configurable)
- Optional: Log Analytics + Diagnostic Settings
- Optional: Databricks workspace-level resources (cluster, example UC grants)

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
   ```

