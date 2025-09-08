###############################################
# Hub-and-Spoke Networking (optional)
###############################################

locals {
  # Hub VNet name should not include environment or use the computed prefix
  hub_name         = "vnet-${var.project}-hub"
  spoke_data_name  = "vnet-${local.prefix}-data"
  spoke_dbx_name   = "vnet-${local.prefix}-dbx"
}

resource "azurerm_virtual_network" "hub" {
  count               = var.enable_hub_spoke ? 1 : 0
  provider            = azurerm.hub
  name                = local.hub_name
  location            = azurerm_resource_group.hub[0].location
  resource_group_name = azurerm_resource_group.hub[0].name
  address_space       = [var.hub_address_space]
  tags                = var.tags
}

resource "azurerm_virtual_network" "spoke_data" {
  count               = var.enable_hub_spoke ? 1 : 0
  name                = local.spoke_data_name
  location            = azurerm_resource_group.bluebrick.location
  resource_group_name = azurerm_resource_group.bluebrick.name
  address_space       = [var.spoke_data_address_space]
  tags                = var.tags
}

resource "azurerm_subnet" "spoke_data_pep" {
  count                = var.enable_hub_spoke ? 1 : 0
  name                 = "pep-subnet"
  resource_group_name  = azurerm_resource_group.bluebrick.name
  virtual_network_name = azurerm_virtual_network.spoke_data[0].name
  address_prefixes     = [cidrsubnet(var.spoke_data_address_space, 8, 0)]
}

resource "azurerm_virtual_network" "spoke_dbx" {
  count               = var.enable_hub_spoke ? 1 : 0
  name                = local.spoke_dbx_name
  location            = azurerm_resource_group.bluebrick.location
  resource_group_name = azurerm_resource_group.bluebrick.name
  address_space       = [var.spoke_dbx_address_space]
  tags                = var.tags
}

resource "azurerm_network_security_group" "dbx_public" {
  count               = var.enable_hub_spoke ? 1 : 0
  name                = "nsg-${local.prefix}-dbx-public"
  location            = azurerm_resource_group.bluebrick.location
  resource_group_name = azurerm_resource_group.bluebrick.name
  tags                = var.tags
}

resource "azurerm_network_security_group" "dbx_private" {
  count               = var.enable_hub_spoke ? 1 : 0
  name                = "nsg-${local.prefix}-dbx-private"
  location            = azurerm_resource_group.bluebrick.location
  resource_group_name = azurerm_resource_group.bluebrick.name
  tags                = var.tags
}

resource "azurerm_subnet" "dbx_public" {
  count                = var.enable_hub_spoke ? 1 : 0
  name                 = "dbx-public"
  resource_group_name  = azurerm_resource_group.bluebrick.name
  virtual_network_name = azurerm_virtual_network.spoke_dbx[0].name
  address_prefixes     = [cidrsubnet(var.spoke_dbx_address_space, 8, 0)]

  delegation {
    name = "databricks-delegation-public"
    service_delegation {
      name = "Microsoft.Databricks/workspaces"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
        "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action",
      ]
    }
  }
}

resource "azurerm_subnet" "dbx_private" {
  count                = var.enable_hub_spoke ? 1 : 0
  name                 = "dbx-private"
  resource_group_name  = azurerm_resource_group.bluebrick.name
  virtual_network_name = azurerm_virtual_network.spoke_dbx[0].name
  address_prefixes     = [cidrsubnet(var.spoke_dbx_address_space, 8, 1)]

  delegation {
    name = "databricks-delegation-private"
    service_delegation {
      name = "Microsoft.Databricks/workspaces"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
        "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action",
      ]
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "dbx_public" {
  count                     = var.enable_hub_spoke ? 1 : 0
  subnet_id                 = azurerm_subnet.dbx_public[0].id
  network_security_group_id = azurerm_network_security_group.dbx_public[0].id
}

resource "azurerm_subnet_network_security_group_association" "dbx_private" {
  count                     = var.enable_hub_spoke ? 1 : 0
  subnet_id                 = azurerm_subnet.dbx_private[0].id
  network_security_group_id = azurerm_network_security_group.dbx_private[0].id
}

# VNet Peerings
resource "azurerm_virtual_network_peering" "hub_to_data" {
  count                         = var.enable_hub_spoke ? 1 : 0
  provider                      = azurerm.hub
  name                          = "peer-hub-to-data"
  resource_group_name           = azurerm_resource_group.hub[0].name
  virtual_network_name          = azurerm_virtual_network.hub[0].name
  remote_virtual_network_id     = azurerm_virtual_network.spoke_data[0].id
  allow_virtual_network_access  = true
  allow_forwarded_traffic       = false
  allow_gateway_transit         = false
  use_remote_gateways           = false
}

resource "azurerm_virtual_network_peering" "data_to_hub" {
  count                         = var.enable_hub_spoke ? 1 : 0
  name                          = "peer-data-to-hub"
  resource_group_name           = azurerm_resource_group.bluebrick.name
  virtual_network_name          = azurerm_virtual_network.spoke_data[0].name
  remote_virtual_network_id     = azurerm_virtual_network.hub[0].id
  allow_virtual_network_access  = true
  allow_forwarded_traffic       = false
  allow_gateway_transit         = false
  use_remote_gateways           = false
}

resource "azurerm_virtual_network_peering" "hub_to_dbx" {
  count                         = var.enable_hub_spoke ? 1 : 0
  provider                      = azurerm.hub
  name                          = "peer-hub-to-dbx"
  resource_group_name           = azurerm_resource_group.hub[0].name
  virtual_network_name          = azurerm_virtual_network.hub[0].name
  remote_virtual_network_id     = azurerm_virtual_network.spoke_dbx[0].id
  allow_virtual_network_access  = true
  allow_forwarded_traffic       = false
  allow_gateway_transit         = false
  use_remote_gateways           = false
}

resource "azurerm_virtual_network_peering" "dbx_to_hub" {
  count                         = var.enable_hub_spoke ? 1 : 0
  name                          = "peer-dbx-to-hub"
  resource_group_name           = azurerm_resource_group.bluebrick.name
  virtual_network_name          = azurerm_virtual_network.spoke_dbx[0].name
  remote_virtual_network_id     = azurerm_virtual_network.hub[0].id
  allow_virtual_network_access  = true
  allow_forwarded_traffic       = false
  allow_gateway_transit         = false
  use_remote_gateways           = false
}

# Private DNS zones for Storage Private Endpoints
resource "azurerm_private_dns_zone" "blob" {
  count               = var.enable_hub_spoke ? 1 : 0
  provider            = azurerm.hub
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.hub[0].name
}

resource "azurerm_private_dns_zone" "dfs" {
  count               = var.enable_hub_spoke ? 1 : 0
  provider            = azurerm.hub
  name                = "privatelink.dfs.core.windows.net"
  resource_group_name = azurerm_resource_group.hub[0].name
}

resource "azurerm_private_dns_zone_virtual_network_link" "blob_hub" {
  count                 = var.enable_hub_spoke ? 1 : 0
  provider              = azurerm.hub
  name                  = "blob-hub-link"
  resource_group_name   = azurerm_resource_group.hub[0].name
  private_dns_zone_name = azurerm_private_dns_zone.blob[0].name
  virtual_network_id    = azurerm_virtual_network.hub[0].id
}

resource "azurerm_private_dns_zone_virtual_network_link" "blob_spoke_data" {
  count                 = var.enable_hub_spoke ? 1 : 0
  provider              = azurerm.hub
  name                  = "blob-data-link"
  resource_group_name   = azurerm_resource_group.hub[0].name
  private_dns_zone_name = azurerm_private_dns_zone.blob[0].name
  virtual_network_id    = azurerm_virtual_network.spoke_data[0].id
}

resource "azurerm_private_dns_zone_virtual_network_link" "dfs_hub" {
  count                 = var.enable_hub_spoke ? 1 : 0
  provider              = azurerm.hub
  name                  = "dfs-hub-link"
  resource_group_name   = azurerm_resource_group.hub[0].name
  private_dns_zone_name = azurerm_private_dns_zone.dfs[0].name
  virtual_network_id    = azurerm_virtual_network.hub[0].id
}

resource "azurerm_private_dns_zone_virtual_network_link" "dfs_spoke_data" {
  count                 = var.enable_hub_spoke ? 1 : 0
  provider              = azurerm.hub
  name                  = "dfs-data-link"
  resource_group_name   = azurerm_resource_group.hub[0].name
  private_dns_zone_name = azurerm_private_dns_zone.dfs[0].name
  virtual_network_id    = azurerm_virtual_network.spoke_data[0].id
}

# Private Endpoints for Storage Account (Blob + DFS)
resource "azurerm_private_endpoint" "sa_blob" {
  count               = var.enable_hub_spoke ? 1 : 0
  name                = "pep-${local.prefix}-blob"
  location            = azurerm_resource_group.bluebrick.location
  resource_group_name = azurerm_resource_group.bluebrick.name
  subnet_id           = azurerm_subnet.spoke_data_pep[0].id

  private_service_connection {
    name                           = "sa-blob-connection"
    private_connection_resource_id = azurerm_storage_account.bluebrick.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name                 = "blob-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.blob[0].id]
  }
}

resource "azurerm_private_endpoint" "sa_dfs" {
  count               = var.enable_hub_spoke ? 1 : 0
  name                = "pep-${local.prefix}-dfs"
  location            = azurerm_resource_group.bluebrick.location
  resource_group_name = azurerm_resource_group.bluebrick.name
  subnet_id           = azurerm_subnet.spoke_data_pep[0].id

  private_service_connection {
    name                           = "sa-dfs-connection"
    private_connection_resource_id = azurerm_storage_account.bluebrick.id
    is_manual_connection           = false
    subresource_names              = ["dfs"]
  }

  private_dns_zone_group {
    name                 = "dfs-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.dfs[0].id]
  }
}
