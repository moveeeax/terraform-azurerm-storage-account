terraform {
  required_version = ">= 1.5"

  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      # `https_traffic_only_enabled` (the azurerm 4.x name for what 3.x called
      # `enable_https_traffic_only`) was only back-ported to the 3.x line in
      # 3.117.0. Anything older fails with "Unsupported argument".
      # Ceiling: the next major. Tested on 5.x; 6.0 has not been vetted.
      version = ">= 3.117.0, < 6.0"
    }
  }
}
