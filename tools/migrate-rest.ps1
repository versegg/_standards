<#
.SYNOPSIS
    Migrate realty, cafe, hotel, gym, veterinary to canonical structure.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][ValidateSet('realty','cafe','hotel','gym','veterinary')][string]$Product
)

$ErrorActionPreference = 'Stop'

$root = "C:\src\products\$Product"
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

switch ($Product) {
    'realty' {
        Write-Host "=== realty ===" -ForegroundColor Cyan
        Move-Doc 'docs/00-vision-and-roadmap.md' 'docs/roadmap/vision.md'
        Move-Doc 'docs/01-architecture.md'       'docs/arch/overview.md'
        Move-Doc 'docs/02-api-contract.md'       'docs/api/contract.md'
        Move-Doc 'docs/03-data-model.md'         'docs/tech/data-model.md'
        Move-Doc 'docs/04-compliance-ru.md'      'docs/arch/compliance.md'
        Move-Doc 'docs/05-design-system.md'      'docs/design/design-system.md'
        Move-Doc 'docs/05b-theme-system.md'      'docs/design/themes.md'
        Move-Doc 'docs/06-roles-rbac.md'         'docs/tech/rbac.md'
        Move-Doc 'docs/roadmap.md'               'docs/roadmap/current.md'
    }
    'cafe' {
        Write-Host "=== cafe ===" -ForegroundColor Cyan
        Move-Doc 'docs/concerns.md'             'docs/arch/concerns.md'
        Move-Doc 'docs/domain-model.md'         'docs/tech/data-model.md'
        Move-Doc 'docs/end-users.md'            'marketing/personas.md'
        Move-Doc 'docs/market.md'               'marketing/positioning.md'
        Move-Doc 'docs/project-structure.md'    'docs/tech/project-structure.md'
        Move-Doc 'docs/reference-projects.md'   'marketing/competitive.md'
        Move-Doc 'docs/reuse-notes.md'          'docs/tech/reuse-notes.md'
        Move-Doc 'docs/roadmap.md'              'docs/roadmap/main.md'
        Move-Doc 'docs/site-structure.md'       'docs/arch/site-structure.md'
        # Marketing showcase
        if (-not (Test-Path 'marketing\showcase\README.md')) {
            New-Item -ItemType Directory -Force -Path 'marketing\showcase' | Out-Null
        }
        if (Test-Path 'marketing\showcase-draft.md') {
            Move-Doc 'marketing/showcase-draft.md' 'marketing/showcase/draft.md'
        }
    }
    'hotel' {
        Write-Host "=== hotel ===" -ForegroundColor Cyan
        Move-Doc 'docs/backlog.md'              'docs/roadmap/backlog.md'
        Move-Doc 'docs/concerns.md'             'docs/arch/concerns.md'
        Move-Doc 'docs/domain-model.md'         'docs/tech/data-model.md'
        Move-Doc 'docs/end-users.md'            'marketing/personas.md'
        Move-Doc 'docs/features.md'             'docs/tech/features.md'
        Move-Doc 'docs/HANDOVER.md'             'docs/runbook/handover.md'
        Move-Doc 'docs/market.md'               'marketing/positioning.md'
        Move-Doc 'docs/opportunities.md'        'docs/roadmap/opportunities.md'
        Move-Doc 'docs/project-structure.md'    'docs/tech/project-structure.md'
        Move-Doc 'docs/reference-projects.md'   'marketing/competitive.md'
        Move-Doc 'docs/requirements.md'         'docs/tech/requirements.md'
        Move-Doc 'docs/roadmap.md'              'docs/roadmap/main.md'
        Move-Doc 'docs/site-structure.md'       'docs/arch/site-structure.md'
        Move-Doc 'docs/surface.md'              'docs/arch/surface.md'
        # research
        if (Test-Path 'docs/research/max-qr-checkin.md') {
            Move-Doc 'docs/research/max-qr-checkin.md' 'docs/runbook/max-qr-checkin.md'
        }
        if (Test-Path 'marketing/showcase-draft.md') {
            Move-Doc 'marketing/showcase-draft.md' 'marketing/showcase/draft.md'
        }
    }
    'gym' {
        Write-Host "=== gym ===" -ForegroundColor Cyan
        Move-Doc 'docs/constitution.md'         'docs/arch/constitution.md'
        Move-Doc 'docs/phases.md'               'docs/roadmap/phases.md'
        Move-Doc 'docs/roadmap.md'              'docs/roadmap/main.md'
        if (Test-Path 'marketing/showcase-draft.md') {
            Move-Doc 'marketing/showcase-draft.md' 'marketing/showcase/draft.md'
        }
    }
    'veterinary' {
        Write-Host "=== veterinary ===" -ForegroundColor Cyan
        # Extract help from frontend/src/help/ if it exists
        $helpSrc = "C:\src\products\$Product\frontend\src\help"
        if (Test-Path $helpSrc) {
            $helpFiles = Get-ChildItem $helpSrc -Recurse -File -Filter "*.md" -ErrorAction SilentlyContinue
            foreach ($hf in $helpFiles) {
                $rel = $hf.FullName.Substring((Join-Path $root 'frontend\src\help').Length).TrimStart('\','/').Replace('\','/')
                $target = Join-Path $root "docs\help\ru\$rel"
                $targetParent = Split-Path -Path $target -Parent
                if (-not (Test-Path $targetParent)) {
                    New-Item -ItemType Directory -Force -Path $targetParent | Out-Null
                }
                if (Test-Path $target) { Remove-Item -Path $target -Force }
                Move-Item -Path $hf.FullName -Destination $target -Force
                Write-Host "  [moved] frontend/src/help/$rel -> docs/help/ru/$rel"
            }
        }
    }
}

Write-Host ""
Write-Host "Done."
