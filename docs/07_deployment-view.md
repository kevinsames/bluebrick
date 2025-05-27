# 07. Deployment View

The deployment view describes the physical and cloud environment topology for this solution. The key infrastructure components and how they are deployed in Azure are as follows:

- **Azure Resource Group:**  
  All Azure resources can be contained in a single Resource Group (e.g., `rg-mlops-template-dev` for a dev environment). The Terraform in `/infra` is responsible for provisioning this (or expects it to exist). There could be separate resource groups per environment (dev, staging, prod) to isolate resources and permissions.

- **Azure Databricks Workspace:**  
  The central compute platform, created as an Azure resource of type `Microsoft.Databricks/workspaces`. Terraform configures this with required parameters:
  - Workspace name (e.g., `adb-mlops-dev`), region (same as storage), and pricing tier (Standard/Premium; Premium is needed for Unity Catalog or advanced security).
  - If required, VNet injection is configured so the workspace uses a customer-managed Virtual Network and subnets. Network peering or NAT may be set up to allow private communication with the storage account.
  - The workspace comes with a managed resource group (created by Databricks) containing the actual VMs, but these are abstracted away from users. The workspace is accessed via its service endpoint URL.

- **Azure Data Lake Storage Gen2 (Storage Account):**  
  Terraform creates a Storage Account (e.g., `stmlopsdev001`) with Hierarchical Namespace enabled. Within it, containers are created (e.g., `raw-data`, `curated-data`, `models`). This storage is used for:
  - Raw input data (e.g., NYC Taxi trip records).
  - Processed data or Delta tables.
  - MLflow artifacts (if using the default Databricks tracking server, artifacts are stored in DBFS, which is backed by blob storage).
  - Access policies ensure either the Databricks workspace’s managed identity or a dedicated service principal is granted the necessary roles (Blob Storage Contributor, etc.). Unity Catalog external locations or legacy DBFS mounts are supported, depending on configuration.

- **Azure AD Service Principals / Managed Identities:**  
  - A Terraform Azure AD service principal (or OIDC workload identity) is used by GitHub Actions to deploy infrastructure, typically with Contributor role on the subscription or resource group.
  - A Databricks access identity: either a service principal for data access (credentials stored in Databricks Secret Scope) or a managed identity for Unity Catalog. The template supports both patterns.
  - GitHub OIDC can be used for secure, short-lived credentials in CI/CD pipelines.

- **Network Topology:**  
  Optionally, the Databricks workspace can be deployed in a secure network using VNet Injection. Terraform can create or use an existing VNet and subnets. The storage account can have network rules allowing access only from the Databricks VNet or via Private Endpoint, ensuring data does not traverse the public internet. The default template uses public networking for simplicity but documents how to enable private networking.

- **Unity Catalog Metastore (optional):**  
  For governance, a Unity Catalog metastore can be deployed and linked to the workspace. Terraform can register a new metastore and attach it to the workspace. When enabled, all data access can go through Unity Catalog tables and external locations, with configuration managed as code.

- **Physical Deployment Separation:**  
  For dev, staging, and prod, separate resource groups, workspaces, and storage accounts can be used (e.g., `rg-mlops-dev` with `adb-mlops-dev` and `datalake_dev`; `rg-mlops-prod` with `adb-mlops-prod` and `datalake_prod`). Each environment has its own service principals and configuration. The repository supports this via separate Terraform state or variable files and separate GitHub environments or branches.

- **GitHub Repository & Actions:**  
  The GitHub repository integrates with Azure via credentials provided to GitHub Actions. Actions runners are ephemeral VMs that communicate with Azure Databricks (REST API) and Azure (ARM API for Terraform). No permanent CI/CD server is needed.

---

**Summary:**  
The deployment consists of Azure Databricks, Azure Storage, and Azure AD identities, all wired together. Databricks acts as the compute layer, data persists in ADLS Gen2, and all components are in the same Azure region for efficiency. Managed services are leveraged, so no VMs are maintained directly except for transient build agents. The template’s Terraform scripts make deploying this infrastructure straightforward and uniform across environments.

**Scalability & Availability:**  
Azure Databricks is a PaaS service with SLAs, and ADLS is highly durable. The system is designed for cloud scale—cluster sizes and job concurrency can be adjusted via configuration. The deployment easily scales from dev/test to production by adjusting Terraform or job configs, without changing the code structure.