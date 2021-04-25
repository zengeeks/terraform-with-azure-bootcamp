output "function_url" {
  value = try(module.function_cosmosdb_basic.function_url, "Not used")
}
