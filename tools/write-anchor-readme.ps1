<#
.SYNOPSIS
    Write a root README.md (anchor document) for a product.

.DESCRIPTION
    Detects description from existing README or first lines of any doc.
    Creates root README.md only if missing (use -Force to overwrite).

.PARAMETER Product
    Product slug.

.PARAMETER Root
    Root dir. Default: C:\src\products.

.PARAMETER Force
    Overwrite existing root README.md.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string]$Product,
    [string]$Root = "C:\src\products",
    [switch]$Force
)

$ErrorActionPreference = 'Stop'

$productDir = Join-Path $Root $Product
if (-not (Test-Path $productDir -PathType Container)) {
    Write-Error "Product '$Product' not found in $Root"
    exit 1
}

$today = (Get-Date).ToString('yyyy-MM-dd')
$readme = Join-Path $productDir 'README.md'

if ((Test-Path $readme) -and -not $Force) {
    Write-Host "Product: $Product  README.md exists, skipping (use -Force to overwrite)"
    return
}

# Detect description
$desc = ""
$descSources = @('README.md','docs\README.md','docs\00-README.md','docs\purpose.md','docs\00-vision-and-roadmap.md','docs\DESCRIPTION.md','docs\EN.md')
foreach ($src in $descSources) {
    if ($desc) { break }
    $full = Join-Path $productDir $src
    if (Test-Path $full) {
        $c = Get-Content $full -TotalCount 50 -Encoding UTF8 -ErrorAction SilentlyContinue
        $capture = $false
        foreach ($line in $c) {
            $line = $line.Trim()
            if ($line -match '^#\s') { $capture = $true; continue }
            if ($capture -and $line -and -not $line.StartsWith('#') -and -not $line.StartsWith('-') -and $line.Length -gt 30) {
                $desc = $line
                break
            }
        }
    }
}

if (-not $desc) {
    $desc = "$Product -- product. Add a short description here."
}

# Detect stack
$stack = @()
if (Test-Path (Join-Path $productDir 'package.json')) { $stack += 'Node.js' }
if (Test-Path (Join-Path $productDir 'pnpm-lock.yaml')) { $stack += 'pnpm' }
if (Test-Path (Join-Path $productDir 'yarn.lock'))     { $stack += 'yarn' }
if (Test-Path (Join-Path $productDir 'requirements.txt')) { $stack += 'Python' }
if (Test-Path (Join-Path $productDir 'pyproject.toml'))   { $stack += 'Python' }
if (Test-Path (Join-Path $productDir 'Cargo.toml'))       { $stack += 'Rust' }
if (Test-Path (Join-Path $productDir 'go.mod'))           { $stack += 'Go' }
if (Get-ChildItem -Path $productDir -Filter '*.csproj' -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1) { $stack += '.NET' }
if (Test-Path (Join-Path $productDir 'pom.xml'))         { $stack += 'Java/Maven' }
if (Test-Path (Join-Path $productDir 'build.gradle'))    { $stack += 'Java/Gradle' }

$stackLine = if ($stack.Count -gt 0) { "**Stack:** " + ($stack -join ', ') } else { "**Stack:** (fill in)" }

$lines = @(
    '---',
    'type: readme',
    "title: $Product",
    'status: approved',
    "owner: $Product-team",
    'audience: all',
    "last_reviewed: $today",
    'tags: []',
    'related: []',
    '---',
    '',
    "# $Product",
    '',
    $desc,
    '',
    $stackLine,
    '',
    '## Quick start',
    '',
    '- Developer: [docs/tech/getting-started.md](docs/tech/getting-started.md)',
    '- Architecture: [docs/arch/](docs/arch/)',
    '- API: [docs/api/](docs/api/)',
    '- Admin / user manual: [docs/manual/](docs/manual/)',
    '- Marketing & showcase: [marketing/showcase/](marketing/showcase/)',
    '',
    '## Documentation',
    '',
    '- All docs: [docs/INDEX.md](docs/INDEX.md)',
    '- Marketing index: [marketing/INDEX.md](marketing/INDEX.md)',
    '- Mockups: [mockups/README.md](mockups/README.md)',
    '',
    '## Development',
    '',
    '- Architecture overview: [docs/tech/architecture-overview.md](docs/tech/architecture-overview.md)',
    '- ADRs: [docs/adr/](docs/adr/)',
    '- Runbook: [docs/runbook/](docs/runbook/)',
    '- Testing: [docs/tech/](docs/tech/)',
    '',
    '## Status',
    '',
    '- Latest release: [docs/releases/](docs/releases/)',
    '- Roadmap: [docs/roadmap/](docs/roadmap/)',
    '- Current branch: see `git branch --show-current`',
    '',
    '## Documentation standard',
    '',
    'This product follows the unified standard: [`_standards/README.md`](../_standards/README.md).',
    'All docs have frontmatter, INDEX.md is auto-generated.',
    ''
)

Set-Content -Path $readme -Value ($lines -join "`r`n") -Encoding UTF8
Write-Host "Product: $Product  Wrote README.md"
