<#
.SYNOPSIS
    Seed initial ADRs for a product based on detected stack and architecture.
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

# Detect stack
$stack = @{}
if (Test-Path (Join-Path $productDir 'package.json')) {
    $stack['frontend'] = 'Node.js'
    if (Test-Path (Join-Path $productDir 'pnpm-lock.yaml')) { $stack['pkgmgr'] = 'pnpm' }
    elseif (Test-Path (Join-Path $productDir 'yarn.lock'))   { $stack['pkgmgr'] = 'yarn' }
    else { $stack['pkgmgr'] = 'npm' }
}
if (Test-Path (Join-Path $productDir 'requirements.txt')) { $stack['backend'] = 'Python' }
if (Test-Path (Join-Path $productDir 'pyproject.toml'))   { $stack['backend'] = 'Python' }
if (Test-Path (Join-Path $productDir 'Cargo.toml'))       { $stack['backend'] = 'Rust' }
if (Test-Path (Join-Path $productDir 'go.mod'))           { $stack['backend'] = 'Go' }
if (Get-ChildItem $productDir -Filter '*.csproj' -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1) { $stack['backend'] = '.NET' }
if (Test-Path (Join-Path $productDir 'pom.xml'))         { $stack['backend'] = 'Java/Maven' }

$backend = $stack['backend']
$frontend = $stack['frontend']
$stackLine = (($stack.Values | Select-Object -Unique) -join ', ')
if (-not $stackLine) { $stackLine = '(fill in from package.json / *.csproj / etc.)' }

# Detect modules
$modules = @()
foreach ($srcRoot in @('src','backend','frontend')) {
    $p = Join-Path $productDir $srcRoot
    if (Test-Path $p) {
        Get-ChildItem $p -Directory -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -notmatch '^\.|bin|obj|node_modules|target|dist' } |
            ForEach-Object { $modules += "$srcRoot/$($_.Name)" }
    }
}
$moduleLine = if ($modules.Count -gt 0) { ($modules -join ', ') } else { '(fill in from src/, backend/, frontend/)' }

# Detect DB
$db = '(TBD)'
$dbEvidence = ''
if (Test-Path (Join-Path $productDir 'docker-compose.yml')) { $composeFile = 'docker-compose.yml' }
elseif (Test-Path (Join-Path $productDir 'docker-compose.yaml')) { $composeFile = 'docker-compose.yaml' }
else { $composeFile = $null }
if ($composeFile) {
    try {
        $composeContent = Get-Content (Join-Path $productDir $composeFile) -Raw -Encoding UTF8
        if ($composeContent -match 'postgres') { $db = 'PostgreSQL'; }
        elseif ($composeContent -match 'mysql|mariadb') { $db = 'MySQL/MariaDB' }
        elseif ($composeContent -match 'mongo') { $db = 'MongoDB' }
        elseif ($composeContent -match 'mssql|sqlserver') { $db = 'SQL Server' }
        $dbEvidence = " (detected from $composeFile)"
    } catch {}
}
if ($db -eq '(TBD)') {
    if (Get-ChildItem $productDir -Filter 'Migrations' -Recurse -Directory -ErrorAction SilentlyContinue | Select-Object -First 1) {
        $db = 'EF Core migrations' + $dbEvidence
    }
}

$adrDir = Join-Path $productDir "docs\adr"
if (-not (Test-Path $adrDir)) { New-Item -ItemType Directory -Force -Path $adrDir | Out-Null }

function New-Adr {
    param(
        [string]$Number,
        [string]$Slug,
        [string]$Title,
        [string]$Context,
        [string]$Decision,
        [string]$Alternatives
    )

    $filename = "$Number-$Slug.md"
    $filepath = Join-Path $script:adrDir $filename

    $lines = @(
        '---',
        "type: adr",
        "title: ADR-$Number. $Title",
        'status: draft',
        "owner: $script:Product-team",
        "last_reviewed: $script:today",
        'version: 1',
        'tags: [decision]',
        'related: []',
        'supersedes: []',
        'superseded_by: []',
        '---',
        '',
        "# ADR-$Number. $Title",
        '',
        '> Nygard format. See https://github.com/joelparkerhenderson/architecture-decision-record',
        '',
        '## Status',
        '',
        "`draft`` on $script:today.",
        '',
        '## Context',
        '',
        $Context,
        '',
        '## Decision',
        '',
        $Decision,
        '',
        '### Positive consequences',
        '',
        '- TODO (fill in expected benefits)',
        '',
        '### Negative consequences',
        '',
        '- TODO: licensing, performance, scalability, vendor lock-in',
        '',
        '## Alternatives considered',
        '',
        $Alternatives,
        '',
        '## References',
        '',
        '- Related ADRs: (link after you write more)',
        '- Tech docs: [../tech/](../tech/)',
        '- Architecture overview: [../arch/overview.md](../arch/overview.md)'
    )
    $body = $lines -join "`n"
    [System.IO.File]::WriteAllText($filepath, $body, $script:utf8NoBom)
    Write-Host "  [created] $filename"
}

# ADR 0001
$ctx0001 = "$Product is being built. As of $today we have detected:`n`n- **Stack:** $stackLine`n- **Modules / directories:** $moduleLine`n- **Persistence layer:** $db`n`nWhat are we building this with?"
$dec0001 = "**$Product is implemented in $stackLine.**`n`nThe choice was driven by:`n- Team familiarity (solo: that's you)`n- Existing infrastructure and shared kernel alignment`n- Time-to-market for the current milestone`n`nSee [tech/getting-started.md](../tech/getting-started.md) for the local bootstrap."
$alts0001 = "- TODO: list 2-3 alternatives you considered (e.g. for backend: Go vs .NET vs Node; for DB: PostgreSQL vs MySQL vs Mongo)"
New-Adr -Number "0001" -Slug "stack-choice" -Title "Stack and language choice" -Context $ctx0001 -Decision $dec0001 -Alternatives $alts0001

# ADR 0002
$ctx0002 = "$Product code is organized into modules: $moduleLine.`n`nShould each module be:`n- A separate folder in a monorepo (current setup),`n- A separate repository / package,`n- A NuGet / npm package shared from the kernel repo?"
$dec0002 = "**We use a single repo with module-folder layout (`src/<Module>` or `backend/<Module>`).**`n`nTraded some compile-time isolation for simple cross-module refactors and shared CI.`n`nModules communicate via:`n- Direct references for in-kernel calls`n- Events (see ADR-0003 if queued) for cross-module async`n- Public HTTP/gRPC for product boundaries (future, not yet)"
$alts0002 = "- TODO: monorepo with packages (Nx, Turborepo, Pants), polyrepo, modular monolith via runtime plugins"
New-Adr -Number "0002" -Slug "module-structure" -Title "Module / repository structure" -Context $ctx0002 -Decision $dec0002 -Alternatives $alts0002

# ADR 0003
$ctx0003 = "$Product persists data into $db.`n`nFor $Product we need:`n- ACID for orders / payments (if applicable)`n- JSON or full-text search over product content (if applicable)`n- Reasonable backup story`n- TCO aligned with the rest of the stack ($stackLine)"
$dec0003 = "**$Product uses $db.**`n`n(If the actual DB is different from what was auto-detected, edit this section.)"
$alts0003 = "- TODO: list 2-3 alternatives (PostgreSQL vs MySQL vs SQL Server for OLTP, MongoDB vs Postgres JSONB for flexible schema)"
New-Adr -Number "0003" -Slug "data-persistence" -Title "Primary data store" -Context $ctx0003 -Decision $dec0003 -Alternatives $alts0003

# ADR index
$idxFile = Join-Path $adrDir "README.md"
if (-not (Test-Path $idxFile)) {
    $idxLines = @(
        '---',
        'type: adr',
        "title: ADR index -- $Product",
        'status: approved',
        "owner: $Product-team",
        "last_reviewed: $today",
        'audience: developer, architect',
        'tags: [adr]',
        'related: []',
        '---',
        '',
        "# ADR index -- $Product",
        '',
        "Architectural Decision Records for $Product.",
        '',
        '| Number | Title | Status | Date |',
        '|---|---|---|---|',
        '| [0001](0001-stack-choice.md) | Stack and language choice | draft | ' + $today + ' |',
        '| [0002](0002-module-structure.md) | Module / repository structure | draft | ' + $today + ' |',
        '| [0003](0003-data-persistence.md) | Primary data store | draft | ' + $today + ' |',
        '',
        '## How to write a new ADR',
        '',
        '```powershell',
        '.\\_standards\\tools\\new-adr.ps1 -Product ' + $Product + ' -Slug my-decision',
        '```'
    )
    $idxBody = $idxLines -join "`n"
    [System.IO.File]::WriteAllText($idxFile, $idxBody, $utf8NoBom)
    Write-Host "  [created] README.md"
}

Write-Host ""
Write-Host "$Product seeded with 3 ADRs + index."
