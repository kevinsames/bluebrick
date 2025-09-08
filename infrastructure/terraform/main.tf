resource "random_string" "suffix" {
  length  = 4
  upper   = false
  lower   = true
  numeric = true
  special = false
}

data "azurerm_client_config" "current" {}

locals {
  # Derive a consistent prefix from project + environment
  prefix = "${var.project}-${var.environment}"
}

resource "azurerm_resource_group" "env_infra" {
  name     = "rg-${local.prefix}-infra"
  location = var.location
  tags     = var.tags
}

# Hub resource group in hub subscription (for shared networking, DNS, etc.)
resource "azurerm_resource_group" "hub" {
  count    = var.enable_hub_spoke ? 1 : 0
  provider = azurerm.hub
  name     = "rg-${var.project}-hub"
  location = var.location
  tags     = merge(var.tags, { environment = "hub", env = "hub" })
}

resource "azurerm_resource_group" "env_shared" {
  name     = "rg-${local.prefix}-shared"
  location = var.location
  tags     = var.tags
}

resource "azurerm_resource_group" "env_app" {
  name     = "rg-${local.prefix}-app"
  location = var.location
  tags     = var.tags
}

resource "azurerm_storage_account" "bluebrick" {
  name                            = substr(replace(lower("st${local.prefix}${random_string.suffix.result}"), "-", ""), 0, 24)
  resource_group_name             = azurerm_resource_group.env_app.name
  location                        = azurerm_resource_group.env_app.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  account_kind                    = "StorageV2"
  https_traffic_only_enabled       = true
  is_hns_enabled                  = true
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  tags                            = var.tags
}

resource "azurerm_storage_container" "raw" {
  name                  = "coal"
  storage_account_name  = azurerm_storage_account.bluebrick.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "bronze" {
  name                  = "bronze"
  storage_account_name  = azurerm_storage_account.bluebrick.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "silver" {
  name                  = "silver"
  storage_account_name  = azurerm_storage_account.bluebrick.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "gold" {
  name                  = "gold"
  storage_account_name  = azurerm_storage_account.bluebrick.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "metadata" {
  name                  = "metadata"
  storage_account_name  = azurerm_storage_account.bluebrick.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "logs" {
  name                  = "logs"
  storage_account_name  = azurerm_storage_account.bluebrick.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "config" {
  name                  = "config"
  storage_account_name  = azurerm_storage_account.bluebrick.name
  container_access_type = "private"
}

resource "azurerm_key_vault" "bluebrick" {
  name                          = "kv-${local.prefix}"
  location                      = azurerm_resource_group.env_shared.location
  resource_group_name           = azurerm_resource_group.env_shared.name
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  sku_name                      = "standard"
  enable_rbac_authorization     = true
  purge_protection_enabled      = true
  soft_delete_retention_days    = 7
  public_network_access_enabled = true
  tags                          = var.tags
}

resource "azurerm_key_vault" "hub" {
  count                         = var.enable_hub_spoke ? 1 : 0
  provider                      = azurerm.hub
  name                          = "kv-${var.project}-hub"
  location                      = azurerm_resource_group.hub[0].location
  resource_group_name           = azurerm_resource_group.hub[0].name
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  sku_name                      = "standard"
  enable_rbac_authorization     = true
  purge_protection_enabled      = true
  soft_delete_retention_days    = 7
  public_network_access_enabled = true
  tags                          = merge(var.tags, { environment = "hub", env = "hub" })
}

resource "azurerm_databricks_workspace" "bluebrick" {
  name                = "dbx-${local.prefix}"
  resource_group_name = azurerm_resource_group.env_app.name
  location            = azurerm_resource_group.env_app.location
  sku                 = var.workspace_sku
  managed_resource_group_name = "databricks-mrg-${local.prefix}"
  tags                = var.tags

  dynamic "custom_parameters" {
    for_each = var.enable_hub_spoke && var.enable_vnet_injection ? [1] : []
    content {
      virtual_network_id = azurerm_virtual_network.spoke_dbx[0].id
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
  name                = "log-${local.prefix}"
  location            = azurerm_resource_group.env_infra.location
  resource_group_name = azurerm_resource_group.env_infra.name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_analytics_retention_days
  tags                = var.tags
}

resource "azurerm_monitor_diagnostic_setting" "dbw" {
  count                      = var.enable_log_analytics ? 1 : 0
  name                       = "diag-dbworkspace"
  target_resource_id         = azurerm_databricks_workspace.bluebrick.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.bluebrick[0].id

  enabled_log {
    category = "accounts"
  }
}

output "resource_group_name" {
  value       = azurerm_resource_group.env_app.name
  description = "Application resource group name (backward-compatible)"
}

output "resource_group_app_name" {
  value       = azurerm_resource_group.env_app.name
  description = "Application resource group name"
}

output "resource_group_shared_name" {
  value       = azurerm_resource_group.env_shared.name
  description = "Shared resource group name (e.g., Key Vault)"
}

output "resource_group_infra_name" {
  value       = azurerm_resource_group.env_infra.name
  description = "Infrastructure resource group name (e.g., VNets, monitoring)"
}

output "storage_account_name" {
  value = azurerm_storage_account.bluebrick.name
}

output "raw_container_url" {
  value = "https://${azurerm_storage_account.bluebrick.name}.blob.core.windows.net/${azurerm_storage_container.raw.name}"
}

output "bronze_container_url" {
  value = "https://${azurerm_storage_account.bluebrick.name}.blob.core.windows.net/${azurerm_storage_container.bronze.name}"
}

output "silver_container_url" {
  value = "https://${azurerm_storage_account.bluebrick.name}.blob.core.windows.net/${azurerm_storage_container.silver.name}"
}

output "gold_container_url" {
  value = "https://${azurerm_storage_account.bluebrick.name}.blob.core.windows.net/${azurerm_storage_container.gold.name}"
}

output "metadata_container_url" {
  value = "https://${azurerm_storage_account.bluebrick.name}.blob.core.windows.net/${azurerm_storage_container.metadata.name}"
}

output "logs_container_url" {
  value = "https://${azurerm_storage_account.bluebrick.name}.blob.core.windows.net/${azurerm_storage_container.logs.name}"
}

output "config_container_url" {
  value = "https://${azurerm_storage_account.bluebrick.name}.blob.core.windows.net/${azurerm_storage_container.config.name}"
}

output "databricks_workspace_url" {
  value = azurerm_databricks_workspace.bluebrick.workspace_url
}

output "key_vault_name" {
  value = azurerm_key_vault.bluebrick.name
}

output "key_vault_uri" {
  value = azurerm_key_vault.bluebrick.vault_uri
}

output "hub_key_vault_name" {
  value = var.enable_hub_spoke ? azurerm_key_vault.hub[0].name : null
}

output "hub_key_vault_uri" {
  value = var.enable_hub_spoke ? azurerm_key_vault.hub[0].vault_uri : null
}

# Azure Data Factory: one per environment (spoke) and one in Hub for Integration Runtimes
resource "azurerm_data_factory" "env" {
  count               = var.enable_adf ? 1 : 0
  name                = "adf-${local.prefix}"
  location            = azurerm_resource_group.env_app.location
  resource_group_name = azurerm_resource_group.env_app.name
  tags                = var.tags

  identity {
    type = "SystemAssigned"
  }

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
  name                = "adf-${var.project}-hub"
  location            = azurerm_resource_group.hub[0].location
  resource_group_name = azurerm_resource_group.hub[0].name
  tags                = merge(var.tags, { environment = "hub", env = "hub" })

  identity {
    type = "SystemAssigned"
  }
}

 


output "adf_env_name" {
  value       = var.enable_adf ? azurerm_data_factory.env[0].name : null
  description = "Environment (spoke) Data Factory name"
}

output "adf_hub_name" {
  value       = var.enable_adf ? azurerm_data_factory.hub[0].name : null
  description = "Hub Data Factory name"
}

 
