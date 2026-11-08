terraform {
  required_version = ">= 1.5"

  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      # `azurerm_storage_container.storage_account_id` first appears in 4.9.0.
      # Earlier releases only accept `storage_account_name`, and 5.0 removed
      # that, so no single argument covers both 3.x and 5.x.
      # Ceiling: the next major. Tested on 5.x; 6.0 has not been vetted.
      version = ">= 4.9.0, < 6.0"
    }
  }
}
