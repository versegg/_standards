<#
.SYNOPSIS
    Create a new ADR with auto-incrementing number.

.DESCRIPTION
    Reads docs/adr/ of a product to find the next NNNN number, copies the ADR
    template, fills slug and title, and updates docs/adr/README.md index.

.PARAMETER Product
    Product slug.

.PARAMETER Slug
    Kebab-case slug for the ADR (e.g. 'use-postgres').

.PARAMETER Title
    Human-readable title for the ADR. If not given, derived from slug.

.PARAMETER TemplateDir
    Directory containing adr.md template. Default: _standards/templates.

.PARAMETER Root
    Products root. Default: C:\src\products.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string]$Product,
    [Parameter(Mandatory=$true)][string]$Slug,
    [string]$Title,
    [string]$TemplateDir = "C:\src\products\_standards\templates",
    [string]$Root = "C:\src\products"
)

$ErrorActionPreference = 'Stop'

$productDir = Join-Path $Root $Product
if (-not (Test-Path $productDir)) { Write-Error "Product not found"; exit 1 }

$utf8NoBom = [System.Text.UTF8Encoding]::new($false)

# Find highest existing ADR number
$adrDir = Join-Path $productDir "docs\adr"
if (-not (Test-Path $adrDir)) { New-Item -ItemType Directory -Force -Path $adrDir | Out-Null }

$maxN = 0
Get-ChildItem $adrDir -File -Filter "*.md" -ErrorAction SilentlyContinue | ForEach-Object {
    if ($_.BaseName -match '^(\d{4})') {
        $n = [int]$Matches[1]
        if ($n -gt $maxN) { $maxN = $n }
    }
}
$nextN = '{0:D4}' -f ($maxN + 1)
Write-Host "Next ADR number: $nextN"

# Slug
if ($Slug -notmatch '^[a-z0-9-]+$') {
    Write-Error "Slug must be kebab-case ASCII (a-z, 0-9, -)"
    exit 1
}

# Title
if (-not $Title) {
    $Title = (Get-Culture).TextInfo.ToTitleCase(($Slug -replace '-', ' '))
}

$adrFile = Join-Path $adrDir "$nextN-$Slug.md"

# Load template
$templatePath = Join-Path $TemplateDir "adr.md"
if (-not (Test-Path $templatePath)) {
    Write-Error "Template not found: $templatePath"
    exit 1
}

$tpl = [System.IO.File]::ReadAllText($templatePath, $utf8NoBom)
$today = (Get-Date).ToString('yyyy-MM-dd')

# Fill in: number, title, last_reviewed
$filled = $tpl -replace 'ADR-\<NNNN\>\. \<.*\>', "ADR-$nextN. $Title"
$filled = $filled -replace 'last_reviewed: YYYY-MM-DD', "last_reviewed: $today"

[System.IO.File]::WriteAllText($adrFile, $filled, $utf8NoBom)
Write-Host "Created: $adrFile"

# Update docs/adr/README.md index
$idxFile = Join-Path $adrDir "README.md"
if (Test-Path $idxFile) {
    $idx = [System.IO.File]::ReadAllText($idxFile, $utf8NoBom)
    $newRow = "| [$nextN]($nextN-$Slug.md) | $Title | draft | $today |"
    # Insert before the "## Как писать новый ADR" section if present
    if ($idx -match '(## Как писать новый ADR)') {
        $idx = $idx -replace '(## Как писать новый ADR)', "$newRow`n`n$1"
    } else {
        # Append at end
        $idx += "`n$newRow`n"
    }
    [System.IO.File]::WriteAllText($idxFile, $idx, $utf8NoBom)
    Write-Host "Updated index: $idxFile"
} else {
    # Create new index
    $indexTpl = @"
---
type: adr
title: ADR index -- $Product
status: approved
owner: $Product-team
last_reviewed: $today
audience: developer, architect
tags: [adr]
related: []
---

# ADR index -- $Product

Architectural Decision Records for $Product.

| Номер | Название | Статус | Дата |
|---|---|---|---|
| [$nextN]($nextN-$Slug.md) | $Title | draft | $today |

## Как писать новый ADR

```powershell
.\\_standards\\tools\\new-adr.ps1 -Product $Product -Slug my-decision
```
"@
    [System.IO.File]::WriteAllText($idxFile, $indexTpl, $utf8NoBom)
    Write-Host "Created index: $idxFile"
}

Write-Host ""
Write-Host "Now edit the ADR to fill in Context, Decision, Alternatives."
