output "name" {
  value       = azurerm_container_group.this.name
  description = "Name of the Azure Container Instance where Debezium executes"
}

output "id" {
  value       = azurerm_container_group.this.id
  description = "Id of the Azure Container Instance where Debezium executes"
}

output "ip_address" {
  value       = azurerm_container_group.this.ip_address
  description = "Public IP address of the Azure Container Instance where Debezium executes"
}

output "identity" {
  value       = azurerm_container_group.this.identity[*]
  description = "List of identities assigned to the Azure Container Instance"
}

output "cmk_key_id" {
  value       = azurerm_key_vault_key.this[0].id
  description = "Customer Managed Key Id, used to encrypt disks on Azure Container Instance"
}

output "status_code" {
  value       = data.http.this.status_code
  description = "HTTP response status code"
}
