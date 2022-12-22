output "name" {
  value       = azurerm_container_group.this.name
  description = "Name of the Container"
}

output "id" {
  value       = azurerm_container_group.this.id
  description = "Id of the Container"
}