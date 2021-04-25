output "function_url_basic" {
  value = try(module.function_cosmosdb_basic.function_url, "Not used")
}

output "function_url_via_vnet" {
  value = try(module.function_cosmosdb_via_vnet.function_url, "Not used")
}
