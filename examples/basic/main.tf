terraform {
  required_version = ">= 1.5"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0"
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

  tags = {
    Environment = "sandbox"
    ManagedBy   = "terraform"
  }
}

output "storage_account_id" {
  value = module.storage_account.id
}
