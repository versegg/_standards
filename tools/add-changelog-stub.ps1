<#
.SYNOPSIS
    Create a root CHANGELOG.md for a product (Keep a Changelog format).
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string]$Product,
    [string]$Root = "C:\src\products"
)

$ErrorActionPreference = 'Stop'

$productDir = Join-Path $Root $Product
if (-not (Test-Path $productDir)) { Write-Error "Product not found"; exit 1 }

$utf8NoBom = [System.Text.UTF8Encoding]::new($false)
$today = (Get-Date).ToString('yyyy-MM-dd')

$cl = Join-Path $productDir "CHANGELOG.md"
if (Test-Path $cl) {
    Write-Host "Already exists: $cl"
    exit 0
}

$content = @"
# Changelog

All notable changes to $Product are documented here. Format follows [Keep a Changelog](https://keepachangelog.com).

The **documentation snapshot** for each release lives under [docs/releases/](docs/releases/). Use [\`_standards/tools/release-docs.ps1\`](https://github.com/versegg/_standards/blob/main/tools/release-docs.ps1) when cutting a release.

## [Unreleased]

### Added
- (in development)

### Changed
- (in development)

### Fixed
- (in development)
"@

[System.IO.File]::WriteAllText($cl, $content, $utf8NoBom)
Write-Host "Created: $cl"
