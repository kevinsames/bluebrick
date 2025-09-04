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
}

resource "azurerm_resource_group" "bluebrick" {
  name     = local.rg_name
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

