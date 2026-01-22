# Changelog

All notable changes to the ExoAliasManagement module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.4] - 2026-01-22

### Changed
- Added `CompatiblePSEditions = @('Core')` to manifest to explicitly indicate PowerShell 7+ requirement
- Removed `RequiredModules` from manifest to fix GitHub Actions build failures
- Dependency enforcement now handled by `#requires` statement in .psm1 file for runtime validation

### Fixed
- GitHub Actions workflow permissions corrected for automated publishing to PowerShell Gallery
- Test-ModuleManifest validation now works in CI/CD environments without ExchangeOnlineManagement installed

## [0.0.3] - 2026-01-22

### Added
- GitHub Actions workflow for automated publishing to PowerShell Gallery
- PUBLISHING.md documentation with detailed instructions for PowerShell Gallery deployment

### Changed
- Updated RequiredModules to remove version constraint (preparation for manifest fixes)

## [0.0.2] - 2026-01-22

### Changed
- Updated documentation in README.md with prerequisites and version information
- Refined module manifest metadata

## [0.0.1] - 2026-01-21

### Added
- Initial release
- `Find-ExoAlias`: Search for email aliases in mailboxes
- `Add-ExoAlias`: Add email aliases to mailboxes with verification
- `Remove-ExoAlias`: Remove email aliases with confirmation prompt
- Interactive authentication for Exchange Online
- Email format validation
- Pipeline support for batch operations
- Smart sorting with color-coded display (primary SMTP green, aliases yellow)
