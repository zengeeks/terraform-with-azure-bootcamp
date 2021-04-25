resource "azurerm_cosmosdb_account" "main" {
  name                = local.cosmosdb_name
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"
  ip_range_filter     = "126.159.25.132,104.42.195.92,40.76.54.131,52.176.6.30,52.169.50.45,52.187.184.26"

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = data.azurerm_resource_group.main.location
    failover_priority = 0
  }
}

resource "azurerm_cosmosdb_sql_database" "main" {
  name                = local.cosmosdb.database_name
  resource_group_name = data.azurerm_resource_group.main.name
  account_name        = azurerm_cosmosdb_account.main.name
  throughput          = local.cosmosdb.throughput
}

resource "azurerm_cosmosdb_sql_container" "main" {
  for_each = local.cosmosdb.containers

  name                = each.value.name
  resource_group_name = data.azurerm_resource_group.main.name
  account_name        = azurerm_cosmosdb_account.main.name
  database_name       = azurerm_cosmosdb_sql_database.main.name
  partition_key_path  = each.value.partition_key_path
}
