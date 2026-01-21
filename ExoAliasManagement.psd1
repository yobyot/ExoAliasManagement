#
# Module manifest for module 'ExoAliasManagement'
#

@{

# Script module or binary module file associated with this manifest.
RootModule = 'ExoAliasManagement.psm1'

# Version number of this module.
ModuleVersion = '0.0.1'

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

# Modules that must be imported into the global environment prior to importing this module
RequiredModules = @(
    @{ModuleName='ExchangeOnlineManagement'; ModuleVersion='3.0.0'}
)

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
AliasesToExport = @()

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
v0.0.1 (2026-01-21)
- Initial release
- Find-ExoAlias: Search for email aliases in mailboxes
- Add-ExoAlias: Add email aliases to mailboxes with verification
- Remove-ExoAlias: Remove email aliases with confirmation prompt
- Interactive authentication for Exchange Online
- Email format validation
- Pipeline support for batch operations
'@

    } # End of PSData hashtable

} # End of PrivateData hashtable

}
