# Databricks workspace-scoped data/resources (optional)

data "databricks_current_user" "me" {
  count = var.enable_databricks ? 1 : 0
}

