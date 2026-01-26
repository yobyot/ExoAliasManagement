<#
.SYNOPSIS
    Automates version bumping and release tagging for ExoAliasManagement module.

.DESCRIPTION
    This script helps maintain consistent versioning by:
    - Requiring all changes to be committed before running
    - Reading current version from module manifest
    - Prompting for version bump type (major/minor/patch) or custom version
    - Updating the module manifest with new version
    - Prompting for release notes
    - Creating a Git commit
    - Creating a matching Git tag
    - Automatically pushing changes and tags to remote

.PARAMETER BumpType
    Type of version bump: Major, Minor, or Patch. If not specified, prompts interactively.

.PARAMETER CustomVersion
    Specify a custom version number instead of bumping. Format: x.y.z

.EXAMPLE
    .\Release.ps1
    # Interactive mode - prompts for all inputs

.EXAMPLE
    .\Release.ps1 -BumpType Patch
    # Bump patch version (1.0.0 -> 1.0.1)

.EXAMPLE
    .\Release.ps1 -BumpType Minor
    # Bump minor version (1.0.0 -> 1.1.0)

.EXAMPLE
    .\Release.ps1 -CustomVersion "2.0.0"
    # Set specific version
#>

[CmdletBinding()]
param(
    [Parameter()]
    [ValidateSet('Major', 'Minor', 'Patch')]
    [string]$BumpType,
    
    [Parameter()]
    [ValidatePattern('^\d+\.\d+\.\d+$')]
    [string]$CustomVersion
)

$ErrorActionPreference = 'Stop'

# Get script directory
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$manifestPath = Join-Path $scriptPath "ExoAliasManagement.psd1"

# Verify we're in a git repository
try {
    git rev-parse --git-dir 2>&1 | Out-Null
} catch {
    Write-Host "Error: Not in a Git repository. Please initialize Git first." -ForegroundColor Red
    exit 1
}

# Require clean working directory (all changes must be committed)
$gitStatus = git status --porcelain
if ($gitStatus) {
    Write-Host "Error: You have uncommitted changes. Please commit all changes before running Release.ps1" -ForegroundColor Red
    git status --short
    Write-Host "\nCommit your changes first:" -ForegroundColor Yellow
    Write-Host "  git add ." -ForegroundColor White
    Write-Host "  git commit -m 'Your commit message'" -ForegroundColor White
    exit 1
}

Write-Host "✓ Git working directory is clean" -ForegroundColor Green

# Read current version from manifest
Write-Host "`nReading current version from manifest..." -ForegroundColor Cyan
$manifest = Test-ModuleManifest -Path $manifestPath -ErrorAction Stop
$currentVersion = $manifest.Version
Write-Host "Current version: $currentVersion" -ForegroundColor Green

# Determine new version
if ($CustomVersion) {
    $newVersion = [Version]$CustomVersion
    Write-Host "Using custom version: $newVersion" -ForegroundColor Cyan
} elseif ($BumpType) {
    switch ($BumpType) {
        'Major' { $newVersion = [Version]::new($currentVersion.Major + 1, 0, 0) }
        'Minor' { $newVersion = [Version]::new($currentVersion.Major, $currentVersion.Minor + 1, 0) }
        'Patch' { $newVersion = [Version]::new($currentVersion.Major, $currentVersion.Minor, $currentVersion.Build + 1) }
    }
    Write-Host "Bumping $BumpType version: $currentVersion -> $newVersion" -ForegroundColor Cyan
} else {
    # Interactive mode
    Write-Host "`nSelect version bump type:" -ForegroundColor Cyan
    Write-Host "  1) Patch  ($currentVersion -> $($currentVersion.Major).$($currentVersion.Minor).$($currentVersion.Build + 1))" -ForegroundColor White
    Write-Host "  2) Minor  ($currentVersion -> $($currentVersion.Major).$($currentVersion.Minor + 1).0)" -ForegroundColor White
    Write-Host "  3) Major  ($currentVersion -> $($currentVersion.Major + 1).0.0)" -ForegroundColor White
    Write-Host "  4) Custom version" -ForegroundColor White
    Write-Host "  5) Republish current version ($currentVersion)" -ForegroundColor Yellow
    
    $choice = Read-Host "`nEnter choice (1-5)"
    
    switch ($choice) {
        '1' { $newVersion = [Version]::new($currentVersion.Major, $currentVersion.Minor, $currentVersion.Build + 1) }
        '2' { $newVersion = [Version]::new($currentVersion.Major, $currentVersion.Minor + 1, 0) }
        '3' { $newVersion = [Version]::new($currentVersion.Major + 1, 0, 0) }
        '4' { 
            $customInput = Read-Host "Enter custom version (x.y.z)"
            if ($customInput -match '^\d+\.\d+\.\d+$') {
                $newVersion = [Version]$customInput
            } else {
                Write-Host "Error: Invalid version format. Must be x.y.z" -ForegroundColor Red
                exit 1
            }
        }
        '5' { 
            $newVersion = $currentVersion
            Write-Host "WARNING: Republishing the same version number!" -ForegroundColor Yellow
        }
        default {
            Write-Host "Error: Invalid choice" -ForegroundColor Red
            exit 1
        }
    }
}

Write-Host "`nNew version will be: $newVersion" -ForegroundColor Green

# Prompt for release notes
Write-Host "`nEnter release notes (press Enter twice when done):" -ForegroundColor Cyan
$releaseNotes = @()
do {
    $line = Read-Host
    if ($line) { $releaseNotes += $line }
} while ($line)

if ($releaseNotes.Count -eq 0) {
    $releaseNotes = @("Version $newVersion release")
}

$releaseNotesText = $releaseNotes -join "`n"

# Read current manifest content
$manifestContent = Get-Content $manifestPath -Raw

# Update ModuleVersion
$manifestContent = $manifestContent -replace "(ModuleVersion\s*=\s*['""])\d+\.\d+\.\d+(['""])", "`${1}$newVersion`${2}"

# Get current date
$currentDate = Get-Date -Format "yyyy-MM-dd"

# Build new release notes section
$newReleaseNotesSection = @"
v$newVersion ($currentDate)
$releaseNotesText

"@

# Update ReleaseNotes - insert at the beginning of existing notes
if ($manifestContent -match "ReleaseNotes\s*=\s*@'[\r\n]+(.*?)[\r\n]+'@") {
    $existingNotes = $Matches[1]
    $updatedNotes = $newReleaseNotesSection + $existingNotes
    $manifestContent = $manifestContent -replace "(ReleaseNotes\s*=\s*@'[\r\n]+).*?([\r\n]+'@)", "`${1}$updatedNotes`${2}"
} else {
    Write-Host "Warning: Could not find ReleaseNotes section in manifest" -ForegroundColor Yellow
}

# Write updated manifest
Set-Content -Path $manifestPath -Value $manifestContent -NoNewline

Write-Host "`nManifest updated successfully!" -ForegroundColor Green
Write-Host "Note: Run .\SyncChangelogs.ps1 to sync CHANGELOG.md with manifest and README.md" -ForegroundColor Yellow

# Verify the manifest is valid
try {
    Test-ModuleManifest -Path $manifestPath -ErrorAction Stop | Out-Null
    Write-Host "Manifest validation: PASSED" -ForegroundColor Green
} catch {
    Write-Host "Error: Updated manifest is invalid!" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

# Git operations
$commitMessage = "Bump version to $newVersion"
$tagName = "v$newVersion"
$tagMessage = "Release v$newVersion`n`n$releaseNotesText"

Write-Host "`nCreating Git commit and tag..." -ForegroundColor Cyan

try {
    # Stage the manifest file
    git add $manifestPath
    
    # Create commit
    git commit -m $commitMessage
    Write-Host "Commit created: $commitMessage" -ForegroundColor Green
    
    # Create annotated tag
    git tag -a $tagName -m $tagMessage
    Write-Host "Tag created: $tagName" -ForegroundColor Green
    
    # Show what was done
    Write-Host "`n--- Commit ---" -ForegroundColor Cyan
    git log -1 --oneline
    
    Write-Host "`n--- Tag ---" -ForegroundColor Cyan
    git tag -l $tagName -n9
    
    # Automatically push to remote
    Write-Host "`nPushing changes and tag to remote..." -ForegroundColor Cyan
    $branch = git rev-parse --abbrev-ref HEAD
    git push origin $branch
    git push origin $tagName
    Write-Host "`nChanges and tag pushed to remote!" -ForegroundColor Green
    
    Write-Host "`n✓ Release $newVersion completed successfully!" -ForegroundColor Green
    
} catch {
    Write-Host "`nError during Git operations:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host "`nThe manifest has been updated but Git operations failed." -ForegroundColor Yellow
    Write-Host "You may need to commit and tag manually." -ForegroundColor Yellow
    exit 1
}
