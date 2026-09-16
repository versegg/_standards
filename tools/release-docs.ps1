<#
.SYNOPSIS
    Snapshot documentation at a release point.

.DESCRIPTION
    Creates docs/releases/<version>/INDEX.md as a snapshot of docs/INDEX.md at
    release time, updates docs/releases/README.md and product CHANGELOG.md,
    and creates a git tag.

.PARAMETER Product
    Product slug.

.PARAMETER Version
    Semantic version, e.g. '1.2.0'. Must match pattern X.Y.Z.

.PARAMETER Date
    Release date (YYYY-MM-DD). Default: today.

.PARAMETER Root
    Products root. Default: C:\src\products.

.PARAMETER NoTag
    If set, skip creating git tag.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string]$Product,
    [Parameter(Mandatory=$true)][string]$Version,
    [string]$Date,
    [string]$Root = "C:\src\products",
    [switch]$NoTag
)

$ErrorActionPreference = 'Stop'

if ($Version -notmatch '^\d+\.\d+\.\d+(-[a-z0-9.]+)?$') {
    Write-Error "Version must be X.Y.Z or X.Y.Z-suffix"
    exit 1
}

$productDir = Join-Path $Root $Product
if (-not (Test-Path $productDir)) { Write-Error "Product not found"; exit 1 }

if (-not $Date) { $Date = (Get-Date).ToString('yyyy-MM-dd') }

$utf8NoBom = [System.Text.UTF8Encoding]::new($false)

$releasesDir = Join-Path $productDir "docs\releases"
$versionDir = Join-Path $releasesDir $Version

# Create version dir
if (-not (Test-Path $versionDir)) {
    New-Item -ItemType Directory -Force -Path $versionDir | Out-Null
}

# Snapshot docs/INDEX.md -> docs/releases/<version>/INDEX.md
$srcIdx = Join-Path $productDir "docs\INDEX.md"
$dstIdx = Join-Path $versionDir "INDEX.md"
if (Test-Path $srcIdx) {
    [System.IO.File]::Copy($srcIdx, $dstIdx, $true)
    Write-Host "Snapshotted: docs/INDEX.md -> docs/releases/$Version/INDEX.md"
} else {
    Write-Warning "No docs/INDEX.md to snapshot"
}

# Update docs/releases/README.md
$relIdx = Join-Path $releasesDir "README.md"
if (Test-Path $relIdx) {
    $idx = [System.IO.File]::ReadAllText($relIdx, $utf8NoBom)
    # Find the table header and add new row
    $newRow = "| [v$Version]($Version/INDEX.md) | $Date | (fill) |"
    if ($idx -match '(\|.*Highlights.*\|)') {
        $idx = $idx -replace '(?=\| \[v)', "$newRow`n"
        if (-not ($idx -match [regex]::Escape($newRow))) {
            # Just append after header row
            $idx = $idx -replace '(?=\n\n|\n$)', "`n$newRow"
        }
    } else {
        $idx += "`n`n$newRow`n"
    }
    [System.IO.File]::WriteAllText($relIdx, $idx, $utf8NoBom)
    Write-Host "Updated: docs/releases/README.md"
} else {
    Write-Warning "No docs/releases/README.md to update"
}

# Create or update CHANGELOG.md at root
$changelog = Join-Path $productDir "CHANGELOG.md"
$newChangelogRow = "## [$Version] - $Date"

if (Test-Path $changelog) {
    $cl = [System.IO.File]::ReadAllText($changelog, $utf8NoBom)
    if ($cl -notmatch [regex]::Escape($newChangelogRow)) {
        $cl = $cl -replace '(?=\n## \[)', "$newChangelogRow`n`n- See [docs/releases/$Version/](docs/releases/$Version/)`n"
        [System.IO.File]::WriteAllText($changelog, $cl, $utf8NoBom)
    }
    Write-Host "Updated: CHANGELOG.md"
} else {
    $cl = @"
# Changelog

All notable changes to $Product are documented here. Format follows [Keep a Changelog](https://keepachangelog.com).

$newChangelogRow

- See [docs/releases/$Version/](docs/releases/$Version/) for the documentation snapshot.
- Highlights: (fill in)

"@
    [System.IO.File]::WriteAllText($changelog, $cl, $utf8NoBom)
    Write-Host "Created: CHANGELOG.md"
}

# Create git tag
if (-not $NoTag) {
    Set-Location $productDir
    git add docs/ CHANGELOG.md 2>&1 | Out-Null
    git commit -m "release: v$Version -- snapshot documentation" 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        git tag "v$Version" 2>&1
        Write-Host "Created git tag: v$Version"
    } else {
        Write-Warning "Could not commit/tag (may be nothing to commit)"
    }
}

Write-Host ""
Write-Host "Release docs ready for $Product v$Version"
