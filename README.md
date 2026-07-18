# terraform-azurerm-storage-account

Terraform module that manages an [Azure](https://azure.microsoft.com/) storage
account. It defaults to a secure StorageV2 account (TLS 1.2, HTTPS-only, no
anonymous access) with blob versioning and a soft-delete retention policy, and
exposes the primary endpoints and access keys as sensitive outputs.

## Usage

```hcl
module "storage_account" {
  source = "github.com/cybercapybara/terraform-azurerm-storage-account"

  name                = "prodsa0storage"
  resource_group_name = "prod-rg"
  location            = "eastus"

  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```

A runnable example lives in [`examples/basic`](examples/basic).

## Requirements

| Name      | Version  |
|-----------|----------|
| terraform | >= 1.5   |
| azurerm   | >= 3.0   |

## Inputs

| Name                              | Description                                                          | Type          | Default       | Required |
|-----------------------------------|----------------------------------------------------------------------|---------------|---------------|:--------:|
| `name`                            | Name of the storage account. Globally unique, 3-24 lowercase chars.  | `string`      | n/a           |   yes    |
| `resource_group_name`             | Name of the resource group in which to create the storage account.   | `string`      | n/a           |   yes    |
| `location`                        | Azure region in which to create the storage account.                 | `string`      | n/a           |   yes    |
| `account_tier`                    | Performance tier of the storage account.                             | `string`      | `"Standard"`  |    no    |
| `account_replication_type`        | Replication strategy for the storage account.                        | `string`      | `"LRS"`       |    no    |
| `account_kind`                    | Kind of storage account.                                             | `string`      | `"StorageV2"` |    no    |
| `access_tier`                     | Default access tier for blob storage.                                | `string`      | `"Hot"`       |    no    |
| `min_tls_version`                 | Minimum TLS version accepted by the storage account.                 | `string`      | `"TLS1_2"`    |    no    |
| `https_traffic_only_enabled`      | Whether to force HTTPS-only traffic.                                  | `bool`        | `true`        |    no    |
| `allow_nested_items_to_be_public` | Whether blobs and containers may allow anonymous public access.      | `bool`        | `false`       |    no    |
| `blob_versioning_enabled`         | Whether blob versioning is enabled.                                  | `bool`        | `true`        |    no    |
| `blob_delete_retention_days`      | Days deleted blobs are retained before permanent deletion.           | `number`      | `7`           |    no    |
| `tags`                            | Map of tags applied to the storage account.                          | `map(string)` | `{}`          |    no    |

## Outputs

| Name                        | Description                                        |
|-----------------------------|----------------------------------------------------|
| `id`                        | ID of the storage account.                         |
| `name`                      | Name of the storage account.                       |
| `primary_blob_endpoint`     | Endpoint URL for blob storage in the primary region.|
| `primary_access_key`        | Primary access key (sensitive).                    |
| `primary_connection_string` | Primary connection string (sensitive).             |

## License

[MIT](LICENSE)
