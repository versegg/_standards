<#
.SYNOPSIS
    Create a stub docs/arch/overview.md with mermaid diagrams for a product.
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

$archDir = Join-Path $productDir "docs\arch"
if (-not (Test-Path $archDir)) { New-Item -ItemType Directory -Force -Path $archDir | Out-Null }
$diagramDir = Join-Path $archDir "diagrams"
if (-not (Test-Path $diagramDir)) { New-Item -ItemType Directory -Force -Path $diagramDir | Out-Null }

$archFile = Join-Path $archDir "overview.md"

if (Test-Path $archFile) {
    Write-Host "  [skip, exists] $archFile"
    exit 0
}

# Detect stack
$stack = @()
if (Test-Path (Join-Path $productDir 'package.json')) { $stack += 'Node.js' }
if (Test-Path (Join-Path $productDir 'pnpm-lock.yaml')) { $stack += 'pnpm' }
if (Test-Path (Join-Path $productDir 'yarn.lock')) { $stack += 'yarn' }
if (Test-Path (Join-Path $productDir 'requirements.txt')) { $stack += 'Python' }
if (Test-Path (Join-Path $productDir 'pyproject.toml')) { $stack += 'Python' }
if (Test-Path (Join-Path $productDir 'Cargo.toml')) { $stack += 'Rust' }
if (Test-Path (Join-Path $productDir 'go.mod')) { $stack += 'Go' }
if (Get-ChildItem $productDir -Filter '*.csproj' -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1) { $stack += '.NET' }
if (Test-Path (Join-Path $productDir 'pom.xml')) { $stack += 'Java/Maven' }
$stackLine = if ($stack.Count -gt 0) { ($stack -join ', ') } else { "(fill in from package.json / etc.)" }

# Detect modules from src/ subdirectories
$srcDir = Join-Path $productDir "src"
$modules = @()
if (Test-Path $srcDir) {
    $modules = Get-ChildItem $srcDir -Directory -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -notmatch '^\.' } |
        ForEach-Object { $_.Name }
}
if ($modules.Count -eq 0) {
    # Try backend/, frontend/, etc.
    $modules = Get-ChildItem $productDir -Directory -Depth 1 -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -in @('backend','frontend','shared','core','src','api','libs') } |
        ForEach-Object { $_.Name }
}
$moduleLine = if ($modules.Count -gt 0) { ($modules -join ', ') } else { "(fill in from src/, backend/, frontend/, etc.)" }

$content = @"
---
type: arch
title: $Product -- Architecture overview
status: draft
owner: $Product-team
audience: architect, developer
version: 0.1.0
last_reviewed: $today
tags: [architecture, mermaid]
related: []
---

# $Product -- Architecture overview

> High-level view of $Product's architecture. Fill in the details as you build or evolve the product.

## Stack

**Tech stack:** $stackLine

## Modules

$moduleLine

## Containers

\`\`\`mermaid
graph LR
  user([User])
  ui[Storefront / Admin UI]
  api[API]
  db[(Database)]
  cache[(Cache / Queue)]
  ext[External integrations]

  user --> ui
  ui --> api
  api --> db
  api --> cache
  api --> ext
\`\`\`

## Components

\`\`\`mermaid
graph TB
  subgraph Backend
    api[API]
    core[Domain Core]
    persist[Persistence]
    jobs[Jobs / Workers]
  end
  subgraph Frontend
    spa[SPA / SSR]
  end
  subgraph Storage
    db[(Database)]
    cache[(Redis)]
    obj[(Object storage)]
  end

  spa --> api
  api --> core
  core --> persist
  core --> jobs
  persist --> db
  jobs --> cache
  api --> obj
\`\`\`

## Key flows

### Read flow (e.g. catalog browse)

\`\`\`mermaid
sequenceDiagram
  participant U as User
  participant F as Frontend
  participant A as API
  participant DB as Database
  U->>F: open page
  F->>A: GET /api/...
  A->>DB: query
  DB-->>A: rows
  A-->>F: JSON
  F-->>U: render
\`\`\`

### Write flow (e.g. create order)

\`\`\`mermaid
sequenceDiagram
  participant U as User
  participant F as Frontend
  participant A as API
  participant DB as Database
  participant Q as Job Queue

  U->>F: submit form
  F->>A: POST /api/...
  A->>DB: write (tx)
  A->>Q: enqueue follow-up
  A-->>F: 201 Created
  F-->>U: confirmation
  Q-->>A: process async
\`\`\`

## Non-functional requirements

- **Availability:** (target %)
- **Latency:** (p95 / p99 targets)
- **Throughput:** (RPS targets)

## Related

- ADRs: [docs/adr/](../adr/)
- Tech docs: [docs/tech/](../tech/)
- Runbook: [docs/runbook/](../runbook/)

## Diagrams source

For higher-fidelity diagrams (C4, ERD), edit `diagrams/*.puml` or `diagrams/*.drawio` and reference the generated PNGs here.
"@

[System.IO.File]::WriteAllText($archFile, $content, $utf8NoBom)
Write-Host "Created: $archFile"
