# ExoAliasManagement Usage Examples
# These examples demonstrate the various ways to use the module

# Import the module
Import-Module ExoAliasManagement

#region Find-ExoAlias Examples

# Example 1: Search for aliases containing "test"
Find-ExoAlias -AddressToBeSearched "test" -MailboxToBeSearched "john@contoso.com"

# Example 2: Get all aliases for a mailbox
Find-ExoAlias -AddressToBeSearched "" -MailboxToBeSearched "john@contoso.com"

# Example 3: Using positional parameters
Find-ExoAlias "old" "john@contoso.com"

# Example 4: Find aliases matching a pattern and display them
$aliases = Find-ExoAlias "temp" "john@contoso.com"
$aliases | Format-Table

#endregion

#region Add-ExoAlias Examples

# Example 1: Add a new alias with named parameters
Add-ExoAlias -AddressToBeAdded "john.doe@contoso.com" -MailboxToAddAlias "john@contoso.com"

# Example 2: Add multiple aliases
$newAliases = @(
    "jdoe@contoso.com",
    "johndoe@contoso.com",
    "j.doe@contoso.com"
)

foreach ($alias in $newAliases) {
    Add-ExoAlias $alias "john@contoso.com"
}

# Example 3: Using positional parameters
Add-ExoAlias "newalias@contoso.com" "john@contoso.com"

#endregion

#region Remove-ExoAlias Examples

# Example 1: Remove a single alias (will prompt for confirmation)
Remove-ExoAlias -AddressToBeRemoved "oldalias@contoso.com" -MailboxToBeRemoved "john@contoso.com"

# Example 2: Remove using positional parameters
Remove-ExoAlias "temp@contoso.com" "john@contoso.com"

# Example 3: Pipeline - Find and remove matching aliases
Find-ExoAlias "test" "john@contoso.com" | Remove-ExoAlias

# Example 4: Remove multiple aliases matching a pattern
Find-ExoAlias "temp" "john@contoso.com" | Remove-ExoAlias

#endregion

#region Complete Workflow Examples

# Workflow 1: Audit mailbox aliases
Write-Host "`nAll aliases for john@contoso.com:" -ForegroundColor Cyan
Find-ExoAlias "" "john@contoso.com"

# Workflow 2: Clean up test aliases
Write-Host "`nRemoving test aliases..." -ForegroundColor Yellow
Find-ExoAlias "test" "john@contoso.com" | Remove-ExoAlias

# Workflow 3: Add new aliases and verify
$mailbox = "john@contoso.com"
Add-ExoAlias "j.doe@contoso.com" $mailbox
Write-Host "`nVerifying new alias was added:" -ForegroundColor Green
Find-ExoAlias "j.doe" $mailbox

# Workflow 4: Replace old domain aliases with new domain
$mailbox = "john@contoso.com"
$oldDomain = "olddomain.com"
$newDomain = "newdomain.com"

# Find aliases with old domain
$oldAliases = Find-ExoAlias $oldDomain $mailbox

# For each old alias, create equivalent new alias and remove old one
foreach ($alias in $oldAliases) {
    $localPart = ($alias.Address -split '@')[0]
    $newAlias = "$localPart@$newDomain"
    
    Write-Host "Migrating $($alias.Address) to $newAlias" -ForegroundColor Cyan
    Add-ExoAlias $newAlias $mailbox
    Remove-ExoAlias $alias.Address $mailbox
}

#endregion

#region Error Handling Examples

# Example: Handle non-existent mailbox
try {
    Find-ExoAlias "" "nonexistent@contoso.com"
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

# Example: Handle invalid email format
try {
    Add-ExoAlias "not-an-email" "john@contoso.com"
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

#endregion
