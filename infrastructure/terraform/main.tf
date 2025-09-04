resource "random_string" "suffix" {
  length  = 4
  upper   = false
  lower   = true
  numeric = true
  special = false
}

locals {
  rg_name   = "rg-${var.prefix}"
  sa_name   = substr(replace(lower("st${var.prefix}${random_string.suffix.result}"), "-", ""), 0, 24)
  la_name   = "law-${var.prefix}"
  wb_name   = "dbw-${var.prefix}"
  raw_name  = "raw"
  silver_name = "silver"
  adf_env_name = "adf-${var.prefix}"
  adf_hub_name = "adf-${var.prefix}-hub"
}

resource "azurerm_resource_group" "bluebrick" {
  name     = local.rg_name
  location = var.location
  tags     = var.tags
}

# Hub resource group in hub subscription (for shared networking, DNS, etc.)
resource "azurerm_resource_group" "hub" {
  count    = var.enable_hub_spoke ? 1 : 0
  provider = azurerm.hub
  name     = "rg-${var.prefix}-hub"
  location = var.location
  tags     = var.tags
}

resource "azurerm_storage_account" "bluebrick" {
  name                            = local.sa_name
  resource_group_name             = azurerm_resource_group.bluebrick.name
  location                        = azurerm_resource_group.bluebrick.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  account_kind                    = "StorageV2"
  enable_https_traffic_only       = true
  is_hns_enabled                  = true
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  tags                            = var.tags
}

resource "azurerm_storage_container" "raw" {
  name                  = local.raw_name
  storage_account_name  = azurerm_storage_account.bluebrick.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "silver" {
  name                  = local.silver_name
  storage_account_name  = azurerm_storage_account.bluebrick.name
  container_access_type = "private"
}

resource "azurerm_databricks_workspace" "bluebrick" {
  name                = local.wb_name
  resource_group_name = azurerm_resource_group.bluebrick.name
  location            = azurerm_resource_group.bluebrick.location
  sku                 = var.workspace_sku
  tags                = var.tags

  dynamic "custom_parameters" {
    for_each = var.enable_hub_spoke && var.enable_vnet_injection ? [1] : []
    content {
      vnet_address_prefix = var.spoke_dbx_address_space
      public_subnet_name  = azurerm_subnet.dbx_public[0].name
      private_subnet_name = azurerm_subnet.dbx_private[0].name
      public_subnet_network_security_group_association_id  = azurerm_subnet_network_security_group_association.dbx_public[0].id
      private_subnet_network_security_group_association_id = azurerm_subnet_network_security_group_association.dbx_private[0].id
    }
  }
}

resource "azurerm_log_analytics_workspace" "bluebrick" {
  count               = var.enable_log_analytics ? 1 : 0
  name                = local.la_name
  location            = azurerm_resource_group.bluebrick.location
  resource_group_name = azurerm_resource_group.bluebrick.name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_analytics_retention_days
  tags                = var.tags
}

resource "azurerm_monitor_diagnostic_setting" "dbw" {
  count                      = var.enable_log_analytics ? 1 : 0
  name                       = "diag-dbworkspace"
  target_resource_id         = azurerm_databricks_workspace.bluebrick.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.bluebrick[0].id

  log {
    category = "accounts"
    enabled  = true
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

output "resource_group_name" {
  value = azurerm_resource_group.bluebrick.name
}

output "storage_account_name" {
  value = azurerm_storage_account.bluebrick.name
}

output "raw_container_url" {
  value = "https://${azurerm_storage_account.bluebrick.name}.blob.core.windows.net/${azurerm_storage_container.raw.name}"
}

output "silver_container_url" {
  value = "https://${azurerm_storage_account.bluebrick.name}.blob.core.windows.net/${azurerm_storage_container.silver.name}"
}

output "databricks_workspace_url" {
  value = azurerm_databricks_workspace.bluebrick.workspace_url
}

# Azure Data Factory: one per environment (spoke) and one in Hub for Integration Runtimes
resource "azurerm_data_factory" "env" {
  count               = var.enable_adf ? 1 : 0
  name                = local.adf_env_name
  location            = azurerm_resource_group.bluebrick.location
  resource_group_name = azurerm_resource_group.bluebrick.name
  tags                = var.tags

  dynamic "github_configuration" {
    for_each = var.enable_adf && var.enable_adf_github && var.github_account_name != "" ? [1] : []
    content {
      account_name    = var.github_account_name
      branch_name     = var.github_branch
      repository_name = var.github_repository_name
      root_folder     = var.github_root_folder
      git_url         = "https://github.com"
    }
  }
}

resource "azurerm_data_factory" "hub" {
  count               = var.enable_adf ? 1 : 0
  provider            = azurerm.hub
  name                = local.adf_hub_name
  location            = azurerm_resource_group.hub[0].location
  resource_group_name = azurerm_resource_group.hub[0].name
  tags                = var.tags
}

resource "azurerm_data_factory_integration_runtime_self_hosted" "hub_shir" {
  count          = var.enable_adf ? 1 : 0
  name           = "shir-${var.prefix}"
  data_factory_id = azurerm_data_factory.hub[0].id
  description    = "Self-hosted IR registered in Hub ADF for cross-env use"
}

resource "azurerm_data_factory_integration_runtime_self_hosted" "env_linked_shir" {
  count          = var.enable_adf ? 1 : 0
  name           = "shir-linked-${var.prefix}"
  data_factory_id = azurerm_data_factory.env[0].id
  description    = "Linked Self-hosted IR referencing Hub ADF IR"
  linked_self_hosted_integration_runtime_id = azurerm_data_factory_integration_runtime_self_hosted.hub_shir[0].id
}

output "adf_env_name" {
  value       = var.enable_adf ? azurerm_data_factory.env[0].name : null
  description = "Environment (spoke) Data Factory name"
}

output "adf_hub_name" {
  value       = var.enable_adf ? azurerm_data_factory.hub[0].name : null
  description = "Hub Data Factory name"
}

output "adf_hub_shir_id" {
  value       = var.enable_adf ? azurerm_data_factory_integration_runtime_self_hosted.hub_shir[0].id : null
  description = "Resource ID of the Hub Self-hosted Integration Runtime"
}
