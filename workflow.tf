resource "azurerm_logic_app_trigger_http_request" "this" {
  name         = "request-trigger"
  logic_app_id = var.logic_app_workflow_id

  schema = templatefile("${path.module}/templates/schema.tftpl", {
    default_method = "PUT"
  })

  depends_on = [azurerm_container_group.this]
}

resource "azurerm_logic_app_action_custom" "config_name" {
  name         = "config-name"
  logic_app_id = var.logic_app_workflow_id
  body = tostring(templatefile("${path.module}/templates/variable.tftpl", {
    name      = "config-name"
    type      = "string"
    value     = jsonencode(var.connector_config_name)
    run_after = ""
  }))
}

locals {
  sql_table_list = join(",", var.sql_tables)
}

resource "azurerm_logic_app_action_custom" "config_payload" {
  name         = "config-payload"
  logic_app_id = var.logic_app_workflow_id
  body = tostring(templatefile("${path.module}/templates/variable.tftpl", {
    name = "config-payload"
    type = "object"
    value = tostring(templatefile("${path.module}/templates/connector_config.tftpl", {
      mssql_server_name      = var.mssql_server_name
      mssql_database_name    = var.mssql_database_name
      sql_tables             = local.sql_table_list
      mssql_username         = var.mssql_username
      mssql_password         = var.mssql_password
      eventhub_name          = var.eventhub_name
      debezium_history_topic = var.debezium_history_topic
      connection_string      = var.connection_string
    }))
    run_after = "config-name"
  }))
  depends_on = [azurerm_logic_app_action_custom.config_name]
}

resource "azurerm_logic_app_action_custom" "method" {
  name         = "method"
  logic_app_id = var.logic_app_workflow_id
  body = tostring(templatefile("${path.module}/templates/variable.tftpl", {
    name      = "method"
    type      = "string"
    value     = jsonencode("@triggerBody()?['method']")
    run_after = "config-payload"
  }))
  depends_on = [azurerm_logic_app_action_custom.config_payload]
}

resource "azurerm_logic_app_action_custom" "if_condition" {
  name         = "null-value-replacer"
  logic_app_id = var.logic_app_workflow_id

  body = templatefile("${path.module}/templates/if_condition.tftpl", {
    variable_name  = azurerm_logic_app_action_custom.method.name
    variable_value = "POST"
  })
}

resource "azurerm_logic_app_action_custom" "switch" {
  logic_app_id = var.logic_app_workflow_id
  name         = "request-action"
  body = templatefile("${path.module}/templates/switch.tftpl", {
    debezium_fqdn       = azurerm_container_group.this.fqdn
    config_name         = azurerm_logic_app_action_custom.config_name.name
    config_payload_name = azurerm_logic_app_action_custom.config_payload.name
    condition_name      = azurerm_logic_app_action_custom.if_condition.name
  })
  depends_on = [azurerm_logic_app_action_custom.method]
}

data "http" "this" {
  url    = azurerm_logic_app_trigger_http_request.this.callback_url
  method = "POST"
  request_headers = {
    Accept       = "*/*"
    Content-Type = "application/json"
  }
  request_body = jsonencode({
    "method" : "POST",
  })
  depends_on = [azurerm_logic_app_trigger_http_request.this, azurerm_logic_app_action_custom.switch]
}
