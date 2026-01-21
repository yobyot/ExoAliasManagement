# ExoAliasManagement Module

PowerShell module for managing Exchange Online email aliases.

## Description

ExoAliasManagement provides a set of functions to find, add, and remove email aliases from Exchange Online mailboxes. The module uses interactive authentication for Exchange Online connections and includes email format validation.

## Installation

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

This module requires the following module:
- ExchangeOnlineManagement (v3.0.0 or higher)

Install prerequisites:
```powershell
Install-Module ExchangeOnlineManagement -MinimumVersion 3.0.0
```

## Functions

### Find-ExoAlias

Searches for an email alias in an Exchange Online mailbox. Uses interactive authentication to connect to Exchange Online. Displays aliases sorted with primary SMTP address first (green), then secondary aliases (yellow). Returns custom objects to the pipeline that can be piped to Remove-ExoAlias.

**Syntax:**
```powershell
Find-ExoAlias [[-AddressToBeSearched] <String>] [-MailboxToBeSearched] <String>
```

**Parameters:**
- `AddressToBeSearched`: Optional. Search pattern for aliases. If empty or omitted, returns all aliases.
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
Add-ExoAlias [-AddressToBeAdded] <String> [-MailboxToAddAlias] <String>
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
Remove-ExoAlias [-AddressToBeRemoved] <String> [[-MailboxToBeRemoved] <String>]
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

## Features

- **Interactive Authentication**: Uses interactive login for Exchange Online connections
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

### v0.0.2 (2026-01-19)
- **Breaking Change**: Removed credential management and SecretStore dependencies
- **Breaking Change**: Removed AdminIdentity parameter from all functions
- Switched to interactive authentication for Exchange Online
- Significantly simplified module (44% code reduction)
- Improved ease of use with fewer required parameters

### v0.0.1 (2026-01-18)
- Initial release
- Find-ExoAlias: Search for email aliases in mailboxes
- Add-ExoAlias: Add email aliases to mailboxes with verification
- Remove-ExoAlias: Remove email aliases with confirmation prompt
- Integrated credential management using PowerShell SecretStore
- Email format validation

## Author

Alex Neihaus

## License

Copyright © 2026 Air11 LLC

This module is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
