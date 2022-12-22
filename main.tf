resource "azurerm_key_vault_key" "this" {
  for_each = length(var.tenant_id) == 36 && length(var.container_group_object_id) == 36 ? var.key_vault_id : {}

  name         = "debezium-${var.project}-${var.env}-${var.location}"
  key_type     = var.key_type
  key_size     = var.key_size
  key_vault_id = each.value
  key_opts     = var.key_opts
}

resource "azurerm_key_vault_access_policy" "this" {
  for_each = length(var.tenant_id) == 36 && length(var.container_group_object_id) == 36 ? var.key_vault_id : {}

  key_vault_id    = each.value
  tenant_id       = var.tenant_id
  object_id       = var.container_group_object_id
  key_permissions = var.access_policy_permissions
}

resource "azurerm_container_group" "this" {
  name                = "debezium-${var.project}-${var.env}-${var.location}"
  location            = var.location
  resource_group_name = var.resource_group
  ip_address_type     = "Public"
  os_type             = "Linux"
  restart_policy      = "Never"
  key_vault_key_id    = length(var.key_vault_id) == 0 ? null : azurerm_key_vault_key.this[keys(var.key_vault_id)[0]].id

  exposed_port {
    port     = 8083
    protocol = "TCP"
  }
  container {
    name   = "debezium"
    image  = "debezium/connect:1.9"
    cpu    = "2"
    memory = "4"

    ports {
      port     = 8083
      protocol = "TCP"
    }

    environment_variables = {
      BOOTSTRAP_SERVERS : "${var.eventhub_name}.servicebus.windows.net:9093"
      CONNECT_REST_ADVERTISED_HOST_NAME : "debezium-eventhub-1"
      CONNECT_REST_PORT : "8083"
      CONNECT_GROUP_ID : "debezium-eventhub-1"
      CONFIG_STORAGE_TOPIC : "config-storage"
      OFFSET_STORAGE_TOPIC : "offsets-storage"
      STATUS_STORAGE_TOPIC : "status-storage"
      KEY_CONVERTER : "org.apache.kafka.connect.storage.StringConverter"
      VALUE_CONVERTER : "org.apache.kafka.connect.json.JsonConverter"

      CONNECT_SECURITY_PROTOCOL = "SASL_SSL"
      CONNECT_SASL_MECHANISM    = "PLAIN"
      CONNECT_SASL_JAAS_CONFIG  = "org.apache.kafka.common.security.plain.PlainLoginModule required username=\"$ConnectionString\" password=\"${var.connection_string}\";"

      CONNECT_PRODUCER_SECURITY_PROTOCOL = "SASL_SSL"
      CONNECT_PRODUCER_SASL_MECHANISM    = "PLAIN"
      CONNECT_PRODUCER_SASL_JAAS_CONFIG  = "org.apache.kafka.common.security.plain.PlainLoginModule required username=\"$ConnectionString\" password=\"${var.connection_string}\";"
    }
  }
}

resource "azurerm_mssql_firewall_rule" "this" {
  name             = "debezium-${var.project}-${var.env}-${var.location}"
  server_id        = var.azure_sql_id
  start_ip_address = azurerm_container_group.this.ip_address
  end_ip_address   = azurerm_container_group.this.ip_address
}

resource "time_sleep" "this" {
  create_duration = "6m"

  lifecycle {
    replace_triggered_by = [
      azurerm_container_group.this
    ]
  }
  depends_on = [azurerm_container_group.this]
}

locals {
  sql_table_list = join(",", var.sql_table)
}

data "http" "this" {
  url    = "http://${azurerm_container_group.this.ip_address}:8083/connectors"
  method = "POST"
  request_headers = {
    Accept       = "*/*"
    Content-Type = "application/json"
  }
  request_body = jsonencode({
    "name" : "sql-server",
    "config" : {
      "connector.class" : "io.debezium.connector.sqlserver.SqlServerConnector",
      "database.hostname" : "${var.azure_sql_server}.database.windows.net",
      "database.port" : "1433",
      "database.user" : (var.azure_sql_user),
      "database.password" : (var.azure_sql_password),
      "database.dbname" : (var.sql_database),
      "database.server.name" : "cdc",
      "table.include.list" : (local.sql_table_list),
      "decimal.handling.mode" : "double",
      "time.precision.mode" : "connect",

      "database.history.kafka.bootstrap.servers" : "${var.eventhub_name}.servicebus.windows.net:9093",
      "database.history.kafka.topic" : "db-history-topic",

      "database.history.consumer.security.protocol" : "SASL_SSL",
      "database.history.consumer.sasl.mechanism" : "PLAIN",
      "database.history.consumer.sasl.jaas.config" : "org.apache.kafka.common.security.plain.PlainLoginModule required username=\"$ConnectionString\"password=\"${var.connection_string}\";",
      "database.history.producer.security.protocol" : "SASL_SSL",
      "database.history.producer.sasl.mechanism" : "PLAIN",
      "database.history.producer.sasl.jaas.config" : "org.apache.kafka.common.security.plain.PlainLoginModule required username=\"$ConnectionString\"password=\"${var.connection_string}\";"
    }
  })

  depends_on = [time_sleep.this]
}