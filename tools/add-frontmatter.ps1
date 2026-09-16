<#
.SYNOPSIS
    Add YAML frontmatter to all .md files under docs/, marketing/, mockups/ of a product.

.DESCRIPTION
    Infers type from path. Skips files that already have frontmatter and INDEX.md.
    Defaults: status=draft, owner=<product>-team, last_reviewed=2026-09-16.

.PARAMETER Product
    Product slug.

.PARAMETER Root
    Root dir. Default: C:\src\products.

.PARAMETER DryRun
    If set, only prints what would change; doesn't write.
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

$scanRoots = @(
    (Join-Path $productDir 'docs'),
    (Join-Path $productDir 'marketing'),
    (Join-Path $productDir 'mockups'),
    (Join-Path $productDir 'media')
) | Where-Object { Test-Path $_ -PathType Container }

# type inference rules: ordered most-specific first
function Get-InferredType {
    param([string]$RelPath)
    $p = $RelPath.ToLower().Replace('\','/')

    # explicit paths
    if ($p -match '/adr/')   { return 'adr' }
    if ($p -match '/api/')   { return 'api' }
    if ($p -match '/arch/')  { return 'arch' }
    if ($p -match '/runbook/') { return 'runbook' }
    if ($p -match '/releases?/') { return 'release' }
    if ($p -match '/roadmap/')  { return 'roadmap' }
    if ($p -match '/design/')   { return 'design' }
    if ($p -match '/help/')     { return 'help' }
    if ($p -match '/manual/')   { return 'manual' }

    # tech docs by file name heuristic
    if ($p -match '/(tech|technical)/') { return 'tech' }
    if ($p -match '/features?/') { return 'tech' }
    if ($p -match '/architecture/') { return 'arch' }

    # marketing by path
    if ($p -match '/showcase/') { return 'showcase' }
    if ($p -match '/hero/')     { return 'hero' }
    if ($p -match '/campaigns/'){ return 'campaign' }
    if ($p -match '/brand/')    { return 'brand' }

    # file name heuristics
    $name = [System.IO.Path]::GetFileNameWithoutExtension($RelPath).ToLower()
    if ($name -in @('roadmap','themes','backlog')) { return 'roadmap' }
    if ($name -in @('architecture','arch','adr','adrs')) { return 'adr' }
    if ($name -match '^adr[-_]?\d') { return 'adr' }
    if ($name -match 'release|changelog') { return 'release' }
    if ($name -match 'runbook|incident|on-call') { return 'runbook' }
    if ($name -match 'api[- ]?contract|api[- ]?reference') { return 'api' }
    if ($name -match 'design[- ]?system|design[- ]?tokens|palette|theme|theme-pack|page[- ]?constructor|wireframe') { return 'design' }
    if ($name -match 'compliance') { return 'tech' }
    if ($name -match 'deployment|deploy|handover|operations|ops') { return 'runbook' }
    if ($name -match 'manual|user[- ]?manual|guide|getting[- ]?started|how[- ]?to') { return 'manual' }
    if ($name -match 'positioning|competitive|market|persona|segment|gtm') { return 'positioning' }
    if ($name -match 'pitch|elevator|investor') { return 'pitch' }
    if ($name -match 'showcase|vitrine') { return 'showcase' }
    if ($name -match 'hero') { return 'hero' }
    if ($name -match 'campaign') { return 'campaign' }
    if ($name -match 'brand|logo|typography') { return 'brand' }
    if ($name -match 'mockup|mockup') { return 'mockup' }
    if ($name -match 'feature|catalog|cart|checkout|order|payment|inventory|warehouse|profile|analytics|finance|media|integration|branding|seeder|permission') { return 'tech' }
    if ($name -match 'domain[- ]?model|data[- ]?model|security|caching|kernel') { return 'tech' }
    if ($name -match 'purpose|vision|scope|description|README|readme|max|next-session|next[- ]?session|review|enhancement|import|landing-text|launch|versioning|white-label|max-qr-checkin|knowledge-base|technical-spec|site-modes|site-structure|project-structure|reference-projects|reuse-notes|concerns|end-users|opportunities|requirements|surface|backlog|phases|constitution|market-research') { return 'tech' }

    # marketing folder but no specific type
    if ($RelPath -match '^marketing\\') { return 'pitch' }

    # default
    return 'tech'
}

function Get-InferredLocale {
    param([string]$RelPath)
    $p = $RelPath.ToLower().Replace('\','/')
    if ($p -match '/ru/') { return 'ru' }
    if ($p -match '/en/') { return 'en' }
    return 'ru'  # default for these products
}

function Has-Frontmatter {
    param([string]$Path)
    $content = Get-Content -Path $Path -Raw -Encoding UTF8 -ErrorAction SilentlyContinue
    if (-not $content) { return $false }
    return ($content -match '(?s)^---\r?\n.*?\r?\n---')
}

function Build-Frontmatter {
    param(
        [string]$Type,
        [string]$Locale,
        [string]$Product,
        [string]$Title,
        [string]$Owner,
        [string]$Today
    )

    $sb = [System.Text.StringBuilder]::new()
    [void]$sb.AppendLine('---')
    [void]$sb.AppendLine("type: $Type")
    [void]$sb.AppendLine("title: $Title")
    [void]$sb.AppendLine('status: draft')
    [void]$sb.AppendLine("owner: $Owner")
    if ($Locale) {
        [void]$sb.AppendLine("locale: $Locale")
    }
    [void]$sb.AppendLine("last_reviewed: $Today")
    [void]$sb.AppendLine('tags: []')
    [void]$sb.AppendLine('related: []')
    [void]$sb.AppendLine('---')
    [void]$sb.AppendLine('')
    return $sb.ToString()
}

function Get-FileTitle {
    param([string]$Path)
    $name = [System.IO.Path]::GetFileNameWithoutExtension($Path)
    # strip numeric prefixes "01-" "02-arch-"
    $name = $name -replace '^\d{2}[-_]?', ''
    # kebab -> words
    $title = ($name -replace '[-_]', ' ').Trim()
    # title-case for English
    if ($title -match '^[a-zA-Z\s\.\-/]+$') {
        $title = (Get-Culture).TextInfo.ToTitleCase($title.ToLower())
    }
    return $title
}

$processed = 0
$skipped = 0
$added = 0

foreach ($scanRoot in $scanRoots) {
    $files = Get-ChildItem -Path $scanRoot -Recurse -File -Filter '*.md' -ErrorAction SilentlyContinue

    foreach ($file in $files) {
        $rel = $file.FullName.Substring($productDir.Length)
        # Skip INDEX.md (generated) and README.md only at scan root level
        $depth = ($rel.TrimStart('\','/').Split('\').Count)
        if ($file.Name -eq 'INDEX.md') { continue }
        if ($file.Name -eq 'README.md' -and $depth -le 1) { continue }

        $processed++

        if (Has-Frontmatter -Path $file.FullName) {
            $skipped++
            continue
        }

        $type = Get-InferredType -RelPath $rel
        $locale = Get-InferredLocale -RelPath $rel
        $title = Get-FileTitle -Path $file.FullName
        $owner = "$Product-team"
        $fm = Build-Frontmatter -Type $type -Locale $locale -Product $Product -Title $title -Owner $owner -Today $today

        if ($DryRun) {
            Write-Host "  [would-add] $rel -- type=$type locale=$locale"
        } else {
            # Read existing content (skip if empty)
            $existing = Get-Content -Path $file.FullName -Raw -Encoding UTF8 -ErrorAction SilentlyContinue
            if (-not $existing) { $existing = "" }
            $newContent = $fm + $existing
            Set-Content -Path $file.FullName -Value $newContent -Encoding UTF8 -NoNewline
            $added++
        }
    }
}

Write-Host "Product: $Product  Processed: $processed  Added: $added  Skipped(existing): $skipped"
