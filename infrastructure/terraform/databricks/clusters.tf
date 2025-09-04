resource "databricks_cluster" "bluebrick_dev" {
  count                   = var.enable_databricks ? 1 : 0
  cluster_name            = "bluebrick-dev"
  spark_version           = var.dbr_version
  node_type_id            = "Standard_DS3_v2"
  autotermination_minutes = 30
  num_workers             = 2
  data_security_mode      = "SINGLE_USER"

  # single_user_name may be required in strict UC environments; set explicitly if needed
  # single_user_name = data.databricks_current_user.me[0].user_name
}

