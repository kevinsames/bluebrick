# Infrastructure (Terraform)

This repo provisions Azure + Databricks with Terraform.

## Components

- Resource group, storage (ADLS Gen2 with HNS), containers: `coal`, `bronze`, `silver`, `gold`, `metadata`, `logs`, `config`
- Databricks workspace (SKU configurable)
- Optional:
  - Log Analytics + diagnostics
  - Hub-and-Spoke networking (VNets/peerings, Private DNS, Private Endpoints)
  - Databricks VNet injection (public/private subnets + NSGs)
  - Databricks workspace resources (cluster, UC grants, instance pool)
  - Azure Data Factory (ADF) in hub and per environment

## Variables and flags

Key variables (see `infrastructure/terraform/variables.tf`):

- Naming/location: `prefix`, `location`, `tags`
- Workspace: `workspace_sku`, `dbr_version`
- Databricks provider: `databricks_host`, `databricks_token`, `enable_databricks`
- UC examples: `enable_uc`, `uc_catalog`, `uc_schema`
- Hub/Spoke: `enable_hub_spoke`, `hub_address_space`, `spoke_*_address_space`, `enable_vnet_injection`
- Multi-subscription: `hub_subscription_id`
- ADF: `enable_adf`, `enable_adf_github`, `github_*`

## Multi-subscription (Hub & Spoke)

- The default `azurerm` provider targets the Spoke (environment) subscription
- The `azurerm.hub` alias targets the Hub subscription using `hub_subscription_id`
- Workflows select the correct subscription per environment via secrets

## Plans and applies

- General infra: `.github/workflows/deploy-azure-envs.yml` (manual only)
- ADF-only: `.github/workflows/deploy-data-factory.yml` (manual only)

## Outputs

- Storage account and container URLs
- Databricks workspace URL
- ADF names and SHIR resource ID (when enabled)
