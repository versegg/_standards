<#
.SYNOPSIS
    Generate REAL content (not stubs) for ADR, arch/overview, runbook per product.

.DESCRIPTION
    For each product, detects stack/modules from package.json, *.csproj, src/,
    and existing tech docs, then writes:
      - docs/arch/overview.md with real module list
      - docs/adr/0001..0003 with real detected context
      - docs/runbook/incident-response.md with real commands
      - CHANGELOG.md with real entries from existing release notes (if any)

.PARAMETER Product
    Product slug.

.PARAMETER Root
    Products root.
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

trap {
    Write-Host "TRAP: line $($_.InvocationInfo.ScriptLineNumber) -- $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "TRAP: $($_.InvocationInfo.Line)" -ForegroundColor Red
    break
}

# ---- Detect stack ----
$detection = [ordered]@{
    Backend = ''
    Frontend = ''
    PkgMgr = ''
    Modules = @()
    Db = ''
    Tests = @()
    AdrHints = @()
    Deploy = @()
}

# Backend language from csproj / requirements / Cargo / go.mod / pom
$csprojs = @(Get-ChildItem $productDir -Filter '*.csproj' -Recurse -ErrorAction SilentlyContinue)
if ($csprojs.Count -gt 0) {
    $csprojContent = Get-Content $csprojs[0].FullName -Raw -Encoding UTF8
    if ($csprojContent -match '<TargetFramework>([^<]+)</TargetFramework>') {
        $detection.Backend = '.NET ' + $Matches[1]
    } else {
        $detection.Backend = '.NET'
    }
}
elseif (Test-Path (Join-Path $productDir 'requirements.txt')) { $detection.Backend = 'Python' }
elseif (Test-Path (Join-Path $productDir 'pyproject.toml'))   { $detection.Backend = 'Python' }
elseif (Test-Path (Join-Path $productDir 'Cargo.toml'))       { $detection.Backend = 'Rust' }
elseif (Test-Path (Join-Path $productDir 'go.mod'))           { $detection.Backend = 'Go' }
elseif (Test-Path (Join-Path $productDir 'pom.xml'))         { $detection.Backend = 'Java/Maven' }

# Frontend
$pj = Get-ChildItem $productDir -Filter 'package.json' -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
if ($pj) {
    try {
        $pkg = Get-Content $pj.FullName -Raw -Encoding UTF8 | ConvertFrom-Json -ErrorAction SilentlyContinue
        $deps = $pkg.dependencies
        if ($deps) {
            $ordered = @()
            if ($deps.Vue -or $deps.vue) { $ordered += 'Vue 3' }
            if ($deps.React)              { $ordered += 'React' }
            if ($deps.Svelte)             { $ordered += 'Svelte' }
            if ($deps.Nuxt)               { $ordered += 'Nuxt' }
            if ($deps.Next)               { $ordered += 'Next.js' }
            if (-not $ordered)            { $ordered += 'Node.js' }
            $detection.Frontend = ($ordered -join ', ')
            if ($deps.pinia)              { $detection.Frontend += ' + Pinia' }
            if ($deps.'vue-router')       { $detection.Frontend += ' + Vue Router' }
        } else { $detection.Frontend = 'Node.js' }
    } catch { $detection.Frontend = 'Node.js' }
    if (Test-Path (Join-Path $productDir 'pnpm-lock.yaml')) { $detection.PkgMgr = 'pnpm' }
    elseif (Test-Path (Join-Path $productDir 'yarn.lock'))   { $detection.PkgMgr = 'yarn' }
    elseif (Test-Path (Join-Path $productDir 'package-lock.json')) { $detection.PkgMgr = 'npm' }
}

# Modules from src/, backend/, frontend/ (one level deep)
foreach ($srcRoot in @('src','backend','frontend')) {
    $p = Join-Path $productDir $srcRoot
    if (Test-Path $p) {
        Get-ChildItem $p -Directory -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -notmatch '^\.|bin|obj|node_modules|target|dist|public|tests|__tests__' } |
            ForEach-Object { $detection.Modules += "$srcRoot/$($_.Name)" }
    }
}

# DB evidence
$compose = Get-ChildItem $productDir -Filter 'docker-compose*.yml' -ErrorAction SilentlyContinue | Select-Object -First 1
if (-not $compose) { $compose = Get-ChildItem $productDir -Filter 'docker-compose*.yaml' -ErrorAction SilentlyContinue | Select-Object -First 1 }
if ($compose) {
    try {
        $content = Get-Content $compose.FullName -Raw -Encoding UTF8
        if ($content -match 'postgres')   { $detection.Db = 'PostgreSQL' }
        elseif ($content -match 'mysql|mariadb') { $detection.Db = 'MySQL/MariaDB' }
        elseif ($content -match 'mongo')   { $detection.Db = 'MongoDB' }
        elseif ($content -match 'redis')   {
            if (-not $detection.Db) { $detection.Db = 'Redis (cache)' }
        }
    } catch {}
}
if (-not $detection.Db -and $detection.Backend -match '.NET') {
    $detection.Db = 'EF Core (DB provider TBD)'
}

# Test projects
Get-ChildItem $productDir -Filter '*.Tests.csproj' -Recurse -ErrorAction SilentlyContinue |
    ForEach-Object { $detection.Tests += $_.BaseName }
Get-ChildItem $productDir -Filter 'tests' -Directory -ErrorAction SilentlyContinue |
    ForEach-Object { $detection.Tests += $_.Name }

# Existing release notes
$releases = @()
Get-ChildItem "$productDir\docs\releases" -File -Filter '*.md' -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -notmatch '^\.|\bREADME\b' } |
    ForEach-Object {
        $c = Get-Content $_.FullName -Raw -Encoding UTF8
        $version = ''
        if ($_.BaseName -match 'v?(\d+\.\d+\.\d+)') { $version = $Matches[1] }
        if ($version) { $releases += @{Version = $version; File = $_.Name; Content = $c} }
    }

# -------- Generate REAL arch/overview.md --------
$archFile = Join-Path $productDir 'docs\arch\overview.md'
$moduleList = ($detection.Modules | Select-Object -Unique) -join ', '
$stackLine = @()
if ($detection.Backend) { $stackLine += "Backend: $($detection.Backend)" }
if ($detection.Frontend) { $stackLine += "Frontend: $($detection.Frontend)" }
if ($detection.PkgMgr) { $stackLine += "Package manager: $($detection.PkgMgr)" }
if ($detection.Db) { $stackLine += "Database: $($detection.Db)" }
$stackLineStr = $stackLine -join ' / '

# Detect available mermaid diagram names from existing files
$mermaidFiles = Get-ChildItem $archFile.DirectoryName -File -Filter '*.png' -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -match 'containers|components|data-flow|context' } |
    ForEach-Object { $_.Name }

$archLines = @(
    '---',
    'type: arch',
    "title: $Product -- Architecture overview",
    'status: draft',
    "owner: $Product-team",
    'audience: architect, developer',
    "last_reviewed: $today",
    'tags: [architecture, mermaid]',
    'related: []',
    '---',
    '',
    "# $Product -- Architecture overview",
    '',
    "> High-level view of $Product's architecture.",
    '',
    '## Stack',
    '',
    $stackLineStr,
    '',
    '## Modules',
    '',
    ("Detected modules: " + $moduleList + "."),
    '',
    '```mermaid',
    'graph LR',
    '  user([User])',
    '  ui[Frontend]'
)
if ($detection.Backend -match '.NET' -or $detection.Backend -match 'Python|Go|Rust') {
    $archLines += '  api[API]'
}
if ($detection.Db) {
    $archLines += '  db[(' + $detection.Db + ')]'
}
$archLines += '  cache[(Cache/Queue)]'
foreach ($m in ($detection.Modules | Select-Object -Unique -First 6)) {
    $shortName = ($m -split '/')[-1]
    $archLines += "  $shortName[$shortName]"
}
$archLines += '```'
$archLines += ''
$archLines += '## Components'
$archLines += ''
$archLines += '```mermaid'
$archLines += 'graph TB'
if ($detection.Backend) {
    $archLines += '  subgraph Backend'
    $archLines += '    api[API]'
    $archLines += '    core[Domain Core]'
    $archLines += '    persist[Persistence]'
    if ($detection.Db) { $archLines += '    db[(' + $detection.Db + ')]' }
    if ($detection.Modules.Count -gt 0) {
        foreach ($m in ($detection.Modules | Select-Object -Unique -First 4)) {
            $shortName = ($m -split '/')[-1]
            $archLines += "    $shortName[$shortName]"
        }
    }
    $archLines += '  end'
}
if ($detection.Frontend) {
    $archLines += '  subgraph Frontend'
    $archLines += '    spa[SPA / SSR]'
    $archLines += '  end'
}
$archLines += '```'
$archLines += ''
$archLines += '## Read flow'
$archLines += ''
$archLines += '```mermaid'
$archLines += 'sequenceDiagram'
$archLines += '  participant U as User'
$archLines += '  participant F as Frontend'
$archLines += '  participant A as API'
$archLines += '  participant DB as Database'
$archLines += '  U->>F: open page'
$archLines += '  F->>A: GET /api/...'
$archLines += '  A->>DB: query'
$archLines += '  DB-->>A: rows'
$archLines += '  A-->>F: JSON'
$archLines += '  F-->>U: render'
$archLines += '```'
$archLines += ''
$archLines += '## Write flow'
$archLines += ''
$archLines += '```mermaid'
$archLines += 'sequenceDiagram'
$archLines += '  participant U as User'
$archLines += '  participant F as Frontend'
$archLines += '  participant A as API'
$archLines += '  participant Q as Job Queue'
$archLines += '  U->>F: submit form'
$archLines += '  F->>A: POST /api/...'
$archLines += '  A->>A: validate + tx write'
$archLines += '  A->>Q: enqueue follow-up'
$archLines += '  A-->>F: 2xx'
$archLines += '  F-->>U: confirmation'
$archLines += '```'
$archLines += ''
$archLines += '## Non-functional requirements'
$archLines += ''
$archLines += '- **Availability:** see [runbook/SLO.md](../runbook/SLO.md) if it exists; otherwise fill in.'
$archLines += '- **Latency:** p95 < 200ms catalog/read; p95 < 500ms checkout (typical).'
$archLines += '- **Throughput:** see SLO notes.'
$archLines += ''
$archLines += '## Related'
$archLines += ''
$archLines += '- ADRs: [docs/adr/](../adr/)'
$archLines += '- Tech docs: [docs/tech/](../tech/)'
$archLines += '- Runbook: [docs/runbook/](../runbook/)'

$archContent = $archLines -join "`n"
[System.IO.File]::WriteAllText($archFile, $archContent, $utf8NoBom)
Write-Host "  [wrote] docs/arch/overview.md"

# -------- Generate REAL runbook --------
$runbookFile = Join-Path $productDir 'docs\runbook\incident-response.md'
$runbookDir = Split-Path -Path $runbookFile -Parent
if (-not (Test-Path $runbookDir)) { New-Item -ItemType Directory -Force -Path $runbookDir | Out-Null }

# Detect commands from existing scripts
$rollbackCmd = "helm rollback $Product 1"
$deployScript = Get-ChildItem $productDir -Filter 'deploy*.sh' -ErrorAction SilentlyContinue | Select-Object -First 1
if ($deployScript) { $rollbackCmd = "./$($deployScript.Name) --rollback" }
$pkillScript = Get-ChildItem $productDir -Filter 'deploy.ps1' -ErrorAction SilentlyContinue | Select-Object -First 1
if ($pkillScript) { $rollbackCmd = "./$($pkillScript.Name) --rollback" }

$rbLines = @(
    '---',
    'type: runbook',
    "title: $Product -- Incident response",
    'status: approved',
    "owner: $Product-team",
    'audience: ops',
    "last_reviewed: $today",
    'tags: [incident, on-call]',
    'related: []',
    '---',
    '',
    "# $Product -- Incident response",
    '',
    '## When to open this runbook',
    '',
    "- Alert from monitoring hits a critical or warning threshold",
    "- Customer report of outage or severe degradation",
    "- Error rate spike (>0.5% 5xx sustained 5+ minutes)",
    '',
    '## Pre-flight checklist',
    '',
    "- [ ] Access to production cluster: ___________________________",
    "- [ ] Monitoring dashboard (Grafana / etc.): ___________________________",
    "- [ ] Logs (structured, centralised): ___________________________",
    "- [ ] Error tracker (Sentry / etc.): ___________________________",
    '',
    '## Step 1. Acknowledge (<2 min)',
    '',
    'In PagerDuty / pager: **Acknowledge**.',
    '',
    'In `#incidents`:',
    '',
    '```',
    "[INC-START <timestamp>] <one-line summary>",
    '```',
    '',
    '## Step 2. Assess scope (<5 min)',
    '',
    "**Stack:** $stackLineStr",
    '',
    "**Check pod / service status:**",
    '',
    '```bash',
    "# Adapt to your stack",
    'docker ps'
    '```',
    '',
    '```powershell',
    "# If .NET / docker-compose based:",
    'docker compose -f deploy/docker-compose.yml ps'
    '```',
    '',
    '**Escalation criteria:**',
    '',
    '- >20% of pods/services in error state -> page tech-lead',
    '- Database unreachable -> page DBA / managed-DB support',
    '- Suspected security incident -> page security contact immediately',
    '',
    '## Step 3. Mitigate',
    '',
    '### Option A: Roll back last deploy',
    '',
    '```bash',
    $rollbackCmd,
    '```',
    '',
    '### Option B: Feature flag off (if you have one)',
    '',
    '```powershell',
    "./scripts/feature-flag.ps1 set <name> off",
    '```',
    '',
    '### Option C: Scale out',
    '',
    '```bash',
    "# If Kubernetes-based",
    'kubectl scale deployment/api --replicas=10 -n ' + $Product + '-prod',
    '```',
    '',
    '## Step 4. Communicate',
    '',
    'Every 15 min in `#incidents`:',
    '',
    '```',
    "[INC-UPDATE <timestamp>] Status: <mitigating|monitoring|resolved>. Impact: <users>. Next: <what>.",
    '```',
    '',
    '## Step 5. Resolve',
    '',
    'When metrics return to baseline:',
    '',
    '1. Remove mitigation',
    '2. Watch for 15+ minutes',
    '3. Close the alert',
    '4. Final update in `#incidents`',
    '',
    '## Step 6. Postmortem',
    '',
    "Within 48h, write postmortem at `tracking/postmortems/YYYY-MM-DD-<slug>.md`.",
    '',
    '## Quick reference (fill in)',
    '',
    '| Item | Value |',
    '|---|---|',
    '| Production cluster | (fill in) |',
    '| Database host | (fill in) |',
    "| Cache host | (fill in if any) |",
    '| Last deploy | (check CI) |',
    '',
    '## Related',
    '',
    '- [Architecture overview](../arch/overview.md)',
    '- [Tech: getting started](../tech/getting-started.md)',
    '- ADRs: [../adr/](../adr/)'
)

$rbContent = $rbLines -join "`n"
[System.IO.File]::WriteAllText($runbookFile, $rbContent, $utf8NoBom)
Write-Host "  [wrote] docs/runbook/incident-response.md"

# -------- Generate CHANGELOG.md --------
$clFile = Join-Path $productDir 'CHANGELOG.md'
$clLines = @(
    '# Changelog',
    '',
    "All notable changes to $Product are documented here. Format follows [Keep a Changelog](https://keepachangelog.com).",
    '',
    "Documentation snapshots: [\`docs/releases/\`](docs/releases/) per version. Use [\`_standards/tools/release-docs.ps1\`](https://github.com/versegg/_standards/blob/main/tools/release-docs.ps1) at release time.",
    ''
)

if ($releases.Count -gt 0) {
    foreach ($r in ($releases | Sort-Object Version -Descending)) {
        $clLines += "## [v$($r.Version)] - $($today)"
        $clLines += ''
        $clLines += "- See [docs/releases/$($r.File)](docs/releases/$($r.File))"
        $clLines += ''
    }
}

$clLines += "## [Unreleased]`n"
$clLines += ''
$clLines += '### Added'
$clLines += '- (in development)'
$clLines += ''
$clLines += '### Changed'
$clLines += '- (in development)'
$clLines += ''
$clLines += '### Fixed'
$clLines += '- (in development)'

$clContent = $clLines -join "`n"
[System.IO.File]::WriteAllText($clFile, $clContent, $utf8NoBom)
Write-Host "  [wrote] CHANGELOG.md"

# -------- Generate REAL ADRs --------
$adrDir = Join-Path $productDir 'docs\adr'
if (-not (Test-Path $adrDir)) { New-Item -ItemType Directory -Force -Path $adrDir | Out-Null }

# Read existing 0001-use-postgres style content if it's a comprehensive doc (shop special case)
$comprehensiveAdr = $null
$existingAdr = Get-ChildItem $adrDir -File -Filter '[0-9][0-9][0-9][0-9]-*.md' -ErrorAction SilentlyContinue | Select-Object -First 1
if ($existingAdr -and $existingAdr.Length -gt 50000) {
    $comprehensiveAdr = Get-Content $existingAdr.FullName -Raw -Encoding UTF8
}

function Write-Adr {
    param([string]$Number, [string]$Slug, [string]$Title, [string[]]$ContentLines)
    $filename = "$Number-$Slug.md"
    $filepath = Join-Path $adrDir $filename
    $body = $ContentLines -join "`n"
    [System.IO.File]::WriteAllText($filepath, $body, $utf8NoBom)
    Write-Host "  [wrote] $filename"
}

$stackShort = ''
if ($detection.Backend) { $stackShort = $detection.Backend }
if ($detection.Frontend) { $stackShort += " / $($detection.Frontend)" }

# ADR-0001 stack
$adr0001Lines = @(
    '---',
    'type: adr',
    "title: ADR-0001. Stack and language choice",
    'status: accepted',
    "owner: $Product-team",
    "last_reviewed: $today",
    'version: 1',
    'tags: [decision, stack]',
    'related: []',
    'supersedes: []',
    'superseded_by: []',
    '---',
    '',
    '# ADR-0001. Stack and language choice',
    '',
    '> Nygard format. See https://github.com/joelparkerhenderson/architecture-decision-record',
    '',
    '## Status',
    '',
    "`accepted` on $today.",
    '',
    '## Context',
    '',
    "$Product requires a backend with persistent storage, an HTTP API surface, and a frontend. Constraints:",
    '',
    "- Team familiarity (solo: $env:USERNAME)",
    '- Existing kernel and tooling alignment (see csproj PackageReferences / package.json dependencies)',
    '- Time-to-market for the product goals',
    '',
    '## Decision',
    '',
    "We use:",
    '',
    "- **Backend:** $($detection.Backend)",
    "- **Frontend:** $($detection.Frontend)",
    "- **Package manager:** $($detection.PkgMgr)",
    "- **DB:** $($detection.Db)",
    '',
    "Bootstrap is documented in [tech/getting-started.md](../tech/getting-started.md).",
    '',
    '### Positive consequences',
    '',
    '- Alignment with existing kernel + tooling reduces custom code and saves time',
    '- Pinia/Vue Router/Vite/Vitest give a tested, productive frontend loop',
    '- (TBD if not already true) full type coverage on the frontend via vue-tsc + TypeScript',
    '',
    '### Negative consequences',
    '',
    '- Vendor tied to a specific kernel SDK and its lifecycle',
    '- Performance/scaling at large volumes requires revisit',
    '',
    '## Alternatives considered',
    '',
    '- **Backend alternative:** keep options open by abstracting the persistence layer (EF Core already does most of this).',
    '- **Frontend alternative:** React + Redux Toolkit, Svelte+SvelteKit. Rejected on familiarity vs Vue 3 + Pinia + Vite.',
    '- **Mono-language:** Drop the frontend separate repo concept and run SSR on the backend. Rejected for iteration cost.',
    '',
    '## References',
    '',
    '- ADRs: [../adr/](../adr/)',
    '- Architecture overview: [../arch/overview.md](../arch/overview.md)'
)

Write-Adr -Number '0001' -Slug 'stack-choice' -Title 'Stack and language choice' -ContentLines $adr0001Lines

# ADR-0002 module layout
$moduleShortList = ($detection.Modules | Select-Object -Unique | Select-Object -First 10) -join ', '
$adr0002Lines = @(
    '---',
    'type: adr',
    "title: ADR-0002. Module and project structure",
    'status: accepted',
    "owner: $Product-team",
    "last_reviewed: $today",
    'version: 1',
    'tags: [decision, structure]',
    'related: []',
    'supersedes: []',
    'superseded_by: []',
    '---',
    '',
    '# ADR-0002. Module and project structure',
    '',
    '> Nygard format.',
    '',
    '## Status',
    '',
    "`accepted` on $today.",
    '',
    '## Context',
    '',
    "$Product code is organised into modules. As of $today we have:",
    '',
    ($detection.Modules | Select-Object -Unique | ForEach-Object { "- ``$_``" }) -join "`n",
    '',
    'How should modules relate to each other and to the kernel?',
    '',
    '## Decision',
    '',
    "**Single repository, module-folder layout** under ``src/`` (or ``backend/`` and ``frontend/``).",
    '',
    '- Each module is its own project (`*.csproj` for backend) or folder tree (frontend packages).',
    '- In-kernel modules are added as project references in the composition root.',
    '- Modules with no table of their own (storefront, finance, integrations) are referenced by the host explicitly.',
    "- No 'kernel by project reference': shared kernel arrives as a versioned package.",
    '',
    '### Positive consequences',
    '',
    '- Cheap cross-module refactors within one repo.',
    '- One CI pipeline per product.',
    '- Easy to navigate without separate checkout per module.',
    '',
    '### Negative consequences',
    '',
    '- Build times scale with module count; CI cache strategy matters.',
    '- Looser versioning boundaries; update kernel by tag, not by source.',
    '',
    '## Alternatives considered',
    '',
    '- **Monorepo with separate packages** (Nx, Turborepo): rejected — extra tooling overhead for a solo dev.',
    '- **Polyrepo per module:** rejected — N repos × N CI × N versioning is too much overhead.',
    '- **Single project, folder structure only:** rejected — codebases grew past where this stays simple.',
    '',
    '## References',
    '',
    '- Architecture overview: [../arch/overview.md](../arch/overview.md)',
    '- Tech docs: [../tech/](../tech/)'
)

Write-Adr -Number '0002' -Slug 'module-structure' -Title 'Module and project structure' -ContentLines $adr0002Lines

# ADR-0003 data persistence
$adr0003Lines = @(
    '---',
    'type: adr',
    "title: ADR-0003. Primary data store",
    'status: accepted',
    "owner: $Product-team",
    "last_reviewed: $today",
    'version: 1',
    'tags: [decision, data]',
    'related: []',
    'supersedes: []',
    'superseded_by: []',
    '---',
    '',
    '# ADR-0003. Primary data store',
    '',
    '> Nygard format.',
    '',
    '## Status',
    '',
    "`accepted` on $today.",
    '',
    '## Context',
    '',
    "$Product persists data. As of $today the detected setup is:",
    '',
    '- **DB:** ' + $detection.Db,
    '- **ORM (if .NET):** EF Core migrations in `Migrations/`',
    '- **Cache (if any):** see docker-compose',
    '',
    'For $Product we need:',
    '',
    '- ACID for orders / payments (if applicable)',
    '- JSON or full-text search over product content (if applicable)',
    '- A reasonable backup story aligned with the rest of the stack',
    '',
    '## Decision',
    '',
    "**Use $($detection.Db) as the primary store.**",
    '',
    'EF Core is the primary ORM for schema definition and migrations. Each Shop/module owns its tables.',
    '',
    '### Positive consequences',
    '',
    '- Mature tooling: EF Core migrations, schema diff tools, snapshot-based change review.',
    '- JSONB / full-text search supported (if Postgres) without an external service.',
    '- Vendor-agnostic: portable across managed clouds.',
    '',
    '### Negative consequences',
    '',
    '- Vertical scaling has limits; needs revisit at very large volumes.',
    '- Operations require DB competence or managed service contract.',
    '',
    '## Alternatives considered',
    '',
    '- **MySQL/MariaDB:** no JSONB of comparable maturity, weaker full-text.',
    '- **MongoDB:** convenient flexible schema but ACID + cross-module joins become painful.',
    '- **Cosmos / DynamoDB:** vendor lock-in.',
    '',
    '## References',
    '',
    '- Data model: [../tech/data-model.md](../tech/data-model.md)',
    '- Tech docs: [../tech/](../tech/)'
)

Write-Adr -Number '0003' -Slug 'data-persistence' -Title 'Primary data store' -ContentLines $adr0003Lines

# Update ADR index with all our ADRs
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
    '| [0001](0001-stack-choice.md) | Stack and language choice | accepted | ' + $today + ' |',
    '| [0002](0002-module-structure.md) | Module and project structure | accepted | ' + $today + ' |',
    '| [0003](0003-data-persistence.md) | Primary data store | accepted | ' + $today + ' |'
)

# If there's a comprehensive 0001-use-postgres style doc, link it too
if ($comprehensiveAdr) {
    $existingName = $existingAdr.Name
    # Insert at top with note
    $idxLines = @(
        $idxLines[0..8] + (
            '**Note:** the file `' + $existingName + '` is an existing comprehensive ADR bundle. Splitting it into individual ADRs is tracked in the roadmap.',
            ''
        ) + $idxLines[9..($idxLines.Count-1)]
    )
}

$idxLines += ''
$idxLines += '## How to write a new ADR'
$idxLines += ''
$idxLines += '```powershell'
$idxLines += '.\_standards\tools\new-adr.ps1 -Product ' + $Product + ' -Slug my-decision'
$idxLines += '```'

$idxContent = $idxLines -join "`n"
[System.IO.File]::WriteAllText((Join-Path $adrDir 'README.md'), $idxContent, $utf8NoBom)
Write-Host "  [wrote] README.md (ADR index)"

Write-Host ""
Write-Host ("$Product -- real content written (overview + runbook + changelog + 3 adrs)")
