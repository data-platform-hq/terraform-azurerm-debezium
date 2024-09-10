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
  
  mssql_database_name = "WideWorldImporters-Standard"
  mssql_tables        = ["schema_example.table_name_example"]
  
  # Object id of Azure-managed enterprise application 'Azure Container Instance Service'
  container_group_object_id = "8120c8cf-c03f-4bb8-b319-603a3ab38e4d" 
  
  # Here, create map of target Key Vault name to it's id:
  key_vault_name_to_id_map  = { 
    (module.key_vault.name) = module.key_vault.id 
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

module "logic_app_workflow" {
  source  = "data-platform-hq/logic-app-workflow/azurerm"

  project        = "datahq"
  env            = "dev"
  location       = "eastus"
  name           = "debezium"
  tags           = local.tags
  resource_group = "example-rg"
}

module "debezium" {
  source   = "data-platform-hq/terraform-azurerm-debezium

  project                    = "datahq"
  env                        = "dev"
  location                   = "eastus"
  resource_group             = "example-rg"
  tags                       = local.tags
  
  eventhub_name              = module.eventhub.namespace_name
  eventhub_connection_string = module.eventhub.namespace_connection_string
  
  # CMK encryption specific variables
  key_vault_id               = local.key_vault_name_to_id_map
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  container_group_object_id  = local.container_group_object_id
  
  # Azure SQL specific variables
  mssql_server_name   = "example-server"
  mssql_username      = "admin"
  mssql_password      = "example-azure-sql-password"
  mssql_database_name = local.mssql_db_name
  sql_tables          = local.mssql_tables
  
  logic_app_workflow_id  = module.logic_app_workflow.id
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.0.1 |


## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.0.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_container_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_group) | resource |
| [azurerm_key_vault_access_policy.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy) | resource |
| [azurerm_key_vault_key.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_key) | resource |
| [azurerm_logic_app_action_custom.config_name](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/logic_app_action_custom) | resource |
| [azurerm_logic_app_action_custom.config_payload](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/logic_app_action_custom) | resource |
| [azurerm_logic_app_action_custom.if_condition](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/logic_app_action_custom) | resource |
| [azurerm_logic_app_action_custom.method](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/logic_app_action_custom) | resource |
| [azurerm_logic_app_action_custom.switch](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/logic_app_action_custom) | resource |
| [azurerm_logic_app_trigger_http_request.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/logic_app_trigger_http_request) | resource |
| [http_http.this](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_policy_permissions"></a> [access\_policy\_permissions](#input\_access\_policy\_permissions) | List of key permissions | `list(string)` | <pre>[<br>  "Get",<br>  "List",<br>  "Verify",<br>  "WrapKey",<br>  "UnwrapKey"<br>]</pre> | no |
| <a name="input_aci_ip_address_type"></a> [aci\_ip\_address\_type](#input\_aci\_ip\_address\_type) | Ip address type on Container Instance | `string` | `"Public"` | no |
| <a name="input_aci_os_type"></a> [aci\_os\_type](#input\_aci\_os\_type) | Container Instance os type | `string` | `"Linux"` | no |
| <a name="input_aci_restart_policy"></a> [aci\_restart\_policy](#input\_aci\_restart\_policy) | Container Instance restart policy | `string` | `"Never"` | no |
| <a name="input_connection_string"></a> [connection\_string](#input\_connection\_string) | Azurerm eventhub namespace connection string | `string` | n/a | yes |
| <a name="input_connector_config_name"></a> [connector\_config\_name](#input\_connector\_config\_name) | Debezium SQL Connector name to give | `string` | `"mssql-config"` | no |
| <a name="input_container_config"></a> [container\_config](#input\_container\_config) | Version and capacity config for container | <pre>map(object({<br>    image  = string<br>    cpu    = string<br>    memory = string<br>  }))</pre> | <pre>{<br>  "debezium": {<br>    "cpu": "2",<br>    "image": "debezium/connect:1.9",<br>    "memory": "4"<br>  }<br>}</pre> | no |
| <a name="input_container_group_object_id"></a> [container\_group\_object\_id](#input\_container\_group\_object\_id) | Azure Container Group Instance Service object id, used to create Key Vault Access Policy for Container Group identity | `string` | `"8120c8cf-c03f-4bb8-b319-603a3ab38e4d"` | no |
| <a name="input_debezium_history_topic"></a> [debezium\_history\_topic](#input\_debezium\_history\_topic) | Database history eventhub topic | `string` | `"db-history-topic"` | no |
| <a name="input_env"></a> [env](#input\_env) | Environment name | `string` | n/a | yes |
| <a name="input_eventhub_name"></a> [eventhub\_name](#input\_eventhub\_name) | Azure eventhub name | `string` | n/a | yes |
| <a name="input_key_opts"></a> [key\_opts](#input\_key\_opts) | JSON web key operations: (decrypt,encrypt,sign,unwrapKey,verify,wrapKey) | `list(string)` | <pre>[<br>  "decrypt",<br>  "encrypt",<br>  "sign",<br>  "unwrapKey",<br>  "verify",<br>  "wrapKey"<br>]</pre> | no |
| <a name="input_key_size"></a> [key\_size](#input\_key\_size) | Size of the RSA key to create in bytes, requied for RSA & RSA-HSM: (1024 - 2048) | `number` | `2048` | no |
| <a name="input_key_type"></a> [key\_type](#input\_key\_type) | Key Type to use for this Key Vault Key: (EC,EC-HSM,RSA,RSA-HSM) | `string` | `"RSA"` | no |
| <a name="input_key_vault_id"></a> [key\_vault\_id](#input\_key\_vault\_id) | Key Vault Name to ID map | `map(string)` | `{}` | no |
| <a name="input_location"></a> [location](#input\_location) | Specifies the supported Azure location where the resource exists | `string` | n/a | yes |
| <a name="input_logic_app_workflow_id"></a> [logic\_app\_workflow\_id](#input\_logic\_app\_workflow\_id) | Id of Logic App Workflow where Actions would be created | `string` | n/a | yes |
| <a name="input_mssql_database_name"></a> [mssql\_database\_name](#input\_mssql\_database\_name) | Azure sql database | `string` | `""` | no |
| <a name="input_mssql_password"></a> [mssql\_password](#input\_mssql\_password) | Azure sql user password | `string` | n/a | yes |
| <a name="input_mssql_server_name"></a> [mssql\_server\_name](#input\_mssql\_server\_name) | Azure sql server name | `string` | n/a | yes |
| <a name="input_mssql_username"></a> [mssql\_username](#input\_mssql\_username) | Azure sql user | `string` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | Project name | `string` | n/a | yes |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | The name of the resource group in which resources is created | `string` | n/a | yes |
| <a name="input_sql_tables"></a> [sql\_tables](#input\_sql\_tables) | Azure sql tables names | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resource | `map(string)` | `{}` | no |
| <a name="input_tenant_id"></a> [tenant\_id](#input\_tenant\_id) | Tenant id where Azure Container Group Instance Service identity is assigned | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cmk_key_id"></a> [cmk\_key\_id](#output\_cmk\_key\_id) | Customer Managed Key Id, used to encrypt disks on Azure Container Instance |
| <a name="output_container_id"></a> [container\_id](#output\_container\_id) | Id of the Azure Container Instance where Debezium executes |
| <a name="output_container_ip_address"></a> [container\_ip\_address](#output\_container\_ip\_address) | Public IP address of the Azure Container Instance where Debezium executes |
| <a name="output_container_name"></a> [container\_name](#output\_container\_name) | Name of the Azure Container Instance where Debezium executes |
| <a name="output_identity"></a> [identity](#output\_identity) | List of identities assigned to the Azure Container Instance |
| <a name="output_status_code"></a> [status\_code](#output\_status\_code) | HTTP response status code |
| <a name="output_trigger_callback_url"></a> [trigger\_callback\_url](#output\_trigger\_callback\_url) | URL to trigger Logic App Workflow |

<!-- END_TF_DOCS -->

## License

Apache 2 Licensed. For more information please see [LICENSE](https://github.com/data-platform-hq/terraform-azurerm-mssql-database/blob/main/LICENSE)
