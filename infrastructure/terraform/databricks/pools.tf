resource "databricks_instance_pool" "bluebrick_pool" {
  count                         = var.enable_databricks && var.enable_instance_pool ? 1 : 0
  instance_pool_name            = "bluebrick-pool"
  min_idle_instances            = 0
  max_capacity                  = 5
  idle_instance_autotermination_minutes = 15

  azure_attributes {
    availability        = "ON_DEMAND_AZURE"
    first_on_demand     = 1
    spot_bid_max_price  = -1
  }

  node_type_id = "Standard_DS3_v2"
}

