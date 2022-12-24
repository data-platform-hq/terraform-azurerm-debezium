# Azure Container Instance with Debezium Terraform module
Terraform module for creation of Azure Container Instance with Debezium Connector

## Usage
This module is provisioning Debezium container connect to Azure Sql Database and Azure Event Hub

```
locals {
  eventhub_topic = {
    db-history-topic = { partition_count = 1, message_retention = 7, permissions = ["listen","send","manage"] }
  }
  tags = {
    environment = "development"
  }
  sql_database              = "WideWorldImporters-Standard"
  mssql_tables              = ["schema_example.table_name_example"]
  container_group_object_id = "8120c8cf-c03f-4bb8-b319-603a3ab38e4d" # Object id of Azure managed enterprise application 'Azure Container Instance Service'
  key_vault_name_to_id_map  = { 
    (data.terraform_remote_state.base.outputs.key_vault.name) = data.terraform_remote_state.base.outputs.key_vault.id 
  }
}

data "azurerm_client_config" "current" {}

module "eventhub" {
  source  = "data-platform-hq/eventhub/azurerm"

  project        = "datahq"
  env            = "dev"
  location       = "eastus"
  tags           = local.tags
  resource_group = "example-rg"
  eventhub_topic = local.eventhub_topic
}

module "debezium" {
  source   = "data-platform-hq/terraform-azurerm-debezium

  project                    = "datahq"
  env                        = "dev"
  location                   = "eastus"
  resource_group             = "example-rg"
  tags                       = local.tags
  
  eventhub_name              = module.eventhub.name
  eventhub_connection_string = module.eventhub.connection_string
  
  # CMK encryption specific variables
  key_vault_id               = local.key_vault_name_to_id_map
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  container_group_object_id  = local.container_group_object_id
  
  # Azure SQL specific variables
  mssql_server_name   = "example-server"
  mssql_server_id     = "example-id"
  mssql_username      = "admin"
  mssql_password      = "example-azure-sql-password"
  mssql_database_name = local.mssql_db_name
  sql_tables          = local.mssql_tables
  
  depends_on = [module.eventhub]
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements
| Name                                                                      | Version   |
|---------------------------------------------------------------------------|---------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0  |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm)       | >= 3.23.0 |
| <a name="requirement_time"></a> [time](#requirement\_time)                | >= 0.9.1  |
| <a name="requirement_http"></a> [http](#requirement\_http)                | >= 3.2.1  |



## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 3.24.0 |
| <a name="provider_time"></a> [time](#provider\_time) | >= 0.9.1 |
| <a name="provider_http"></a> [http](#provider\_http) | >= 3.2.1 |

## Modules

No modules.

## Resources

| Name | Type |
|-------------------------------------------------------------------------------------------------------------------------------------------------|----------|
| [azurerm_key_vault_key.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_key) | resource |
| [azurerm_key_vault_access_policy.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy) | resource |
| [azurerm_container_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_group) | resource |
| [azurerm_mssql_firewall_rule.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_firewall_rule) | resource |
| [time_sleep.this](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [data.http.this](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_project"></a> [project](#input\_project) | Project name | `string` | n/a | yes |
| <a name="input_env"></a> [env](#input\_env) | Environment name | `string` | n/a | yes |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | The name of the resource group in which the Log Analytics workspace is created | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Specifies the supported Azure location where the resource exists | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resource | map | {} | no |
| <a name="input_azure_sql_server"></a> [azure\_sql\_server](#input\_azure\_sql\_server) | Azure sql server name | `string` | n/a | yes |
| <a name="input_sql_database"></a> [sql\_database](#input\_sql\_database) | Azure sql database | `string` | "example-database" | no |
| <a name="input_sql_table"></a> [sql\_table](#input\_sql\_table) | Azure sql tables names | list(string) | ["dbo.example-table"] | no |
| <a name="input_connection_string"></a> [connection\_string](#input\_connection\_string) | Azurerm eventhub namespace connection string | `string` | n/a | yes |
| <a name="input_eventhub_name"></a> [eventhub\_name](#input\_eventhub\_name) | Azure eventhub name | `string` | n/a | yes |
| <a name="input_azure_sql_user"></a> [azure\_sql\_user](#input\_azure\_sql\_user) | Azure sql user | `string` | n/a | yes |
| <a name="input_azure_sql_password"></a> [azure\_sql\_password](#input\_azure\_sql\_password) | Azure sql user password | `string` | n/a | yes |
| <a name="input_azure_sql_id"></a> [azure\_sql\_id](#input\_azure\_sql\_id) | Azure sql server id | `string` | n/a | yes |
| <a name="input_key_type"></a> [key\_type](#input\_key\_type) | Key Type to use for this Key Vault Key: (EC,EC-HSM,RSA,RSA-HSM) | `string` | "RSA" | no |
| <a name="input_key_size"></a> [key\_size](#input\_key\_size) | Size of the RSA key to create in bytes, requied for RSA & RSA-HSM: (1024 - 2048) | `number`| 2048 | no |
| <a name="input_key_opts"></a> [key\_opts](#input\_key\_opts) | JSON web key operations: (decrypt,encrypt,sign,unwrapKey,verify,wrapKey) | `list(string)` | <pre>[<br>  "decrypt",<br>  "encrypt",<br>  "sign",<br>  "unwrapKey",<br>  "verify",<br>  "wrapKey"<br>]</pre> | no |
| <a name="input_access_policy_permissions"></a> [key\_access\_policy\_permissions](#input\_access\_policy\_permissions) | List of key permissions | `list(string)` | <pre>[<br>  "Get",<br>  "List",<br>  "Verify",<br>  "WrapKey",<br>  "UnwrapKey"<br>]</pre> | no |
| <a name="input_key_vault_id"></a> [key\_vault\_id](#input\_key\_vault\_id) | Key Vault Name to ID map | `map(string)` | {} | no |
| <a name="input_container_group_object_id"></a> [container\_group\_object\_id](#input\_container\_group\_object\_id) | Azure Container Group Instance Service object id, used to create Key Vault Access Policy for Container Group identity | `string` | " " | no |
| <a name="input_tenant_id"></a> [tenant\_id](#input\_tenant\_id) | Tenant id where Azure Container Group Instance Service identity is assigned | `string` | " " | no |
| <a name="input_sleep_amount"></a> [sleep\_amount](#input\_sleep\_amount) | Time duration to delay resource creation | `string` | "6m" | yes |

## Outputs
| Name | Description |
|------|-------------|
| <a name="output_container_name"></a> [name](#output\_container\_name) | Name of the Container |
| <a name="output_container_id"></a> [id](#output\_container\_id) | Id of the Container |
| <a name="output_status_code"></a> [id](#output\_status\_code) | HTTP response status code |


<!-- END_TF_DOCS -->

## License

Apache 2 Licensed. For more information please see [LICENSE](https://github.com/data-platform-hq/terraform-azurerm-mssql-database/blob/main/LICENSE)
