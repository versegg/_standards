<#
.SYNOPSIS
    Validate product documentation against the unified standard.

.DESCRIPTION
    Checks:
    - YAML frontmatter present in all .md under docs/, marketing/, mockups/;
    - required fields per type;
    - valid status, locale, audience values;
    - all related paths exist;
    - last_reviewed not older than 6 months (warning).

.PARAMETER Product
    Product slug (e.g. shop, academy, cafe). Folder must exist under C:\src\products\.

.PARAMETER Root
    Root dir containing products. Default: C:\src\products.

.EXAMPLE
    .\validate.ps1 -Product shop
    .\validate.ps1 -Product cafe -Root "D:\products"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$Product,
    [string]$Root = "C:\src\products"
)

$ErrorActionPreference = 'Stop'

$productDir = Join-Path $Root $Product
if (-not (Test-Path -Path $productDir -PathType Container)) {
    Write-Error "Product '$Product' not found in $Root"
    exit 1
}

$scanRoots = @(
    (Join-Path $productDir "docs"),
    (Join-Path $productDir "marketing"),
    (Join-Path $productDir "mockups"),
    (Join-Path $productDir "media")
) | Where-Object { Test-Path -Path $_ -PathType Container }

$excludePattern = 'node_modules|\.git|bin|obj|dist|build|__pycache__|\.next|\.venv|\.codegraph|\.claude|\.omo|\.forgejo|\.ai|\.opencode|\.research'

$required = @{
    'manual'     = @('type','title','status','owner','locale','last_reviewed')
    'help'       = @('type','title','status','owner','locale','last_reviewed')
    'tech'       = @('type','title','status','owner','last_reviewed')
    'arch'       = @('type','title','status','owner','last_reviewed')
    'adr'        = @('type','title','status','owner','last_reviewed')
    'api'        = @('type','title','status','owner','last_reviewed')
    'runbook'    = @('type','title','status','owner','last_reviewed')
    'release'    = @('type','title','status','owner','last_reviewed')
    'roadmap'    = @('type','title','status','owner','last_reviewed')
    'design'     = @('type','title','status','owner','last_reviewed')
    'positioning'= @('type','title','status','owner','last_reviewed')
    'pitch'      = @('type','title','status','owner','last_reviewed')
    'showcase'   = @('type','title','status','owner','last_reviewed')
    'hero'       = @('type','title','status','owner','last_reviewed')
    'campaign'   = @('type','title','status','owner','last_reviewed')
    'brand'      = @('type','title','status','owner','last_reviewed')
    'mockup'     = @('type','title','status','owner','last_reviewed')
    'standard'   = @('type','title','status','owner','last_reviewed')
    'readme'     = @('type','title','status','owner','last_reviewed')
}

$validStatuses = @('draft','review','approved','deprecated',
                   'proposed','accepted','rejected','superseded')
$validLocales  = @('ru','en','kk','by')
$validAudiences= @('customer','admin','manager','developer','architect',
                    'designer','ops','sales','marketing','founder',
                    'partner','support','all')

$errors = @()
$warnings = @()
$checked = 0

function Get-Frontmatter {
    param([string]$Path)
    $content = Get-Content -Path $Path -Raw -Encoding UTF8
    if ($content -match '(?s)^---\r?\n(.*?)\r?\n---') {
        return $Matches[1]
    }
    return $null
}

function Parse-Frontmatter {
    param([string]$Yaml)
    $result = [ordered]@{}
    if (-not $Yaml) { return $result }
    foreach ($line in $Yaml -split "`r?`n") {
        if ($line -match '^\s*#') { continue }
        if ($line -match '^\s*$') { continue }
        if ($line -match '^(\w+):\s*(.*)$') {
            $key = $Matches[1]
            $value = $Matches[2].Trim()
            if ($value -match '^["''](.*)["'']$') { $value = $Matches[1] }
            if ($value -match '^\[(.*)\]$') {
                $inner = $Matches[1]
                $list = @()
                if ($inner.Trim() -ne '') {
                    foreach ($item in $inner -split ',') {
                        $list += $item.Trim().Trim('"').Trim("'")
                    }
                }
                $result[$key] = $list
            } else {
                $result[$key] = $value
            }
        }
    }
    return $result
}

function Test-RelatedPath {
    param(
        [string]$Path,
        [string]$RelatedPath,
        [string]$FileDir
    )
    if ($RelatedPath -match '^https?://') { return $true }
    $resolved = if ([System.IO.Path]::IsPathRooted($RelatedPath)) {
        $RelatedPath
    } else {
        Join-Path $FileDir $RelatedPath
    }
    $resolved = [System.IO.Path]::GetFullPath($resolved)
    return (Test-Path -Path $resolved)
}

foreach ($scanRoot in $scanRoots) {
    $files = Get-ChildItem -Path $scanRoot -Recurse -File -Filter "*.md" -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -notmatch $excludePattern }

    foreach ($file in $files) {
        if ($file.Name -eq 'INDEX.md') { continue }  # generated, not authored
        $checked++
        $rel = $file.FullName.Substring($productDir.Length)

        $yaml = Get-Frontmatter -Path $file.FullName
        if (-not $yaml) {
            $errors += "$rel -- NO FRONTMATTER"
            continue
        }

        $fm = Parse-Frontmatter -Yaml $yaml
        $type = $fm['type']

        if (-not $type) {
            $errors += "$rel -- missing field 'type'"
            continue
        }

        if ($required.ContainsKey($type)) {
            foreach ($req in $required[$type]) {
                if (-not $fm.Contains($req) -or [string]::IsNullOrWhiteSpace($fm[$req])) {
                    $errors += "$rel -- missing required field '$req'"
                }
            }
        } else {
            $warnings += "$rel -- unknown type '$type' (check DOC-TYPES.md)"
        }

        if ($fm['status'] -and $validStatuses -notcontains $fm['status']) {
            $errors += "$rel -- invalid status '$($fm['status'])'. Allowed: $($validStatuses -join ', ')"
        }

        if (($type -eq 'manual' -or $type -eq 'help') -and $fm['locale']) {
            if ($validLocales -notcontains $fm['locale']) {
                $warnings += "$rel -- non-standard locale '$($fm['locale'])'. Standard: $($validLocales -join ', ')"
            }
        }

        if ($fm['last_reviewed'] -and $fm['status'] -eq 'approved') {
            try {
                $reviewed = [datetime]::ParseExact($fm['last_reviewed'], 'yyyy-MM-dd', $null)
                $age = (Get-Date) - $reviewed
                if ($age.Days -gt 180) {
                    $warnings += "$rel -- last_reviewed older than 6 months ($($fm['last_reviewed'])). Refresh."
                }
            } catch {
                $warnings += "$rel -- bad last_reviewed format '$($fm['last_reviewed'])'. Expected YYYY-MM-DD"
            }
        }

        if ($fm.Contains('related') -and $fm['related']) {
            $fileDir = Split-Path -Path $file.FullName -Parent
            foreach ($relPath in $fm['related']) {
                if (-not (Test-RelatedPath -Path $file.FullName -RelatedPath $relPath -FileDir $fileDir)) {
                    $errors += "$rel -- related path does not exist: $relPath"
                }
            }
        }
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Validation: $Product" -ForegroundColor Cyan
Write-Host "Files checked: $checked" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if ($errors.Count -eq 0 -and $warnings.Count -eq 0) {
    Write-Host "OK -- product is on the rails." -ForegroundColor Green
    exit 0
}

if ($errors.Count -gt 0) {
    Write-Host "ERRORS ($($errors.Count)):" -ForegroundColor Red
    foreach ($e in $errors) {
        Write-Host "  - $e" -ForegroundColor Red
    }
    Write-Host ""
}

if ($warnings.Count -gt 0) {
    Write-Host "WARNINGS ($($warnings.Count)):" -ForegroundColor Yellow
    foreach ($w in $warnings) {
        Write-Host "  - $w" -ForegroundColor Yellow
    }
    Write-Host ""
}

if ($errors.Count -gt 0) { exit 1 }
exit 0
