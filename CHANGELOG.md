# Changelog

All notable changes to this module are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the project uses
[Semantic Versioning](https://semver.org/).

## [Unreleased]

## [2.0.0] - 2026-11-08

### Added

- `containers` input creates `azurerm_storage_container` resources keyed by
  container name, with `access_type` (default `private`) and `metadata`. A
  container with `blob` or `container` access fails the plan unless
  `allow_nested_items_to_be_public = true`. New `container_ids` output.
  Defaults to `{}`, so existing deployments plan the same.

### Changed

- Breaking: the azurerm floor is raised from 3.117.0 to 4.9.0. Containers use
  `storage_account_id`, which first appears in 4.9.0; azurerm 5.0 removed the
  older `storage_account_name`, so no single argument works on both 3.x and
  5.x. Consumers on azurerm 3.x or 4.0-4.8 must upgrade the provider first.

## [1.1.0] - 2026-11-05

### Changed

- Allow azurerm < 6.0 and accept only `TLS1_2` for `min_tls_version`.
- CI: group Dependabot updates monthly and auto-merge patch updates.

## [1.0.0]

Initial release (`v0.1.0` points at the same commit).

[Unreleased]: https://github.com/moveeeax/terraform-azurerm-storage-account/compare/v2.0.0...HEAD
[2.0.0]: https://github.com/moveeeax/terraform-azurerm-storage-account/compare/v1.1.0...v2.0.0
[1.1.0]: https://github.com/moveeeax/terraform-azurerm-storage-account/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/moveeeax/terraform-azurerm-storage-account/releases/tag/v1.0.0
