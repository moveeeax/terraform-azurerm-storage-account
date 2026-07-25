variable "name" {
  description = "Name of the storage account. Must be globally unique, 3-24 lowercase alphanumeric characters."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.name))
    error_message = "The name must be 3-24 characters long and contain only lowercase letters and digits."
  }
}

variable "resource_group_name" {
  description = "Name of the resource group in which to create the storage account."
  type        = string
}

variable "location" {
  description = "Azure region in which to create the storage account."
  type        = string
}

variable "account_tier" {
  description = "Performance tier of the storage account. Either Standard or Premium."
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Standard", "Premium"], var.account_tier)
    error_message = "The account_tier must be either Standard or Premium."
  }
}

variable "account_replication_type" {
  description = "Replication strategy for the storage account, e.g. LRS, ZRS, GRS or RAGRS."
  type        = string
  default     = "LRS"

  validation {
    condition     = contains(["LRS", "ZRS", "GRS", "RAGRS", "GZRS", "RAGZRS"], var.account_replication_type)
    error_message = "The account_replication_type must be one of LRS, ZRS, GRS, RAGRS, GZRS or RAGZRS."
  }
}

variable "account_kind" {
  description = "Kind of storage account, e.g. StorageV2, BlobStorage or FileStorage."
  type        = string
  default     = "StorageV2"

  validation {
    condition     = contains(["Storage", "StorageV2", "BlobStorage", "BlockBlobStorage", "FileStorage"], var.account_kind)
    error_message = "The account_kind must be one of Storage, StorageV2, BlobStorage, BlockBlobStorage or FileStorage."
  }
}

variable "access_tier" {
  description = "Default access tier for blob storage. One of Hot, Cool, Cold or Premium."
  type        = string
  default     = "Hot"

  validation {
    condition     = contains(["Hot", "Cool", "Cold", "Premium"], var.access_tier)
    error_message = "The access_tier must be one of Hot, Cool, Cold or Premium."
  }
}

variable "min_tls_version" {
  description = "Minimum TLS version accepted by the storage account. Azure Storage rejects anything below TLS1_2, so lower values are accepted here only for parity with the provider."
  type        = string
  default     = "TLS1_2"

  validation {
    condition     = contains(["TLS1_0", "TLS1_1", "TLS1_2"], var.min_tls_version)
    error_message = "The min_tls_version must be one of TLS1_0, TLS1_1 or TLS1_2."
  }
}

variable "https_traffic_only_enabled" {
  description = "Whether to force HTTPS-only traffic to the storage account."
  type        = bool
  default     = true
}

variable "allow_nested_items_to_be_public" {
  description = "Whether blobs and containers may be configured for anonymous public access. The Azure default is true; this module defaults to false."
  type        = bool
  default     = false
}

variable "shared_access_key_enabled" {
  description = "Whether the account's shared access keys may be used to authorise data-plane requests. Set to false to require Entra ID authentication; the primary_access_key and primary_connection_string outputs are then empty."
  type        = bool
  default     = true
}

variable "public_network_access_enabled" {
  description = "Whether the storage account is reachable from the public internet at all. Set to false when access is exclusively through private endpoints."
  type        = bool
  default     = true
}

variable "infrastructure_encryption_enabled" {
  description = "Whether to enable a second layer of encryption at rest for the account. Can only be set at creation time - changing it on an existing account forces replacement."
  type        = bool
  default     = false
}

variable "network_rules" {
  description = "Storage firewall configuration. Defaults to denying all traffic except trusted Azure services. Set to null to omit the block entirely, for example when the firewall is managed by a separate azurerm_storage_account_network_rules resource."
  type = object({
    default_action             = optional(string, "Deny")
    bypass                     = optional(set(string), ["AzureServices"])
    ip_rules                   = optional(set(string), [])
    virtual_network_subnet_ids = optional(set(string), [])
  })
  default = {}

  validation {
    condition     = var.network_rules == null || contains(["Allow", "Deny"], try(var.network_rules.default_action, ""))
    error_message = "The network_rules.default_action must be either Allow or Deny."
  }

  validation {
    condition     = var.network_rules == null || length(setsubtract(try(var.network_rules.bypass, []), ["AzureServices", "Logging", "Metrics", "None"])) == 0
    error_message = "Each network_rules.bypass entry must be one of AzureServices, Logging, Metrics or None."
  }
}

variable "blob_versioning_enabled" {
  description = "Whether blob versioning is enabled on the storage account."
  type        = bool
  default     = true
}

variable "blob_delete_retention_days" {
  description = "Number of days deleted blobs are retained before permanent deletion."
  type        = number
  default     = 7

  validation {
    condition     = var.blob_delete_retention_days >= 1 && var.blob_delete_retention_days <= 365 && floor(var.blob_delete_retention_days) == var.blob_delete_retention_days
    error_message = "The blob_delete_retention_days must be a whole number between 1 and 365."
  }
}

variable "container_delete_retention_days" {
  description = "Number of days deleted blob containers are retained before permanent deletion."
  type        = number
  default     = 7

  validation {
    condition     = var.container_delete_retention_days >= 1 && var.container_delete_retention_days <= 365 && floor(var.container_delete_retention_days) == var.container_delete_retention_days
    error_message = "The container_delete_retention_days must be a whole number between 1 and 365."
  }
}

variable "tags" {
  description = "Map of tags applied to the storage account."
  type        = map(string)
  default     = {}
}
