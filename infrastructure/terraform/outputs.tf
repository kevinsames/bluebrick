output "workspace_id" {
  value = azurerm_databricks_workspace.bluebrick.id
}

output "workspace_url" {
  value = azurerm_databricks_workspace.bluebrick.workspace_url
}

output "storage_account_id" {
  value = azurerm_storage_account.bluebrick.id
}

