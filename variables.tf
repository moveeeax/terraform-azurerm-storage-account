variable "name" {
  description = "Name of the storage account. Must be globally unique, 3-24 lowercase alphanumeric characters."
  type        = string
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
}

variable "account_replication_type" {
  description = "Replication strategy for the storage account, e.g. LRS, ZRS, GRS or RAGRS."
  type        = string
  default     = "LRS"
}

variable "account_kind" {
  description = "Kind of storage account, e.g. StorageV2, BlobStorage or FileStorage."
  type        = string
  default     = "StorageV2"
}

variable "access_tier" {
  description = "Default access tier for blob storage. Either Hot or Cool."
  type        = string
  default     = "Hot"
}

variable "min_tls_version" {
  description = "Minimum TLS version accepted by the storage account."
  type        = string
  default     = "TLS1_2"
}

variable "https_traffic_only_enabled" {
  description = "Whether to force HTTPS-only traffic to the storage account."
  type        = bool
  default     = true
}

variable "allow_nested_items_to_be_public" {
  description = "Whether blobs and containers may be configured for anonymous public access."
  type        = bool
  default     = false
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
}

variable "tags" {
  description = "Map of tags applied to the storage account."
  type        = map(string)
  default     = {}
}
