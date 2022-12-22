variable "project" {
  type        = string
  description = "Project name"
}

variable "env" {
  type        = string
  description = "Environment name"
}

variable "resource_group" {
  type        = string
  description = "The name of the resource group in which the Log Analytics workspace is created"
}

variable "location" {
  type        = string
  description = "Specifies the supported Azure location where the resource exists"
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the resource"
  default     = {}
}

variable "azure_sql_server" {
  type        = string
  description = "Azure sql server name"
}

variable "sql_database" {
  type        = string
  description = "Azure sql database"
  default     = ""
}

variable "sql_table" {
  type        = list(string)
  description = "Azure sql tables names"
  default     = []
}

variable "connection_string" {
  type        = string
  description = "Azurerm eventhub namespace connection string"
}

variable "eventhub_name" {
  type        = string
  description = "Azure eventhub name"
}

variable "azure_sql_user" {
  type        = string
  description = "Azure sql user"
}

variable "azure_sql_password" {
  type        = string
  description = "Azure sql password"
}

variable "azure_sql_id" {
  type        = string
  description = "Azure sql server"
}

variable "key_type" {
  type        = string
  description = "Key Type to use for this Key Vault Key: [EC|EC-HSM|Oct|RSA|RSA-HSM]"
  default     = "RSA"
}

variable "key_size" {
  type        = number
  description = "Size of the RSA key to create in bytes, requied for RSA & RSA-HSM: [1024|2048]"
  default     = 2048
}

variable "key_opts" {
  type        = list(string)
  description = "JSON web key operations: [decrypt|encrypt|sign|unwrapKey|verify|wrapKey]"
  default = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey"
  ]
}

variable "access_policy_permissions" {
  type        = list(string)
  description = "JSON web key operations: [decrypt|encrypt|sign|unwrapKey|verify|wrapKey]"
  default = [
    "Get",
    "List",
    "Verify",
    "WrapKey",
    "UnwrapKey",
  ]
}

variable "key_vault_id" {
  type        = map(string)
  description = "Key Vault Name to ID map"
  default     = {}
}

variable "container_group_object_id" {
  type        = string
  description = "Azure Container Group Instance Service object id, used to create Key Vault Access Policy for Container Group identity"
  default     = ""
  validation {
    condition     = length(var.container_group_object_id) == 36 || length(var.container_group_object_id) == 0
    error_message = "UUID has to be either in nnnnnnnn-nnnn-nnnn-nnnn-nnnnnnnnnnnn format or empty string"
  }
}

variable "tenant_id" {
  type        = string
  description = "Tenant id where Azure Container Group Instance Service identity is assigned"
  default     = ""
  validation {
    condition     = length(var.tenant_id) == 36 || length(var.tenant_id) == 0
    error_message = "UUID has to be either in nnnnnnnn-nnnn-nnnn-nnnn-nnnnnnnnnnnn format or empty string"
  }
}

