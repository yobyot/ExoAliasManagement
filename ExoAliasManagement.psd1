#
# Module manifest for module 'ExoAliasManagement'
#

@{

# Script module or binary module file associated with this manifest.
RootModule = 'ExoAliasManagement.psm1'

# Version number of this module.
ModuleVersion = '0.0.6'

# ID used to uniquely identify this module
GUID = 'a1b2c3d4-e5f6-4789-a012-3456789abcde'

# Author of this module
Author = 'Alex Neihaus'

# Company or vendor of this module
CompanyName = 'Air11 LLC'

# Copyright statement for this module
Copyright = '(c) 2026 Air11 LLC'

# Description of the functionality provided by this module
Description = 'PowerShell module for managing Exchange Online email aliases. Provides functions to find, add, and remove email aliases from Exchange Online mailboxes using interactive authentication.'

# Minimum version of the PowerShell engine required by this module
PowerShellVersion = '7.0'

# Supported PSEditions
CompatiblePSEditions = @('Core')

# Modules that must be imported into the global environment prior to importing this module
# NOTE: RequiredModules is commented out because the #requires statement in the .psm1 file
# already enforces this dependency at runtime. This prevents issues during Test-ModuleManifest
# in build environments where ExchangeOnlineManagement may not be installed.
#RequiredModules = @(
#    @{ ModuleName = 'ExchangeOnlineManagement'; ModuleVersion = '0.0.6' }
#)

# Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
FunctionsToExport = @(
    'Find-ExoAlias',
    'Add-ExoAlias',
    'Remove-ExoAlias'
)

# Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
CmdletsToExport = @()

# Variables to export from this module
VariablesToExport = @()

# Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
AliasesToExport = @('fea', 'aea', 'rea')

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = @('Exchange', 'ExchangeOnline', 'Office365', 'Email', 'Alias', 'Mailbox')

        # A URL to the license for this module.
        # LicenseUri = ''

        # A URL to the main website for this project.
        # ProjectUri = ''

        # ReleaseNotes of this module
        ReleaseNotes = @'
v0.0.6 (2026-01-26)
- New `SyncChangelogs.ps1` script to synchronize CHANGELOG.md with manifest and README.md
- PowerShell aliases for convenience: `fea` (Find-ExoAlias), `aea` (Add-ExoAlias), `rea` (Remove-ExoAlias)
- CHANGELOG.md is now the single source of truth for all version history
- `Release.ps1` no longer syncs README.md automatically - use `SyncChangelogs.ps1` instead
- Workflow updated: Update CHANGELOG.md first, then run SyncChangelogs.ps1 to propagate changes

v0.0.5 (2026-01-25)
- New private function `Test-MailboxAndEmailFormat` to validate both email format and mailbox existence
- Mailbox existence validation using `Get-CasMailbox` in all public functions
- `Find-ExoAlias` now validates that the target mailbox exists in Exchange Online before searching
- `Add-ExoAlias` now validates that the target mailbox exists in Exchange Online before adding aliases
- `Remove-ExoAlias` now validates that the target mailbox exists in Exchange Online before removing aliases
- Enhanced error messages to indicate both format validation and mailbox existence failures
- Reliability by preventing operations on non-existent mailboxes
- User experience with clearer error messages

v0.0.4 (2026-01-22)
- Added `CompatiblePSEditions = @('Core')` to manifest to explicitly indicate PowerShell 7+ requirement
- Removed `RequiredModules` from manifest to fix GitHub Actions build failures
- Dependency enforcement now handled by `#requires` statement in .psm1 file for runtime validation
- GitHub Actions workflow permissions corrected for automated publishing to PowerShell Gallery
- Test-ModuleManifest validation now works in CI/CD environments without ExchangeOnlineManagement installed

v0.0.3 (2026-01-22)
- GitHub Actions workflow for automated publishing to PowerShell Gallery
- PUBLISHING.md documentation with detailed instructions for PowerShell Gallery deployment
- Updated RequiredModules to remove version constraint (preparation for manifest fixes)

v0.0.2 (2026-01-22)
- Updated documentation in README.md with prerequisites and version information
- Refined module manifest metadata

v0.0.1 (2026-01-21)
- Initial release
- `Find-ExoAlias`: Search for email aliases in mailboxes
- `Add-ExoAlias`: Add email aliases to mailboxes with verification
- `Remove-ExoAlias`: Remove email aliases with confirmation prompt
- Interactive authentication for Exchange Online
- Email format validation
- Pipeline support for batch operations
- Smart sorting with color-coded display (primary SMTP green, aliases yellow)
'@

    } # End of PSData hashtable

} # End of PrivateData hashtable

}
