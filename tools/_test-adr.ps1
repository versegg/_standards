$ErrorActionPreference = "Stop"
$product = "shop"
$root = "C:\src\products"
$productDir = Join-Path $root $product
$today = "2026-09-17"

# Detect modules
$detection = [ordered]@{ Modules = @() }
foreach ($srcRoot in @("src","backend","frontend")) {
  $p = Join-Path $productDir $srcRoot
  if (Test-Path $p) {
    Get-ChildItem $p -Directory -ErrorAction SilentlyContinue |
      Where-Object { $_.Name -notmatch '^\.|bin|obj|node_modules|target|dist|public|tests' } |
      ForEach-Object { $detection.Modules += "$srcRoot/$($_.Name)" }
  }
}
"Module count: $($detection.Modules.Count)"

# Build module list line
$moduleListLine = ($detection.Modules | Select-Object -Unique | ForEach-Object { "- ``$_``" }) -join "`n"
"moduleListLine length: $($moduleListLine.Length)"

# Build $adr0002Lines
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
    $moduleListLine,
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
"adr0002Lines count: $($adr0002Lines.Count)"
$body = $adr0002Lines -join "`n"
"body length: $($body.Length)"
