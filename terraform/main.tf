terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.0.0"
    }
  }

  # Configure backend, if need
  # backend "azurerm" {}
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  # If the runner doesn't have permission to register providers on Azure, errors may be raised. To prevent it, make skip the registration
  # skip_provider_registration = "true"
  features {}

  # If you want to configure authentication settings on a file instead of environment variables, write down here
  # subscription_id = "00000000-0000-0000-0000-000000000000"
  # ...
}

module "get_client_ip" {
  source = "./modules/get_client_ip"
}

module "get_function_package_url" {
  source = "./modules/get_function_package_url"

  asset_name = "functions.zip"
}

module "function_cosmosdb_basic" {
  source = "./modules/function_cosmosdb_basic"

  resource_group_name  = var.resource_group_name
  app_identifier       = "${var.app_identifier}-basic"
  function_package_url = module.get_function_package_url.download_url
}

module "function_cosmosdb_via_vnet" {
  source = "./modules/function_cosmosdb_via_vnet"

  resource_group_name  = var.resource_group_name
  app_identifier       = "${var.app_identifier}-via-vnet"
  function_package_url = module.get_function_package_url.download_url
  client_ip            = module.get_client_ip.client_ip
}
