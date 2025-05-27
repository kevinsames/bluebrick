# main.tf
provider "azurerm" {
    features {}
}

provider "databricks" {
    alias = "workspace"
    host  = var.databricks_host
    token = var.databricks_token
}

module "databricks" {
    source = "./modules/databricks"
    # variables: workspace_name, resource_group, etc.
}