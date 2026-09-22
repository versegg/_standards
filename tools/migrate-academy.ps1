<#
.SYNOPSIS
    Migrate academy product to canonical documentation structure.
#>

[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$root = "C:\src\products\academy"
Set-Location $root

function Move-Doc {
    param([string]$From, [string]$To)
    $fromPath = Join-Path $root $From
    $toPath = Join-Path $root $To
    if (-not (Test-Path $fromPath)) {
        Write-Host "  [skip, not found] $From"
        return
    }
    if ($fromPath -eq $toPath) { return }
    $toParent = Split-Path -Path $toPath -Parent
    if (-not (Test-Path $toParent)) {
        New-Item -ItemType Directory -Force -Path $toParent | Out-Null
    }
    if (Test-Path $toPath) { Remove-Item -Path $toPath -Force }
    git mv $From $To 2>&1 | Out-Null
    Write-Host "  [moved] $From -> $To"
}

Write-Host "=== academy: top-level docs/" -ForegroundColor Cyan
Move-Doc 'docs/deployment.md'    'docs/runbook/deployment.md'
Move-Doc 'docs/features.md'      'docs/tech/features.md'
Move-Doc 'docs/handover.md'      'docs/runbook/handover.md'
Move-Doc 'docs/hero-video.md'    'marketing/hero/README.md'
Move-Doc 'docs/site-modes.md'    'docs/tech/site-modes.md'

Write-Host ""
Write-Host "=== academy: marketing/ + mockups/ + media/" -ForegroundColor Cyan
Move-Doc 'marketing/instructions.md' 'marketing/positioning.md'

# Move media/hero/* into marketing/hero/
$mediaHeroFiles = Get-ChildItem "$root\media\hero" -File -Filter "*.md" -ErrorAction SilentlyContinue
foreach ($f in $mediaHeroFiles) {
    $target = Join-Path $root "marketing\hero\$($f.Name)"
    if (Test-Path $target) { Remove-Item -Path $target -Force }
    git mv "media/hero/$($f.Name)" "marketing/hero/$($f.Name)" 2>&1 | Out-Null
    Write-Host "  [moved] media/hero/$($f.Name) -> marketing/hero/$($f.Name)"
}

Write-Host ""
Write-Host "Done. Ready for split-md on big files."
