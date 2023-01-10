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
  description = "The name of the resource group in which resources is created"
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

variable "container_config" {
  type = map(object({
    image  = string
    cpu    = string
    memory = string
  }))
  description = "Version and capacity config for container"
  default = {
    "debezium" = {
      image  = "debezium/connect:1.9",
      cpu    = "2",
      memory = "4"
    }
  }
}

variable "aci_ip_address_type" {
  type        = string
  description = "Ip address type on Container Instance"
  default     = "Public"
}

variable "aci_os_type" {
  type        = string
  description = "Container Instance os type"
  default     = "Linux"
}

variable "aci_restart_policy" {
  type        = string
  description = "Container Instance restart policy"
  default     = "Never"
}

variable "mssql_server_name" {
  type        = string
  description = "Azure sql server name"
}

variable "mssql_database_name" {
  type        = string
  description = "Azure sql database"
  default     = ""
}

variable "sql_tables" {
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

variable "mssql_username" {
  type        = string
  description = "Azure sql user"
}

variable "mssql_password" {
  type        = string
  description = "Azure sql user password"
}

variable "key_type" {
  type        = string
  description = "Key Type to use for this Key Vault Key: (EC,EC-HSM,RSA,RSA-HSM)"
  default     = "RSA"
}

variable "key_size" {
  type        = number
  description = "Size of the RSA key to create in bytes, requied for RSA & RSA-HSM: (1024 - 2048)"
  default     = 2048
}

variable "key_opts" {
  type        = list(string)
  description = "JSON web key operations: (decrypt,encrypt,sign,unwrapKey,verify,wrapKey)"
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
  description = "List of key permissions"
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
  default     = "8120c8cf-c03f-4bb8-b319-603a3ab38e4d"
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

variable "debezium_history_topic" {
  type        = string
  description = "Database history eventhub topic"
  default     = "db-history-topic"
}

variable "connector_config_name" {
  type        = string
  description = "Debezium SQL Connector name to give"
  default     = "mssql-config"
}

variable "logic_app_workflow_id" {
  type        = string
  description = "Id of Logic App Workflow where Actions would be created"
}
