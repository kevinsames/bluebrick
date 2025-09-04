# Architecture

## Azure Hub-and-Spoke

- Hub subscription: shared networking resources (Hub VNet, Private DNS zones, optional firewall)
- Spoke subscriptions: one per environment (dev/test/prod)
- Optional features in Terraform:
  - Hub/Spoke VNets and peerings
  - Private Endpoints for ADLS Gen2 (Blob + DFS)
  - VNet injection for Databricks workspace into a Spoke VNet

## Data Layers (CSG: Coal → Bronze → Silver → Gold)

- Coal
  - Raw, 1:1 persistence of source data (no transforms)
  - One folder per ingestion tool (e.g., `coal/adf`, `coal/lakeflow`, `coal/upload`)
  - Data contracts per source (formats, naming, partitioning, delivery guarantees)
- Bronze (UC managed Delta)
  - Append-only (never delete) with types, deduplication, metadata columns
  - 1:1 with Coal artifacts; optional SCD2 history retention on demand
- Silver (UC managed Delta)
  - Business logic enrichment and standardization for analytics and ML
- Gold (UC managed Delta)
  - Interfaces for downstream use cases
  - One schema per use case; read/write permissions per interface contract

## Identity and secrets

- Azure auth via OIDC (GitHub Actions `azure/login`)
- Databricks auth via `DATABRICKS_HOST` and `DATABRICKS_TOKEN`
- Store ADLS credentials in Key Vault–backed Databricks secret scopes or use Managed Identity

