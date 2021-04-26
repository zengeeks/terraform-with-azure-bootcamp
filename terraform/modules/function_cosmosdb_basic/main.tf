data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

locals {
  function_name = "func-${var.app_identifier}"
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
