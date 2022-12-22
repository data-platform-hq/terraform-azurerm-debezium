# Azure Debezium Container Terraform module
Terraform module for creation Debezium Container

## Usage
Debezium writes cdc changes to azure event hubs and depend on module azure eventhub. Ensure that _**"eventhub_enabled"**_ is set as true
Pre config for Debezium container is to turn on cdc at Azure sql database and tables.
Do all queries using dpaf or azure sql administrator user.

Enable cdc at azure sql database, in this example for "WideWorldImporters-Standard" database
```
EXEC sys.sp_cdc_enable_db
```

Enable cdc at azure sql tables
```
EXEC sys.sp_cdc_enable_table
@source_schema = N'shema_example',
@source_name   = N'table_name_example',
@role_name     = NULL,
@supports_net_changes = 1
```

Next step is to fill database name and topics to their variables at terraform tfstate environment file
```
locals {
  sql_database = "WideWorldImporters-Standard"
  mssql_tables = ["shema_example.table_name_example"]
  key_vault_map = { for n in toset([data.azurerm_key_vault_secret.key_vault]) : n.name => n.id }
  debezium_encryption_key = true
  eventhub_enabled = true
  debezium_enabled = true
}
module "debezium" {
  source   = "data-platform-hq/terraform-azurerm-debezium
  count  = var.debezium_enabled == true ? 1 : 0

  project                   = var.project
  env                       = var.env
  location                  = var.location
  resource_group            = module.resource_group.name
  tags                      = var.tags
  connection_string         = module.eventhub[0].connection_string
  eventhub_name             = module.eventhub[0].name
  key_vault_id              = local.debezium_encryption_key == true ? local.key_vault_map : {}
  tenant_id                 = data.azurerm_client_config.current.tenant_id
  container_group_object_id = var.container_group_object_id
  azure_sql_server          = module.azure_sql.name
  azure_sql_id              = module.azure_sql.id
  azure_sql_user            = data.azurerm_key_vault_secret.secret_sql_server_admin_username.value
  azure_sql_password        = data.azurerm_key_vault_secret.secret_sql_server_admin_password.value
  sql_database              = local.mssql_db_name
  sql_table                 = local.mssql_tables

depends_on = [module.eventhub]
}
```
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.23.0 |



## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 3.24.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
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
| <a name="input_azure_sql_server"></a> [azure\_sql\_server](#input\_azure_sql_server) | Azure sql server name | `string` | n/a | no |
| <a name="input_sql_database"></a> [sql\_database](#input\_sql_database) | Azure sql database | `string` | "example-database" | no |
| <a name="input_sql_table"></a> [sql\_table](#input\_sql_table) | Azure sql tables names | list(string) | ["dbo.example-table"] | no |
| <a name="input_connection_string"></a> [connection\_string](#input\_connection_string) | Azurerm eventhub namespace connection string | string | n/a | yes |
| <a name="input_eventhub_name"></a> [eventhub\_name](#input\_eventhub_name) | Azure eventhub name | `string` | n/a | yes |
| <a name="input_azure_sql_user"></a> [azure\_sql\_user](#input\_azure_sql_user) | Azure sql user | `string` | n/a | yes |
| <a name="input_azure_sql_password"></a> [azure\_sql\_password](#input\_azure_sql_password) | Azure sql password | `string` | n/a | yes |
| <a name="input_azure_sql_id"></a> [azure\_sql\_id](#input\_azure_sql_id) | Azure sql server id | `string` | n/a | yes |
| <a name="input_key_type"></a> [key\_type](#input\_key_type) | Key Type to use for this Key Vault Key: [EC|EC-HSM|Oct|RSA|RSA-HSM] | `string` | "RSA" | no |
| <a name="input_key_size"></a> [key\_size](#input\_key_size) | Size of the RSA key to create in bytes, requied for RSA & RSA-HSM: [1024|2048] | `number`| 2048 | no |
| <a name="input_key_opts"></a> [key\_opts](#input\_key_opts) | JSON web key operations: [decrypt\|encrypt\|sign\|unwrapKey\|verify\|wrapKey] | `list(string)` | <pre>[<br>  "decrypt",<br>  "encrypt",<br>  "sign",<br>  "unwrapKey",<br>  "verify",<br>  "wrapKey"<br>]</pre> | no |
| <a name="input_access_policy_permissions"></a> [key\_opts](#input\_access\_policy\_permissions) | List of key permissions, must be one or more from the following | `list(string)` | <pre>[<br>  "Get",<br>  "List",<br>  "Verify",<br>  "WrapKey",<br>  "UnwrapKey"<br>]</pre> | no |
| <a name="input_key_vault_id"></a> [key\_vault\_id](#input\_key\_vault\_id) | Key Vault Name to ID map | `map(string)` | {} | no |
| <a name="input_container_group_object_id"></a> [container\_group\_object\_id](#input\_container\_group\_object\_id) | Azure Container Group Instance Service object id, used to create Key Vault Access Policy for Container Group identity | `string` | n/a | yes |
| <a name="input_tenant_id"></a> [tenant\_id](#input\_tenant\_id) | Tenant id where Azure Container Group Instance Service identity is assigned | `string` | n/a | yes |

## Outputs
| Name | Description |
|------|-------------|
| <a name="output_name"></a> [name](#output\_name) | Name of the Container |
| <a name="output_id"></a> [id](#output\_id) | Id of the Container |



<!-- END_TF_DOCS -->

## License

Apache 2 Licensed. For more information please see [LICENSE](https://github.com/data-platform-hq/terraform-azurerm-mssql-database/blob/main/LICENSE)
