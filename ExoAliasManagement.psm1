#requires -Version 7.0
#requires -Modules @{ModuleName='ExchangeOnlineManagement'; ModuleVersion='3.9.2'}

<#
.NOTES
    Copyright © 2026 Air11 LLC. All rights reserved.
    
    Licensed under the MIT License.
    See https://opensource.org/licenses/MIT for license information.
#>

# ExoAliasManagement Module
# PowerShell module for managing Exchange Online email aliases

#region Private Functions

function Connect-ExoInteractive {
    <#
    .SYNOPSIS
    Connects to Exchange Online using interactive authentication.
    
    .DESCRIPTION
    Checks if already connected to Exchange Online. If not connected,
    establishes a connection using interactive login.
    #>
    
    try {
        # Test if already connected by attempting a simple cmdlet
        $null = Get-OrganizationConfig -ErrorAction Stop
        Write-Verbose "Already connected to Exchange Online."
    } catch {
        # Not connected, initiate interactive login
        Write-Host "Connecting to Exchange Online..." -ForegroundColor Cyan
        Connect-ExchangeOnline -ShowBanner:$false
    }
}

function Get-ExoMailboxAddresses {
    <#
    .SYNOPSIS
    Retrieves all email addresses for a specified mailbox.
    
    .DESCRIPTION
    Queries Exchange Online for a mailbox and returns its email addresses.
    
    .PARAMETER Identity
    The identity of the mailbox to query.
    
    .OUTPUTS
    Array of email addresses from the mailbox.
    #>
    
    param(
        [Parameter(Mandatory = $true)]
        [string]$Identity
    )
    
    $mbox = Get-EXOMailbox -Identity $Identity
    return $mbox.EmailAddresses
}

function Find-ExoAliasInAddresses {
    <#
    .SYNOPSIS
    Searches for an alias in a collection of email addresses.
    
    .DESCRIPTION
    Matches an address pattern against a collection of email addresses.
    
    .PARAMETER Addresses
    The collection of email addresses to search.
    
    .PARAMETER AddressPattern
    The address pattern to search for.
    
    .OUTPUTS
    Array of matching addresses or $null if no matches found.
    #>
    
    param(
        [Parameter(Mandatory = $true)]
        $Addresses,
        
        [Parameter(Mandatory = $true)]
        [string]$AddressPattern
    )
    
    return $Addresses -match $AddressPattern
}

function Test-EmailFormat {
    <#
    .SYNOPSIS
    Validates that a string is in proper email format.
    
    .DESCRIPTION
    Tests whether a string matches the pattern user@example.com.
    Returns $true if valid, $false otherwise.
    
    .PARAMETER EmailAddress
    The email address string to validate.
    
    .OUTPUTS
    Boolean indicating whether the email format is valid.
    #>
    
    param(
        [Parameter(Mandatory = $true)]
        [string]$EmailAddress
    )
    
    # Email regex pattern that matches user@example.com format
    $emailPattern = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    
    return $EmailAddress -match $emailPattern
}

#endregion

#region Public Functions

function Find-ExoAlias {
    <#
    .SYNOPSIS
    Searches for an email alias in an Exchange Online mailbox.
    
    .DESCRIPTION
    Connects to Exchange Online and searches for a specified email address or pattern
    within a mailbox's email addresses. If no search pattern is provided, returns all addresses.
    
    .PARAMETER AddressToBeSearched
    The email address or pattern to search for in the mailbox. If null or empty, returns all addresses.
    
    .PARAMETER MailboxToBeSearched
    The email address of the mailbox to search. Must be in user@example.com format. This parameter is mandatory.
    
    .EXAMPLE
    Find-ExoAlias -AddressToBeSearched "alias@domain.com" -MailboxToBeSearched "user@example.com"
    
    .EXAMPLE
    Find-ExoAlias "delete" "user@example.com"
    
    .EXAMPLE
    Find-ExoAlias "" "user@example.com"
    Returns all aliases for the mailbox.
    #>
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false, Position = 0)]
        [AllowEmptyString()]
        [string]$AddressToBeSearched = "",
        
        [Parameter(Mandatory = $true, Position = 1, HelpMessage = "Enter the mailbox email address to search (e.g., user@example.com)")]
        [string]$MailboxToBeSearched
    )
    
    # Validate mailbox email format
    if (-not (Test-EmailFormat -EmailAddress $MailboxToBeSearched)) {
        Write-Host "Error: '$MailboxToBeSearched' is not a valid email address format. Expected format: user@example.com" -ForegroundColor Red
        return
    }
    
    Connect-ExoInteractive
    
    $mboxAddresses = Get-ExoMailboxAddresses -Identity $MailboxToBeSearched
    
    # If AddressToBeSearched is empty, return all addresses; otherwise filter
    if ([string]::IsNullOrEmpty($AddressToBeSearched)) {
        $matchingAliases = $mboxAddresses
    } else {
        $matchingAliases = Find-ExoAliasInAddresses -Addresses $mboxAddresses -AddressPattern $AddressToBeSearched
    }
    
    if ($matchingAliases) {
        Write-Host "`nMatching aliases:" -ForegroundColor Cyan
        Write-Host ("-" * 50) -ForegroundColor Cyan
        
        # Sort aliases: SMTP: (primary) first, then all others alphabetically
        $sortedAliases = $matchingAliases | Sort-Object { 
            if ($_ -cmatch '^SMTP:') { 0 } 
            else { 1 } 
        }, { $_ }
        
        foreach ($alias in $sortedAliases) {
            if ($alias -cmatch '^SMTP:') {
                # Primary SMTP address
                $cleanAlias = $alias -replace '^SMTP:', ''
                Write-Host $cleanAlias -ForegroundColor Green -NoNewline
                Write-Host " (This alias is the mailbox default SMTP address)" -ForegroundColor Gray
            } elseif ($alias -cmatch '^smtp:') {
                # Secondary SMTP address
                $cleanAlias = $alias -replace '^smtp:', ''
                Write-Host $cleanAlias -ForegroundColor Yellow
            }
            # Skip all other address types (SIP:, X500:, etc.)
        }
        
        # Output custom objects to pipeline only if being piped
        # Check if output is being captured/piped by inspecting pipeline position
        if ($PSCmdlet.MyInvocation.PipelinePosition -lt $PSCmdlet.MyInvocation.PipelineLength) {
            # Being piped - return objects for pipeline processing
            foreach ($alias in $sortedAliases) {
                [PSCustomObject]@{
                    Alias   = $alias
                    Mailbox = $MailboxToBeSearched
                }
            }
        }
        # If not piped, do nothing - user already saw the formatted Write-Host output
    } else {
        Write-Host "`nNo matching aliases found." -ForegroundColor Red
    }
}

function Add-ExoAlias {
    <#
    .SYNOPSIS
    Adds an email alias to an Exchange Online mailbox.
    
    .DESCRIPTION
    Connects to Exchange Online and adds a new email alias to the specified mailbox.
    Verifies that the alias was successfully added.
    
    .PARAMETER AddressToBeAdded
    The email address to add as an alias. Must be in user@example.com format. This parameter is mandatory.
    
    .PARAMETER MailboxToAddAlias
    The email address of the mailbox to modify. Must be in user@example.com format. This parameter is mandatory.
    
    .EXAMPLE
    Add-ExoAlias -AddressToBeAdded "newalias@domain.com" -MailboxToAddAlias "user@example.com"
    
    .EXAMPLE
    Add-ExoAlias "newalias@domain.com" "user@example.com"
    #>
    
    param(
        [Parameter(Mandatory = $true, Position = 0, HelpMessage = "Enter the email alias to add (e.g., newalias@domain.com)")]
        [string]$AddressToBeAdded,
        
        [Parameter(Mandatory = $true, Position = 1, HelpMessage = "Enter the mailbox email address to modify (e.g., user@example.com)")]
        [string]$MailboxToAddAlias
    )
    
    # Validate mailbox email format
    if (-not (Test-EmailFormat -EmailAddress $MailboxToAddAlias)) {
        Write-Host "Error: '$MailboxToAddAlias' is not a valid email address format. Expected format: user@example.com" -ForegroundColor Red
        return
    }
    
    # Validate address email format
    if (-not (Test-EmailFormat -EmailAddress $AddressToBeAdded)) {
        Write-Host "Error: '$AddressToBeAdded' is not a valid email address format. Expected format: user@example.com" -ForegroundColor Red
        return
    }
    
    Connect-ExoInteractive
        
    Set-Mailbox -Identity $MailboxToAddAlias -EmailAddresses @{Add = "smtp:$AddressToBeAdded" }
    
    # Query Exchange Online to verify the alias was added
    $mboxAddresses = Get-ExoMailboxAddresses -Identity $MailboxToAddAlias
    $aliasFound = Find-ExoAliasInAddresses -Addresses $mboxAddresses -AddressPattern $AddressToBeAdded
    
    if ($aliasFound) {
        Write-Host "`nAlias successfully added and verified:" -ForegroundColor Green
        # Remove smtp: or SMTP: prefix before displaying
        $cleanAlias = $aliasFound -replace '^smtp:', '' -replace '^SMTP:', ''
        $cleanAlias | Write-Host -ForegroundColor Yellow
    } else {
        Write-Host "`nWarning: Alias was not found in the mailbox after adding." -ForegroundColor Red
    }
}

function Remove-ExoAlias {
    <#
    .SYNOPSIS
    Removes an email alias from an Exchange Online mailbox.
    
    .DESCRIPTION
    Connects to Exchange Online, verifies the alias exists, prompts for confirmation,
    and removes the specified email alias from the mailbox. Can accept pipeline input
    from Find-ExoAlias to remove multiple aliases.
    
    .PARAMETER AddressToBeRemoved
    The email address to remove from the mailbox. Can be in user@example.com format or
    smtp:user@example.com format (from pipeline). Accepts pipeline input.
    
    .PARAMETER MailboxToBeRemoved
    The email address of the mailbox to modify. Must be in user@example.com format.
    When piping from Find-ExoAlias, this parameter is automatically populated.
    
    .EXAMPLE
    Remove-ExoAlias -AddressToBeRemoved "oldalias@domain.com" -MailboxToBeRemoved "user@example.com"
    
    .EXAMPLE
    Remove-ExoAlias "oldalias@domain.com" "user@example.com"
    
    .EXAMPLE
    Find-ExoAlias "test" "user@example.com" | Remove-ExoAlias
    Removes all aliases matching "test" from the mailbox (mailbox is passed via pipeline).
    #>
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true, HelpMessage = "Enter the email alias to remove (e.g., oldalias@domain.com)")]
        [Alias('Alias')]
        [string]$AddressToBeRemoved,
        
        [Parameter(Mandatory = $true, Position = 1, ValueFromPipelineByPropertyName = $true, HelpMessage = "Enter the mailbox email address to modify (e.g., user@example.com)")]
        [Alias('Mailbox')]
        [string]$MailboxToBeRemoved
    )
    
    begin {
        Connect-ExoInteractive
        
        # Store current mailbox to detect changes in pipeline
        $currentMailbox = $null
        $currentMailboxAddresses = $null
    }
    
    process {
        # Use the provided mailbox
        $targetMailbox = $MailboxToBeRemoved
        
        # Validate mailbox email format
        if (-not (Test-EmailFormat -EmailAddress $targetMailbox)) {
            Write-Host "Error: '$targetMailbox' is not a valid email address format. Expected format: user@example.com" -ForegroundColor Red
            return
        }
        
        # Clean the address - remove smtp: or SMTP: prefix if present (from pipeline)
        $cleanAddress = $AddressToBeRemoved -replace '^smtp:', '' -replace '^SMTP:', ''
        
        # Validate address email format
        if (-not (Test-EmailFormat -EmailAddress $cleanAddress)) {
            Write-Host "Error: '$cleanAddress' is not a valid email address format. Expected format: user@example.com" -ForegroundColor Red
            return
        }
        
        # Get mailbox addresses (cache if same mailbox)
        if ($currentMailbox -ne $targetMailbox) {
            $currentMailbox = $targetMailbox
            $currentMailboxAddresses = Get-ExoMailboxAddresses -Identity $targetMailbox
        }
        
        # Query Exchange Online to check if the alias exists
        $aliasFound = Find-ExoAliasInAddresses -Addresses $currentMailboxAddresses -AddressPattern $cleanAddress
        
        if ($aliasFound) {
            Write-Host "`nAlias to be deleted:" -ForegroundColor Cyan
            # Remove smtp: or SMTP: prefix before displaying
            $displayAlias = $aliasFound -replace '^smtp:', '' -replace '^SMTP:', ''
            $displayAlias | Write-Host -ForegroundColor Yellow
            
            # Prompt user to confirm deletion with N as default
            $confirmation = Read-Host "`nDo you want to remove this alias? (Y/N) [N]"
            
            if ($confirmation -eq 'Y' -or $confirmation -eq 'y') {
                Set-Mailbox -Identity $targetMailbox -EmailAddresses @{Remove = "smtp:$cleanAddress" }
                Write-Host "`nAlias removed successfully." -ForegroundColor Green
            } else {
                
                Write-Host "`nAlias removal cancelled." -ForegroundColor Yellow
            }
        } else {
            Write-Host "`nAlias '$cleanAddress' not found in mailbox. No action taken." -ForegroundColor Red
        }
    }
}

#endregion

# Export only the public functions
Export-ModuleMember -Function Find-ExoAlias, Add-ExoAlias, Remove-ExoAlias
