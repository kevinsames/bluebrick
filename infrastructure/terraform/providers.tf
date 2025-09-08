# Optionally configure a remote backend for shared state
# backend "azurerm" {
#   resource_group_name  = "<rg-for-tfstate>"
#   storage_account_name = "<storageaccount>"
#   container_name       = "tfstate"
#   key                  = "bluebrick.terraform.tfstate"
# }

provider "azurerm" {
  features {}
}

# Hub subscription alias for cross-subscription deployments (Hub & Spoke)
provider "azurerm" {
  alias           = "hub"
  subscription_id = var.hub_subscription_id
}

# Databricks provider can authenticate via PAT (host + token) or Azure auth.
# For simplicity and predictable planning, default to PAT and gate resources
# behind `var.enable_databricks` until the workspace exists.
provider "databricks" {
  host  = var.databricks_host
  token = var.databricks_token
}
