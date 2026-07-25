# terraform-azurerm-storage-account

Terraform module that manages an [Azure](https://azure.microsoft.com/) storage
account. It defaults to a secure StorageV2 account — TLS 1.2, HTTPS-only, no
anonymous access, and a storage firewall that denies everything except trusted
Azure services — with blob and container soft delete plus versioning, and
exposes the primary endpoints and access keys as sensitive outputs.

## Usage

```hcl
module "storage_account" {
  source = "github.com/moveeeax/terraform-azurerm-storage-account"

  name                = "prodsa0storage"
  resource_group_name = "prod-rg"
  location            = "eastus"

  account_tier             = "Standard"
  account_replication_type = "GRS"

  # The firewall denies everything by default. Allow-list what needs access.
  network_rules = {
    default_action             = "Deny"
    ip_rules                   = ["203.0.113.0/24"]
    virtual_network_subnet_ids = [azurerm_subnet.app.id]
  }

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```

A runnable example lives in [`examples/basic`](examples/basic).

### Network access

`network_rules` controls the storage firewall and defaults to
`default_action = "Deny"` with `bypass = ["AzureServices"]`. Nothing reaches the
data plane until you allow-list it. There are three ways to work with it:

| Goal                                        | Setting                                  |
|---------------------------------------------|------------------------------------------|
| Deny by default, allow specific networks    | leave the default and set `ip_rules` / `virtual_network_subnet_ids` |
| Open to all networks (pre-v1 behaviour)     | `network_rules = { default_action = "Allow" }` |
| Manage the firewall in a separate resource  | `network_rules = null` (omits the block entirely) |

Use the last option if you also declare an
`azurerm_storage_account_network_rules` resource — declaring both fights over
the same setting.

## Requirements

| Name      | Version              |
|-----------|----------------------|
| terraform | >= 1.5               |
| azurerm   | >= 3.117.0, < 5.0    |

`https_traffic_only_enabled` only exists in azurerm 3.117.0 and later (in older
3.x releases it was called `enable_https_traffic_only`), which is why the lower
bound is 3.117.0 rather than 3.0.

Running the test suite in [`tests/`](tests) additionally needs Terraform >= 1.7
for `mock_provider`. That is a test-only requirement; the module itself still
works on 1.5.

## Inputs

| Name                                | Description                                                                 | Type            | Default       | Required |
|-------------------------------------|-----------------------------------------------------------------------------|-----------------|---------------|:--------:|
| `name`                              | Name of the storage account. Globally unique, 3-24 lowercase chars.         | `string`        | n/a           |   yes    |
| `resource_group_name`               | Name of the resource group in which to create the storage account.          | `string`        | n/a           |   yes    |
| `location`                          | Azure region in which to create the storage account.                        | `string`        | n/a           |   yes    |
| `account_tier`                      | Performance tier of the storage account.                                    | `string`        | `"Standard"`  |    no    |
| `account_replication_type`          | Replication strategy for the storage account.                               | `string`        | `"LRS"`       |    no    |
| `account_kind`                      | Kind of storage account.                                                    | `string`        | `"StorageV2"` |    no    |
| `access_tier`                       | Default access tier for blob storage.                                       | `string`        | `"Hot"`       |    no    |
| `min_tls_version`                   | Minimum TLS version accepted by the storage account.                        | `string`        | `"TLS1_2"`    |    no    |
| `https_traffic_only_enabled`        | Whether to force HTTPS-only traffic.                                        | `bool`          | `true`        |    no    |
| `allow_nested_items_to_be_public`   | Whether blobs and containers may allow anonymous public access.             | `bool`          | `false`       |    no    |
| `shared_access_key_enabled`         | Whether shared access keys may authorise data-plane requests.               | `bool`          | `true`        |    no    |
| `public_network_access_enabled`     | Whether the account is reachable from the public internet at all.           | `bool`          | `true`        |    no    |
| `infrastructure_encryption_enabled` | Second layer of encryption at rest. Changing this replaces the account.     | `bool`          | `false`       |    no    |
| `network_rules`                     | Storage firewall. `null` omits the block. See [Network access](#network-access). | `object`   | deny-by-default |  no    |
| `blob_versioning_enabled`           | Whether blob versioning is enabled.                                         | `bool`          | `true`        |    no    |
| `blob_delete_retention_days`        | Days deleted blobs are retained before permanent deletion (1-365).          | `number`        | `7`           |    no    |
| `container_delete_retention_days`   | Days deleted containers are retained before permanent deletion (1-365).     | `number`        | `7`           |    no    |
| `tags`                              | Map of tags applied to the storage account.                                 | `map(string)`   | `{}`          |    no    |

## Outputs

| Name                        | Description                                        |
|-----------------------------|----------------------------------------------------|
| `id`                        | ID of the storage account.                         |
| `name`                      | Name of the storage account.                       |
| `primary_blob_endpoint`     | Endpoint URL for blob storage in the primary region.|
| `primary_access_key`        | Primary access key (sensitive).                    |
| `primary_connection_string` | Primary connection string (sensitive).             |

`primary_access_key` and `primary_connection_string` are empty when
`shared_access_key_enabled = false`.

## Development

```sh
terraform fmt -recursive
terraform init -backend=false && terraform validate
terraform test
```

## License

[MIT](LICENSE)
