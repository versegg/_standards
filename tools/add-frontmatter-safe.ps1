<#
.SYNOPSIS
    Add YAML frontmatter to .md files SAFELY using .NET APIs (no encoding corruption).
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string]$Product,
    [string]$Root = "C:\src\products",
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'

$productDir = Join-Path $Root $Product
if (-not (Test-Path $productDir -PathType Container)) {
    Write-Error "Product '$Product' not found"
    exit 1
}

$today = (Get-Date).ToString('yyyy-MM-dd')

$scanRoots = @('docs','marketing','mockups','media') | ForEach-Object { Join-Path $productDir $_ } | Where-Object { Test-Path $_ }

# .NET UTF-8 no BOM
$utf8NoBom = [System.Text.UTF8Encoding]::new($false)

function Read-AllText {
    param([string]$Path)
    return [System.IO.File]::ReadAllText($Path, $utf8NoBom)
}

function Write-AllText {
    param([string]$Path, [string]$Content)
    [System.IO.File]::WriteAllText($Path, $Content, $utf8NoBom)
}

function Has-Frontmatter {
    param([string]$Content)
    return $Content -match '(?s)^---\r?\n.*?\r?\n---'
}

function Get-InferredType {
    param([string]$RelPath)
    $p = $RelPath.ToLower().Replace('\','/')
    if ($p -match '/adr/') { return 'adr' }
    if ($p -match '/api/') { return 'api' }
    if ($p -match '/arch/') { return 'arch' }
    if ($p -match '/runbook/') { return 'runbook' }
    if ($p -match '/releases?/') { return 'release' }
    if ($p -match '/roadmap/') { return 'roadmap' }
    if ($p -match '/design/') { return 'design' }
    if ($p -match '/help/') { return 'help' }
    if ($p -match '/manual/') { return 'manual' }
    if ($p -match '/showcase/') { return 'showcase' }
    if ($p -match '/hero/') { return 'hero' }
    if ($p -match '/campaigns/') { return 'campaign' }
    if ($p -match '/brand/') { return 'brand' }
    if ($p -match '/mockups/') { return 'mockup' }
    if ($p -match '/(tech|technical)/') { return 'tech' }
    if ($p -match '/features?/') { return 'tech' }
    if ($p -match '/scenarios/') { return 'tech' }
    if ($p -match '/user-guide/') { return 'manual' }
    return 'tech'
}

function Get-InferredLocale {
    param([string]$RelPath)
    $p = $RelPath.ToLower().Replace('\','/')
    if ($p -match '/ru/') { return 'ru' }
    if ($p -match '/en/') { return 'en' }
    if ($p -match '-public') { return 'ru' }
    return 'ru'
}

function Get-FileTitle {
    param([string]$Name)
    $n = [System.IO.Path]::GetFileNameWithoutExtension($Name)
    $n = $n -replace '^\d{2,}[-_]?', ''
    $n = $n -replace '^\d{1}[-_]?', ''
    $t = ($n -replace '[-_]', ' ').Trim()
    if ($t -match '^[a-zA-Z\s\.\-/]+$') {
        $t = (Get-Culture).TextInfo.ToTitleCase($t.ToLower())
    }
    return $t
}

function Build-Frontmatter {
    param([string]$Type, [string]$Locale, [string]$Title, [string]$Owner, [string]$Today)
    @"
---
type: $Type
title: $Title
status: draft
owner: $Owner
locale: $Locale
last_reviewed: $Today
tags: []
related: []
---

"@
}

$processed = 0
$skipped = 0
$added = 0

foreach ($scanRoot in $scanRoots) {
    $files = Get-ChildItem -Path $scanRoot -Recurse -File -Filter '*.md' -ErrorAction SilentlyContinue

    foreach ($file in $files) {
        $rel = $file.FullName.Substring($productDir.Length)
        $depth = ($rel.TrimStart('\','/').Split('\').Count)
        if ($file.Name -eq 'INDEX.md') { continue }
        if ($file.Name -eq 'README.md' -and $depth -le 1) { continue }

        $processed++

        $existing = Read-AllText -Path $file.FullName
        if (Has-Frontmatter -Content $existing) {
            $skipped++
            continue
        }

        $type = Get-InferredType -RelPath $rel
        $locale = Get-InferredLocale -RelPath $rel
        $title = Get-FileTitle -Name $file.Name
        $owner = "$Product-team"
        $fm = Build-Frontmatter -Type $type -Locale $locale -Title $title -Owner $owner -Today $today

        if ($DryRun) {
            Write-Host "  [would-add] $rel -- type=$type locale=$locale"
        } else {
            $newContent = $fm + $existing
            Write-AllText -Path $file.FullName -Content $newContent
            $added++
        }
    }
}

Write-Host "Product: $Product  Processed: $processed  Added: $added  Skipped(existing): $skipped"
