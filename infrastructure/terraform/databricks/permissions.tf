resource "databricks_grants" "uc_catalog_example" {
  count   = var.enable_databricks && var.enable_uc ? 1 : 0
  catalog = var.uc_catalog

  grant {
    principal  = "account users"
    privileges = ["USE_CATALOG"]
  }
}

resource "databricks_grants" "uc_schema_example" {
  count  = var.enable_databricks && var.enable_uc ? 1 : 0
  schema = "${var.uc_catalog}.${var.uc_schema}"

  grant {
    principal  = "account users"
    privileges = ["USE_SCHEMA", "SELECT"]
  }
}

