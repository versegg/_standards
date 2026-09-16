<#
.SYNOPSIS
    Ensure canonical folder structure exists for a product. Create stubs for required-missing types.

.PARAMETER Product
    Product slug.

.PARAMETER Root
    Root dir. Default: C:\src\products.

.PARAMETER DryRun
    If set, only prints what would be created.
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
    Write-Error "Product '$Product' not found in $Root"
    exit 1
}

$today = (Get-Date).ToString('yyyy-MM-dd')

$dirs = @(
    'docs\manual\ru','docs\manual\en',
    'docs\help\ru','docs\help\en',
    'docs\tech','docs\arch','docs\adr',
    'docs\api','docs\runbook',
    'docs\releases','docs\roadmap','docs\design',
    'marketing\showcase','marketing\hero','marketing\campaigns','marketing\brand'
)

function Write-Stub {
    param(
        [string]$Path,
        [string[]]$Lines
    )
    if (Test-Path $Path) { return }
    if ($DryRun) { Write-Host "  [would-create] $Path"; return }
    $parent = Split-Path -Path $Path -Parent
    if (-not (Test-Path $parent)) {
        New-Item -ItemType Directory -Force -Path $parent | Out-Null
    }
    Set-Content -Path $Path -Value ($Lines -join "`r`n") -Encoding UTF8
    Write-Host "  [created] $Path"
}

$createdDirs = 0
foreach ($d in $dirs) {
    $full = Join-Path $productDir $d
    if (-not (Test-Path $full)) {
        if (-not $DryRun) {
            New-Item -ItemType Directory -Force -Path $full | Out-Null
        }
        $createdDirs++
    }
}

$stubs = @{}

# docs/tech/getting-started.md
$gs = Join-Path $productDir 'docs\tech\getting-started.md'
if (-not (Test-Path $gs)) {
    $stubs[$gs] = @(
        '---',
        'type: tech',
        "title: $Product -- Getting started",
        'status: draft',
        "owner: $Product-team",
        'audience: developer',
        "last_reviewed: $today",
        'tags: [onboarding]',
        'related: []',
        '---',
        '',
        "# $Product -- Getting started",
        '',
        '> Brief description: what you need to run this project locally.',
        '',
        '## Prerequisites',
        '',
        '- (fill in: runtime, DB, tools)',
        '',
        '## Steps',
        '',
        '1. (fill in)',
        '2. (fill in)',
        '',
        '## Related',
        '',
        '- [Architecture overview](./architecture-overview.md)',
        ''
    )
}

# docs/tech/architecture-overview.md
$ao = Join-Path $productDir 'docs\tech\architecture-overview.md'
if (-not (Test-Path $ao)) {
    $stubs[$ao] = @(
        '---',
        'type: tech',
        "title: $Product -- Architecture overview",
        'status: draft',
        "owner: $Product-team",
        'audience: developer, architect',
        "last_reviewed: $today",
        'tags: [architecture]',
        'related: []',
        '---',
        '',
        "# $Product -- Architecture overview",
        '',
        '> Brief description of modules and data flows.',
        '',
        '## Modules',
        '',
        '| Module | Responsibility |',
        '|---|---|',
        '| (fill in) | (fill in) |',
        '',
        '## Key flows',
        '',
        '## Related',
        '',
        '- [Getting started](./getting-started.md)',
        ''
    )
}

# docs/releases/README.md
$rl = Join-Path $productDir 'docs\releases\README.md'
if (-not (Test-Path $rl)) {
    $stubs[$rl] = @(
        '---',
        'type: release',
        "title: $Product -- changelog",
        'status: approved',
        "owner: $Product-team",
        'audience: all',
        "last_reviewed: $today",
        'tags: [changelog]',
        'related: []',
        '---',
        '',
        "# $Product -- changelog",
        '',
        '| Version | Date | Highlights |',
        '|---|---|---|',
        '| (fill in) | (fill in) | (fill in) |',
        ''
    )
}

# docs/roadmap/README.md
$rm = Join-Path $productDir 'docs\roadmap\README.md'
if (-not (Test-Path $rm)) {
    $stubs[$rm] = @(
        '---',
        'type: roadmap',
        "title: $Product -- roadmap",
        'status: draft',
        "owner: $Product-team",
        'audience: all',
        "last_reviewed: $today",
        'tags: [roadmap]',
        'related: []',
        '---',
        '',
        "# $Product -- roadmap",
        '',
        'Current focus -- fill in this section.',
        ''
    )
}

# docs/roadmap/themes.md
$th = Join-Path $productDir 'docs\roadmap\themes.md'
if (-not (Test-Path $th)) {
    $stubs[$th] = @(
        '---',
        'type: roadmap',
        "title: $Product -- long-term themes",
        'status: draft',
        "owner: $Product-team",
        'audience: all',
        "last_reviewed: $today",
        'tags: [themes]',
        'related: []',
        '---',
        '',
        "# $Product -- long-term themes",
        '',
        '## 1. (fill in)',
        '',
        'Horizon: ...',
        '',
        '## 2. (fill in)',
        ''
    )
}

# marketing/showcase/README.md
$ms = Join-Path $productDir 'marketing\showcase\README.md'
if (-not (Test-Path $ms)) {
    $stubs[$ms] = @(
        '---',
        'type: showcase',
        "title: $Product -- showcase",
        'status: draft',
        "owner: $Product-team",
        'audience: sales, partner',
        "last_reviewed: $today",
        'tags: [showcase]',
        'related: []',
        '---',
        '',
        "# $Product -- showcase",
        '',
        'Vitrine of key capabilities. Used by sales, marketing, partners.',
        '',
        '## Available showcases',
        '',
        '- (none yet -- add one per template in `_standards/templates/showcase-item.md`)',
        ''
    )
}

# marketing/hero/README.md
$mh = Join-Path $productDir 'marketing\hero\README.md'
if (-not (Test-Path $mh)) {
    $stubs[$mh] = @(
        '---',
        'type: hero',
        "title: $Product -- hero media",
        'status: draft',
        "owner: $Product-team",
        'audience: marketing',
        "last_reviewed: $today",
        'tags: [hero]',
        'related: []',
        '---',
        '',
        "# $Product -- hero media",
        '',
        'Current hero media for the landing page.',
        '',
        '## Currently active',
        '',
        '- (fill in)',
        ''
    )
}

# mockups/README.md
$mu = Join-Path $productDir 'mockups\README.md'
if (-not (Test-Path $mu)) {
    $stubs[$mu] = @(
        '---',
        'type: mockup',
        "title: $Product -- mockups",
        'status: draft',
        "owner: $Product-team",
        'audience: designer, product-manager',
        "last_reviewed: $today",
        'tags: [mockups]',
        'related: []',
        '---',
        '',
        "# $Product -- mockups",
        '',
        'Visual mockups. Source of truth: Figma.',
        ''
    )
}

foreach ($k in $stubs.Keys) {
    Write-Stub -Path $k -Lines $stubs[$k]
}

Write-Host "Product: $Product  Created dirs: $createdDirs  Stubs: $($stubs.Count)"
