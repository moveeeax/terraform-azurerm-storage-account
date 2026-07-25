# Test-only requirement: `mock_provider` needs Terraform >= 1.7 (or OpenTofu
# >= 1.7). The module itself still supports >= 1.5, so required_version in
# versions.tf is deliberately left alone.
mock_provider "azurerm" {}

variables {
  name                = "tftestsa0storage"
  resource_group_name = "tftest-rg"
  location            = "eastus"
}

run "defaults_are_safe" {
  assert {
    condition     = azurerm_storage_account.this.allow_nested_items_to_be_public == false
    error_message = "Anonymous public access to blobs and containers must be off by default."
  }

  assert {
    condition     = azurerm_storage_account.this.https_traffic_only_enabled == true
    error_message = "Plaintext HTTP traffic must be rejected by default."
  }

  assert {
    condition     = azurerm_storage_account.this.min_tls_version == "TLS1_2"
    error_message = "The minimum TLS version must default to TLS1_2."
  }

  assert {
    condition     = azurerm_storage_account.this.network_rules[0].default_action == "Deny"
    error_message = "The storage firewall must default to denying unlisted networks."
  }

  assert {
    condition     = azurerm_storage_account.this.network_rules[0].bypass == toset(["AzureServices"])
    error_message = "The storage firewall must bypass trusted Azure services only."
  }

  assert {
    condition     = length(azurerm_storage_account.this.network_rules[0].ip_rules) == 0
    error_message = "No IP ranges may be allow-listed by default."
  }

  assert {
    condition     = azurerm_storage_account.this.blob_properties[0].versioning_enabled == true
    error_message = "Blob versioning must be enabled by default."
  }

  assert {
    condition     = azurerm_storage_account.this.blob_properties[0].delete_retention_policy[0].days == 7
    error_message = "Blob soft delete must be enabled by default."
  }

  assert {
    condition     = azurerm_storage_account.this.blob_properties[0].container_delete_retention_policy[0].days == 7
    error_message = "Container soft delete must be enabled by default."
  }
}

run "network_rules_can_be_opened_up" {
  variables {
    network_rules = {
      default_action = "Allow"
    }
  }

  assert {
    condition     = azurerm_storage_account.this.network_rules[0].default_action == "Allow"
    error_message = "Callers must be able to opt back in to an open storage firewall."
  }
}

run "network_rules_can_be_omitted" {
  variables {
    network_rules = null
  }

  assert {
    condition     = length(azurerm_storage_account.this.network_rules) == 0
    error_message = "Setting network_rules to null must omit the block so it can be managed elsewhere."
  }
}

run "hardened_options_are_wired_through" {
  variables {
    shared_access_key_enabled         = false
    public_network_access_enabled     = false
    infrastructure_encryption_enabled = true
  }

  assert {
    condition     = azurerm_storage_account.this.shared_access_key_enabled == false
    error_message = "shared_access_key_enabled must reach the resource."
  }

  assert {
    condition     = azurerm_storage_account.this.public_network_access_enabled == false
    error_message = "public_network_access_enabled must reach the resource."
  }

  assert {
    condition     = azurerm_storage_account.this.infrastructure_encryption_enabled == true
    error_message = "infrastructure_encryption_enabled must reach the resource."
  }
}

run "rejects_invalid_name" {
  command = plan

  variables {
    name = "Invalid_Name"
  }

  expect_failures = [var.name]
}

run "rejects_invalid_replication_type" {
  command = plan

  variables {
    account_replication_type = "SUPERLRS"
  }

  expect_failures = [var.account_replication_type]
}

run "rejects_invalid_min_tls_version" {
  command = plan

  variables {
    min_tls_version = "1.2"
  }

  expect_failures = [var.min_tls_version]
}

run "rejects_invalid_network_default_action" {
  command = plan

  variables {
    network_rules = {
      default_action = "Permit"
    }
  }

  expect_failures = [var.network_rules]
}

run "rejects_invalid_network_bypass" {
  command = plan

  variables {
    network_rules = {
      bypass = ["AzureServices", "Everything"]
    }
  }

  expect_failures = [var.network_rules]
}

run "rejects_out_of_range_retention" {
  command = plan

  variables {
    blob_delete_retention_days = 0
  }

  expect_failures = [var.blob_delete_retention_days]
}
