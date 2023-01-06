resource "azurerm_key_vault_access_policy" "this" {
  for_each = length(var.tenant_id) != 0 && length(var.container_group_object_id) != 0 ? var.key_vault_id : {}

  key_vault_id    = each.value
  tenant_id       = var.tenant_id
  object_id       = var.container_group_object_id
  key_permissions = var.access_policy_permissions
}

resource "azurerm_key_vault_key" "this" {
  for_each = length(var.tenant_id) != 0 && length(var.container_group_object_id) != 0 ? var.key_vault_id : {}

  name         = "debezium-${var.project}-${var.env}-${var.location}"
  key_type     = var.key_type
  key_size     = var.key_size
  key_vault_id = each.value
  key_opts     = var.key_opts

  depends_on = [azurerm_key_vault_access_policy.this]
}

resource "azurerm_container_group" "this" {
  name                = "debezium-${var.project}-${var.env}-${var.location}"
  location            = var.location
  resource_group_name = var.resource_group
  tags                = var.tags
  ip_address_type     = var.aci_ip_address_type
  os_type             = var.aci_os_type
  restart_policy      = var.aci_restart_policy
  dns_name_label      = "debezium-${var.project}-${var.env}"
  key_vault_key_id    = length(var.key_vault_id) == 0 ? null : azurerm_key_vault_key.this[keys(var.key_vault_id)[0]].id

  identity {
    type         = var.identity_ids == null ? "SystemAssigned" : "SystemAssigned, UserAssigned"
    identity_ids = var.identity_ids
  }

  exposed_port {
    port     = 8083
    protocol = "TCP"
  }

  dynamic "container" {
    for_each = var.container_config
    content {
      name   = container.key
      image  = container.value.image
      cpu    = container.value.cpu
      memory = container.value.memory

      ports {
        port     = 8083
        protocol = "TCP"
      }

      environment_variables = {
        BOOTSTRAP_SERVERS : "${var.eventhub_name}.servicebus.windows.net:9093"
        CONNECT_REST_ADVERTISED_HOST_NAME : "azure-container-instance-debezium"
        CONNECT_REST_PORT : "8083"
        CONNECT_GROUP_ID : "azure-container-instance-debezium"
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
}

resource "azurerm_mssql_firewall_rule" "this" {
  name             = "debezium-${var.project}-${var.env}-${var.location}"
  server_id        = var.mssql_server_id
  start_ip_address = azurerm_container_group.this.ip_address
  end_ip_address   = azurerm_container_group.this.ip_address
}
