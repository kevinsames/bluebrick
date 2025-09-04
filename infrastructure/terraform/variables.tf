variable "prefix" {
  description = "Name prefix for all resources"
  type        = string
  default     = "bluebrick"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "eastus"
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {
    project = "bluebrick"
    env     = "dev"
  }
}

variable "workspace_sku" {
  description = "Databricks workspace SKU (standard or premium)"
  type        = string
  default     = "premium"
}

variable "enable_log_analytics" {
  description = "Create Log Analytics workspace and wire diagnostics"
  type        = bool
  default     = false
}

variable "log_analytics_retention_days" {
  description = "Retention for Log Analytics"
  type        = number
  default     = 30
}

variable "dbr_version" {
  description = "Databricks Runtime version for the sample cluster"
  type        = string
  default     = "14.3.x-scala2.12"
}

variable "enable_databricks" {
  description = "Enable creation of Databricks workspace-level resources (cluster, grants)"
  type        = bool
  default     = false
}

variable "enable_uc" {
  description = "Enable Unity Catalog-related examples (grants). Requires UC to be configured."
  type        = bool
  default     = false
}

variable "enable_instance_pool" {
  description = "Create a sample Databricks instance pool (requires enable_databricks=true)"
  type        = bool
  default     = false
}

variable "uc_catalog" {
  description = "Unity Catalog catalog name for examples"
  type        = string
  default     = "main"
}

variable "uc_schema" {
  description = "Unity Catalog schema name for examples"
  type        = string
  default     = "bluebrick_dev"
}

variable "databricks_host" {
  description = "Databricks workspace URL (https://adb-<id>.<region>.azuredatabricks.net)"
  type        = string
  default     = ""
}

variable "databricks_token" {
  description = "Databricks Personal Access Token (PAT)"
  type        = string
  default     = ""
  sensitive   = true
}

# Multi-subscription support
variable "hub_subscription_id" {
  description = "Azure subscription ID for Hub (shared) resources"
  type        = string
  default     = ""
}

# Azure Data Factory (optional)
variable "enable_adf" {
  description = "Provision Azure Data Factory (one per environment + one in Hub for Integration Runtimes)"
  type        = bool
  default     = false
}

variable "enable_adf_github" {
  description = "Enable GitHub integration for the dev (environment) Data Factory"
  type        = bool
  default     = false
}

variable "github_account_name" {
  description = "GitHub org/user that hosts the repository"
  type        = string
  default     = ""
}

variable "github_repository_name" {
  description = "GitHub repository name"
  type        = string
  default     = "bluebrick"
}

variable "github_branch" {
  description = "GitHub branch for ADF authoring (dev)"
  type        = string
  default     = "main"
}

variable "github_root_folder" {
  description = "Root folder within the repo for ADF code"
  type        = string
  default     = "data-factory"
}

# Hub-and-Spoke Networking (optional)
variable "enable_hub_spoke" {
  description = "Enable Hub-and-Spoke VNets, peering, and private endpoints for storage"
  type        = bool
  default     = false
}

variable "hub_address_space" {
  description = "CIDR for Hub VNet"
  type        = string
  default     = "10.0.0.0/16"
}

variable "spoke_data_address_space" {
  description = "CIDR for Data Spoke VNet (private endpoints)"
  type        = string
  default     = "10.1.0.0/16"
}

variable "spoke_dbx_address_space" {
  description = "CIDR for Databricks Spoke VNet (VNet injection)"
  type        = string
  default     = "10.2.0.0/16"
}

variable "enable_vnet_injection" {
  description = "Inject Databricks workspace into the Databricks Spoke VNet"
  type        = bool
  default     = false
}
