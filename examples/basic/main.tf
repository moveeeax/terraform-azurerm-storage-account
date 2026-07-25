terraform {
  required_version = ">= 1.5"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.117.0, < 5.0"
    }
  }
}

provider "azurerm" {
  features {}
}

module "storage_account" {
  source = "../.."

  name                = "examplesa0storage"
  resource_group_name = "example-rg"
  location            = "eastus"

  account_tier             = "Standard"
  account_replication_type = "LRS"

  # The module denies all network traffic by default. Allow-list the ranges
  # that actually need data-plane access, or set `network_rules = null` to
  # leave the firewall alone.
  network_rules = {
    default_action = "Deny"
    ip_rules       = ["203.0.113.0/24"]
  }

  tags = {
    Environment = "sandbox"
    ManagedBy   = "terraform"
  }
}

output "storage_account_id" {
  value = module.storage_account.id
}
