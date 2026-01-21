# Changelog

All notable changes to the ExoAliasManagement module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.2] - 2026-01-19

### Changed
- **BREAKING**: Removed credential management and SecretStore dependencies
- **BREAKING**: Removed AdminIdentity parameter from all functions
- Switched to interactive authentication for Exchange Online
- Significantly simplified module (44% code reduction)
- Improved ease of use with fewer required parameters

### Removed
- Dependency on Microsoft.PowerShell.SecretManagement
- Dependency on Microsoft.PowerShell.SecretStore
- AdminIdentity parameter from all cmdlets

## [0.0.1] - 2026-01-18

### Added
- Initial release
- `Find-ExoAlias`: Search for email aliases in mailboxes
- `Add-ExoAlias`: Add email aliases to mailboxes with verification
- `Remove-ExoAlias`: Remove email aliases with confirmation prompt
- Integrated credential management using PowerShell SecretStore
- Email format validation
- Pipeline support for batch operations
- Smart sorting with color-coded display (primary SMTP green, aliases yellow)
