resource "azurerm_app_service_plan" "main" {
  name                = "plan-${var.app_identifier}"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  sku {
    tier = "PremiumV2"
    size = "P1v2"
  }
}

resource "azurerm_function_app" "main" {
  name                       = local.function_name
  location                   = data.azurerm_resource_group.main.location
  resource_group_name        = data.azurerm_resource_group.main.name
  app_service_plan_id        = azurerm_app_service_plan.main.id
  storage_account_name       = azurerm_storage_account.for_func.name
  storage_account_access_key = azurerm_storage_account.for_func.primary_access_key
  version                    = "~3"
  https_only                 = true

  site_config {
    always_on     = true
    ftps_state    = "Disabled"
    http2_enabled = true
  }

  app_settings = {
    AzureWebJobsStorage                      = azurerm_storage_account.for_func.primary_connection_string
    WEBSITE_CONTENTAZUREFILECONNECTIONSTRING = azurerm_storage_account.for_func.primary_connection_string
    FUNCTIONS_WORKER_RUNTIME                 = "dotnet"
    WEBSITE_RUN_FROM_PACKAGE                 = var.function_package_url
    TargetHost                               = regex("^https://(?P<host>[\\d\\w.-]+):443/$", azurerm_cosmosdb_account.main.endpoint).host
  }
}

resource "random_string" "storage_for_func" {
  length  = 22
  upper   = false
  special = false
  keepers = {
    resource_group_id = data.azurerm_resource_group.main.id
    app_identifier    = var.app_identifier
  }
}

resource "azurerm_storage_account" "for_func" {
  name                     = "st${random_string.storage_for_func.result}"
  location                 = data.azurerm_resource_group.main.location
  resource_group_name      = data.azurerm_resource_group.main.name
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
