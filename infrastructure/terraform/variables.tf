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
  default     = "13.3.x-scala2.12"
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

