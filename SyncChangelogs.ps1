<#
.SYNOPSIS
    Synchronizes CHANGELOG.md content to module manifest and README.md.

.DESCRIPTION
    This script reads CHANGELOG.md (the source of truth) and synchronizes
    the version history to:
    - ExoAliasManagement.psd1 (ReleaseNotes section)
    - README.md (Version History section)
    
    CHANGELOG.md uses the "Keep a Changelog" format with categorized entries.
    The script converts these to simple bullet lists for the manifest and README.

.EXAMPLE
    .\SyncChangelogs.ps1
    # Synchronizes all changelogs

.NOTES
    CHANGELOG.md is the single source of truth for all version history.
    Always update CHANGELOG.md first, then run this script to sync.
#>

[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

# Get script directory
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$changelogPath = Join-Path $scriptPath "CHANGELOG.md"
$manifestPath = Join-Path $scriptPath "ExoAliasManagement.psd1"
$readmePath = Join-Path $scriptPath "README.md"

# Verify CHANGELOG.md exists
if (-not (Test-Path $changelogPath)) {
    Write-Host "Error: CHANGELOG.md not found at $changelogPath" -ForegroundColor Red
    exit 1
}

Write-Host "Reading CHANGELOG.md..." -ForegroundColor Cyan
$changelogContent = Get-Content $changelogPath -Raw

# Parse changelog entries using regex
# Match pattern: ## [version] - date followed by categorized sections
$versionPattern = '(?s)## \[(\d+\.\d+\.\d+)\] - (\d{4}-\d{2}-\d{2})(.*?)(?=## \[|$)'
$versionMatches = [regex]::Matches($changelogContent, $versionPattern)

if ($versionMatches.Count -eq 0) {
    Write-Host "Error: No version entries found in CHANGELOG.md" -ForegroundColor Red
    exit 1
}

Write-Host "Found $($versionMatches.Count) version entries" -ForegroundColor Green

# Build release notes for manifest and README
$manifestReleaseNotes = @()
$readmeVersionHistory = @()

foreach ($match in $versionMatches) {
    $version = $match.Groups[1].Value
    $date = $match.Groups[2].Value
    $content = $match.Groups[3].Value
    
    # Extract all bullet points from all sections (### Added, ### Changed, etc.)
    $bulletPattern = '(?m)^- (.+)$'
    $bullets = [regex]::Matches($content, $bulletPattern)
    
    if ($bullets.Count -eq 0) {
        Write-Host "Warning: No bullet points found for version $version" -ForegroundColor Yellow
        continue
    }
    
    # Build entry for manifest (compact format)
    $manifestEntry = "v$version ($date)"
    foreach ($bullet in $bullets) {
        $manifestEntry += "`n- $($bullet.Groups[1].Value)"
    }
    $manifestReleaseNotes += $manifestEntry
    
    # Build entry for README (same format with markdown header)
    $readmeEntry = "### v$version ($date)"
    foreach ($bullet in $bullets) {
        $readmeEntry += "`n- $($bullet.Groups[1].Value)"
    }
    $readmeVersionHistory += $readmeEntry
}

# Join all entries
$manifestNotesText = $manifestReleaseNotes -join "`n`n"
$readmeHistoryText = $readmeVersionHistory -join "`n`n"

# Update manifest file
Write-Host "`nUpdating ExoAliasManagement.psd1..." -ForegroundColor Cyan
if (Test-Path $manifestPath) {
    $manifestContent = Get-Content $manifestPath -Raw
    
    # Replace ReleaseNotes section
    if ($manifestContent -match "(?s)(ReleaseNotes\s*=\s*@').*?('@)") {
        $manifestContent = $manifestContent -replace "(?s)(ReleaseNotes\s*=\s*@').*?('@)", "`${1}`n$manifestNotesText`n`${2}"
        Set-Content -Path $manifestPath -Value $manifestContent -NoNewline
        Write-Host "  ✓ Manifest ReleaseNotes updated" -ForegroundColor Green
        
        # Validate manifest
        try {
            Test-ModuleManifest -Path $manifestPath -ErrorAction Stop | Out-Null
            Write-Host "  ✓ Manifest validation passed" -ForegroundColor Green
        } catch {
            Write-Host "  ✗ Manifest validation failed!" -ForegroundColor Red
            Write-Host "    $($_.Exception.Message)" -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "  ✗ Could not find ReleaseNotes section" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "  ✗ Manifest file not found" -ForegroundColor Red
    exit 1
}

# Update README.md file
Write-Host "`nUpdating README.md..." -ForegroundColor Cyan
if (Test-Path $readmePath) {
    $readmeContent = Get-Content $readmePath -Raw
    
    # Replace Version History section content
    # Pattern: ## Version History followed by content until next ## heading or end of file
    if ($readmeContent -match '(?s)(## Version History).*?(?=\n## [A-Z]|\Z)') {
        $replacement = "`$1`n`n$readmeHistoryText`n`n"
        $readmeContent = $readmeContent -replace '(?s)(## Version History).*?(?=\n## [A-Z]|\Z)', $replacement
        Set-Content -Path $readmePath -Value $readmeContent -NoNewline
        Write-Host "  ✓ README.md Version History updated" -ForegroundColor Green
    } else {
        Write-Host "  ✗ Could not find Version History section" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "  ✗ README.md file not found" -ForegroundColor Red
    exit 1
}

Write-Host "`n✓ Synchronization complete!" -ForegroundColor Green
Write-Host "  CHANGELOG.md → ExoAliasManagement.psd1 (ReleaseNotes)" -ForegroundColor White
Write-Host "  CHANGELOG.md → README.md (Version History)" -ForegroundColor White
