resource "azurerm_storage_account" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type
  account_kind             = var.account_kind
  access_tier              = var.access_tier

  min_tls_version                   = var.min_tls_version
  https_traffic_only_enabled        = var.https_traffic_only_enabled
  allow_nested_items_to_be_public   = var.allow_nested_items_to_be_public
  shared_access_key_enabled         = var.shared_access_key_enabled
  public_network_access_enabled     = var.public_network_access_enabled
  infrastructure_encryption_enabled = var.infrastructure_encryption_enabled

  blob_properties {
    versioning_enabled = var.blob_versioning_enabled

    delete_retention_policy {
      days = var.blob_delete_retention_days
    }

    container_delete_retention_policy {
      days = var.container_delete_retention_days
    }
  }

  # Omitted entirely when `network_rules` is null, for callers that manage the
  # firewall out of band via `azurerm_storage_account_network_rules`.
  dynamic "network_rules" {
    for_each = var.network_rules == null ? [] : [var.network_rules]

    content {
      default_action             = network_rules.value.default_action
      bypass                     = network_rules.value.bypass
      ip_rules                   = network_rules.value.ip_rules
      virtual_network_subnet_ids = network_rules.value.virtual_network_subnet_ids
    }
  }

  tags = var.tags
}

# Containers are addressed by `storage_account_id`, which goes through the ARM
# management plane. That keeps working when the module's default firewall
# (`default_action = "Deny"`) or `shared_access_key_enabled = false` would
# block the data-plane API used by the older `storage_account_name` argument.
resource "azurerm_storage_container" "this" {
  for_each = var.containers

  name                  = each.key
  storage_account_id    = azurerm_storage_account.this.id
  container_access_type = each.value.access_type
  metadata              = each.value.metadata

  lifecycle {
    # Cross-variable check kept here rather than in a variable validation,
    # because those need Terraform 1.9 and the module supports >= 1.5.
    precondition {
      condition     = var.allow_nested_items_to_be_public || each.value.access_type == "private"
      error_message = "Container \"${each.key}\" has access_type \"${each.value.access_type}\", but allow_nested_items_to_be_public is false. Use access_type = \"private\" or set allow_nested_items_to_be_public = true."
    }
  }
}
