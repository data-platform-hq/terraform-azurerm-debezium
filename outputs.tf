output "container_name" {
  value       = azurerm_container_group.this.name
  description = "Name of the Container"
}

output "container_id" {
  value       = azurerm_container_group.this.id
  description = "Id of the Container"
}

output "status_code" {
  value       = data.http.this.status_code
  description = "HTTP response status code"
}
