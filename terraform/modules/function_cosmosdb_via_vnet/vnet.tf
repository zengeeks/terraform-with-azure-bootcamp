resource "azurerm_virtual_network" "main" {
  name                = "vnet-${var.app_identifier}"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  address_space       = [local.vnet_address_space]
}

resource "azurerm_subnet" "main" {
  name                 = "snet-${var.app_identifier}"
  resource_group_name  = data.azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [cidrsubnet(azurerm_virtual_network.main.address_space[0], 8, 0)]
  service_endpoints    = ["Microsoft.Storage", "Microsoft.AzureCosmosDB"]

  delegation {
    name = "Delegation"
    service_delegation {
      name = "Microsoft.Web/serverFarms"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/action",
      ]
    }
  }
}
