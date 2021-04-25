data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

locals {
  vnet_address_space = "10.0.0.0/16"
  function_name      = "func-${var.app_identifier}"
  cosmosdb = {
    database_name = "item"
    throughput    = 400
    containers = {
      categories = {
        name               = "categories"
        partition_key_path = "/id"
      }
      suppliers = {
        name               = "suppliers"
        partition_key_path = "/supplier/id"
      }
    }
  }
}
