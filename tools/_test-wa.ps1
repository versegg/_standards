$ErrorActionPreference = "Stop"
$root = "C:\src\products"
$product = "shop"
$productDir = Join-Path $root $product
$today = "2026-09-17"
$utf8NoBom = [System.Text.UTF8Encoding]::new($false)
$adrDir = Join-Path $productDir "docs\adr"
if (-not (Test-Path $adrDir)) { New-Item -ItemType Directory -Force -Path $adrDir | Out-Null }

function Write-Adr {
    param([string]$Number, [string]$Slug, [string]$Title, [string[]]$ContentLines)
    $filename = "$Number-$Slug.md"
    $filepath = Join-Path $adrDir $filename
    $body = $ContentLines -join "`n"
    [System.IO.File]::WriteAllText($filepath, $body, $utf8NoBom)
    Write-Host "  [wrote] $filename -- body length: $($body.Length)"
}

# Same content as the script
$adr0002Lines = @(
    '---',
    'type: adr',
    'title: ADR-0002. Module and project structure',
    'status: accepted',
    "owner: $product-team",
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
    "$product code is organised into modules. As of $today we have:",
    '',
    ("- ``src/Shop.Api``", "- ``src/Shop.Caching``", "- ``src/Shop.Catalog``", "- ``src/Shop.Checkout``", "- ``src/Shop.Compliance``", "- ``src/Shop.Content``", "- ``src/Shop.Core``", "- ``src/Shop.Employees``", "- ``src/Shop.Finance``", "- ``src/Shop.Integrations``", "- ``src/Shop.Inventory``", "- ``src/Shop.Jobs.Redis``", "- ``src/Shop.Media``", "- ``src/Shop.Orders``", "- ``src/Shop.Payments``", "- ``src/Shop.Persistence``", "- ``src/Shop.Platform``", "- ``src/Shop.Profiles``", "- ``src/Shop.Seeder``", "- ``src/Shop.Storefront``", "- ``src/frontend``") -join "`n",
    '',
    'How should modules relate to each other and to the kernel?',
    '',
    '## Decision',
    '',
    '**Single repository, module-folder layout** under ``src/`` (or ``backend/`` and ``frontend/``).',
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
    '- **Monorepo with separate packages** (Nx, Turborepo): rejected -- extra tooling overhead for a solo dev.',
    '- **Polyrepo per module:** rejected -- N repos x N CI x N versioning is too much overhead.',
    '- **Single project, folder structure only:** rejected -- codebases grew past where this stays simple.',
    '',
    '## References',
    '',
    '- Architecture overview: [../arch/overview.md](../arch/overview.md)',
    '- Tech docs: [../tech/](../tech/)'
)

Write-Host "adr0002Lines count: $($adr0002Lines.Count)"
$body = $adr0002Lines -join "`n"
Write-Host "body length before WriteAllText: $($body.Length)"

Write-Adr -Number '0002' -Slug 'module-structure' -Title 'Module and project structure' -ContentLines $adr0002Lines

# Verify file size on disk
$filepath = Join-Path $adrDir "0002-module-structure.md"
if (Test-Path $filepath) {
    Write-Host "File size on disk: $((Get-Item $filepath).Length)"
}
