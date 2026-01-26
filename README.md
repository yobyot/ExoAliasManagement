# ExoAliasManagement Module

PowerShell module for managing Exchange Online email aliases.

## Description

ExoAliasManagement provides a set of functions to find, add, and remove email aliases from Exchange Online mailboxes. The module uses interactive authentication for Exchange Online connections and includes email format validation.

## Installation

### From PowerShell Gallery (Recommended)

```powershell
# Install for the current user
Install-Module -Name ExoAliasManagement -Scope CurrentUser

# Or install for all users (requires administrator privileges)
Install-Module -Name ExoAliasManagement -Scope AllUsers

# Import the module
Import-Module ExoAliasManagement
```

### From GitHub

```powershell
# Clone the repository
git clone https://github.com/YourUsername/ExoAliasManagement.git

# Copy the module folder to your PowerShell modules directory
Copy-Item -Path ./ExoAliasManagement/ExoAliasManagement -Destination "$HOME/Documents/PowerShell/Modules/" -Recurse

# Import the module
Import-Module ExoAliasManagement
```

### Manual Installation

1. Copy the `ExoAliasManagement` folder to one of your PowerShell module paths:
   - Current user: `$HOME\Documents\PowerShell\Modules\`
   - All users: `C:\Program Files\PowerShell\Modules\`
   - Or any path in `$env:PSModulePath`

2. Import the module:
   ```powershell
   Import-Module ExoAliasManagement
   ```

## Prerequisites

- **PowerShell 7.0 or higher** (PowerShell Core)
- **ExchangeOnlineManagement module** (v3.9.2 or higher)

Install prerequisites:
```powershell
# Install the ExchangeOnlineManagement module
Install-Module ExchangeOnlineManagement -MinimumVersion 3.9.2

# Verify PowerShell version (should be 7.0 or higher)
$PSVersionTable.PSVersion
```

## Functions

### Find-ExoAlias

Searches for an email alias in an Exchange Online mailbox. Uses interactive authentication to connect to Exchange Online. Displays aliases sorted with primary SMTP address first (green), then secondary aliases (yellow). Returns custom objects to the pipeline that can be piped to Remove-ExoAlias.

**Syntax:**
```powershell
Find-ExoAlias <String> -MailboxToBeSearched <String>
```

**Parameters:**
- `AddressToBeSearched`: Search pattern for aliases. Use empty string "" to return all aliases.
- `MailboxToBeSearched`: Required. The mailbox email address to search.

**Examples:**
```powershell
# Search for aliases matching a pattern
Find-ExoAlias -AddressToBeSearched "test" -MailboxToBeSearched "user@example.com"

# Return all aliases for a mailbox
Find-ExoAlias "" "user@example.com"

# Search using positional parameters
Find-ExoAlias "old" "user@example.com"

# Pipe results to Remove-ExoAlias
Find-ExoAlias "temp" "user@example.com" | Remove-ExoAlias
```

### Add-ExoAlias

Adds an email alias to an Exchange Online mailbox and verifies it was added successfully. Uses interactive authentication to connect to Exchange Online.

**Syntax:**
```powershell
Add-ExoAlias -AddressToBeAdded <String> -MailboxToAddAlias <String>
```

**Examples:**
```powershell
# Add a new alias
Add-ExoAlias -AddressToBeAdded "newalias@domain.com" -MailboxToAddAlias "user@example.com"

# Positional parameters
Add-ExoAlias "newalias@domain.com" "user@example.com"
```

### Remove-ExoAlias

Removes an email alias from an Exchange Online mailbox with confirmation prompt. Uses interactive authentication to connect to Exchange Online. Accepts pipeline input from Find-ExoAlias for batch operations.

**Syntax:**
```powershell
Remove-ExoAlias -AddressToBeRemoved <String> [[-MailboxToBeRemoved] <String>]
```

**Parameters:**
- `AddressToBeRemoved`: Required. The alias to remove. Accepts pipeline input from Find-ExoAlias.
- `MailboxToBeRemoved`: Optional when piping from Find-ExoAlias. Required otherwise.

**Examples:**
```powershell
# Remove an alias (will prompt for confirmation)
Remove-ExoAlias -AddressToBeRemoved "oldalias@domain.com" -MailboxToBeRemoved "user@example.com"

# Positional parameters
Remove-ExoAlias "oldalias@domain.com" "user@example.com"

# Remove multiple aliases using pipeline
Find-ExoAlias "test" "user@example.com" | Remove-ExoAlias
```

## Private Functions

The following helper functions support the public cmdlets. They are internal to the module (not exported) but documented here for completeness.

- **Connect-ExoInteractive**: Connects to Exchange Online using interactive authentication.
- **Get-ExoMailboxAddresses**: Retrieves all email addresses for a specified mailbox.
- **Find-ExoAliasInAddresses**: Searches for an alias in a collection of email addresses.
- **Test-EmailFormat**: Validates that a string is in proper email format.
- **Test-MailboxAndEmailFormat**: Validates email format and verifies mailbox exists in Exchange Online using Get-CasMailbox.

## Features

- **Interactive Authentication**: Uses interactive login for Exchange Online connections
- **Mailbox Validation**: Verifies mailboxes exist in Exchange Online before performing operations
- **Pipeline Support**: Find-ExoAlias outputs objects that can be piped to Remove-ExoAlias for batch operations
- **Smart Sorting**: Aliases displayed with primary SMTP address first (green), then secondary aliases (yellow)
- **Email Validation**: Validates email addresses are in proper user@example.com format
- **Verification**: Add-ExoAlias verifies the alias was successfully added
- **Confirmation**: Remove-ExoAlias prompts for confirmation before removing aliases
- **Performance Optimization**: Caches mailbox data when processing multiple aliases for the same mailbox
- **Error Handling**: Clear error messages and validation
- **Simplified Interface**: Streamlined parameters for ease of use

## Authentication

This module uses interactive authentication for Exchange Online. When you run any of the functions, you will be prompted to sign in to Exchange Online using your web browser or the Microsoft authentication dialog. This provides the most secure and flexible authentication method.

## Usage Examples

```powershell
# Import the module
Import-Module ExoAliasManagement

# Search for aliases containing "test"
Find-ExoAlias "test" "john@contoso.com"

# Get all aliases for a mailbox
Find-ExoAlias "" "john@contoso.com"

# Add a new alias
Add-ExoAlias "john.doe@contoso.com" "john@contoso.com"

# Remove a single alias (will ask for confirmation)
Remove-ExoAlias "old.alias@contoso.com" "john@contoso.com"

# Remove all aliases matching a pattern (pipeline)
Find-ExoAlias "temp" "john@contoso.com" | Remove-ExoAlias

# Find and remove old test aliases
Find-ExoAlias "test" "john@contoso.com" | Remove-ExoAlias
```

## Version History


### v0.0.6 (2026-01-26)
- New `SyncChangelogs.ps1` script to synchronize CHANGELOG.md with manifest and README.md
- PowerShell aliases for convenience: `fea` (Find-ExoAlias), `aea` (Add-ExoAlias), `rea` (Remove-ExoAlias)
- CHANGELOG.md is now the single source of truth for all version history
- `Release.ps1` no longer syncs README.md automatically - use `SyncChangelogs.ps1` instead
- Workflow updated: Update CHANGELOG.md first, then run SyncChangelogs.ps1 to propagate changes

### v0.0.5 (2026-01-25)
- New private function `Test-MailboxAndEmailFormat` to validate both email format and mailbox existence
- Mailbox existence validation using `Get-CasMailbox` in all public functions
- `Find-ExoAlias` now validates that the target mailbox exists in Exchange Online before searching
- `Add-ExoAlias` now validates that the target mailbox exists in Exchange Online before adding aliases
- `Remove-ExoAlias` now validates that the target mailbox exists in Exchange Online before removing aliases
- Enhanced error messages to indicate both format validation and mailbox existence failures
- Reliability by preventing operations on non-existent mailboxes
- User experience with clearer error messages

### v0.0.4 (2026-01-22)
- Added `CompatiblePSEditions = @('Core')` to manifest to explicitly indicate PowerShell 7+ requirement
- Removed `RequiredModules` from manifest to fix GitHub Actions build failures
- Dependency enforcement now handled by `#requires` statement in .psm1 file for runtime validation
- GitHub Actions workflow permissions corrected for automated publishing to PowerShell Gallery
- Test-ModuleManifest validation now works in CI/CD environments without ExchangeOnlineManagement installed

### v0.0.3 (2026-01-22)
- GitHub Actions workflow for automated publishing to PowerShell Gallery
- PUBLISHING.md documentation with detailed instructions for PowerShell Gallery deployment
- Updated RequiredModules to remove version constraint (preparation for manifest fixes)

### v0.0.2 (2026-01-22)
- Updated documentation in README.md with prerequisites and version information
- Refined module manifest metadata

### v0.0.1 (2026-01-21)
- Initial release
- `Find-ExoAlias`: Search for email aliases in mailboxes
- `Add-ExoAlias`: Add email aliases to mailboxes with verification
- `Remove-ExoAlias`: Remove email aliases with confirmation prompt
- Interactive authentication for Exchange Online
- Email format validation
- Pipeline support for batch operations
- Smart sorting with color-coded display (primary SMTP green, aliases yellow)


## Author

Alex Neihaus

## License

Copyright © 2026 Air11 LLC

This module is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
