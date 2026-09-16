<#
.SYNOPSIS
    Recover damaged files from git history and safely add frontmatter.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string]$Product,
    [string]$Root = "C:\src\products",
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'

$productDir = Join-Path $Root $Product
Set-Location $productDir

$today = (Get-Date).ToString('yyyy-MM-dd')

# Find my migration commit (the one that destroyed content)
# It's the latest "docs: migrate to unified documentation standard" commit
$myCommit = git log --oneline | Select-String "docs: migrate to unified documentation standard" | Select-Object -First 1
if (-not $myCommit) {
    Write-Host "No migration commit found"
    return
}
$myHash = ($myCommit -split " ")[0]
Write-Host "Migration commit: $myHash"
$parentHash = git rev-parse "$myHash^"
Write-Host "Parent commit: $parentHash"

# Find all damaged files
$scanRoots = @('docs','marketing','mockups','media') | ForEach-Object { Join-Path $productDir $_ } | Where-Object { Test-Path $_ }

$damaged = @()
foreach ($scanRoot in $scanRoots) {
    $files = Get-ChildItem -Path $scanRoot -Recurse -File -Filter '*.md' -ErrorAction SilentlyContinue
    foreach ($d in $files) {
        if ($d.Length -gt 0 -and $d.Length -lt 500) {
            $c = Get-Content $d.FullName -Raw -Encoding UTF8
            if ([regex]::IsMatch($c, '(?s)^---\r?\n.*?---\r?\n?$')) {
                $damaged += $d
            }
        }
    }
}

Write-Host "Damaged files found: $($damaged.Count)"

foreach ($d in $damaged) {
    $rel = $d.FullName.Substring($productDir.Length).Replace('\','/').TrimStart('/')
    Write-Host ""
    Write-Host "Recovering: $rel"

    # Get the file content from parent commit
    $original = git show "$parentHash`:$rel" 2>$null
    if (-not $original) {
        Write-Host "  [SKIP] Could not get original from $parentHash"
        continue
    }
    $originalLen = ($original | Measure-Object -Line).Lines
    Write-Host "  Original lines: $originalLen"

    if ($DryRun) {
        Write-Host "  [DRY] Would restore + add frontmatter"
        continue
    }

    # Determine type from path
    $type = 'tech'  # default
    if ($rel -match 'manual') { $type = 'manual' }
    elseif ($rel -match 'help') { $type = 'help' }
    elseif ($rel -match 'adr') { $type = 'adr' }

    $name = [System.IO.Path]::GetFileNameWithoutExtension($d.Name)
    $name = $name -replace '^\d{2}[-_]?', ''
    $title = ($name -replace '[-_]', ' ').Trim()
    if ($title -match '^[a-zA-Z\s\.\-/]+$') {
        $title = (Get-Culture).TextInfo.ToTitleCase($title.ToLower())
    }

    # Build frontmatter
    $fm = @(
        '---',
        "type: $type",
        "title: $title",
        'status: draft',
        "owner: $Product-team",
        'locale: ru',
        "last_reviewed: $today",
        'tags: []',
        'related: []',
        '---',
        ''
    ) -join "`n"

    # Write using .NET File to avoid PowerShell encoding quirks
    $fullPath = $d.FullName
    $content = $fm + ($original -join "`n")

    $utf8NoBom = [System.Text.UTF8Encoding]::new($false)
    [System.IO.File]::WriteAllText($fullPath, $content, $utf8NoBom)

    $newLen = (Get-Item $fullPath).Length
    Write-Host "  [RECOVERED] $newLen bytes"
}

Write-Host ""
Write-Host "Done."
