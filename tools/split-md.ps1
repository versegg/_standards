<#
.SYNOPSIS
    Split a .md file by top-level ## headers into separate files.

.PARAMETER Path
    Path to source .md file.

.PARAMETER Frontmatter
    Has YAML frontmatter (preserve and add to each split file).

.PARAMETER OutputDir
    Directory for split output files. Defaults to source's directory.

.PARAMETER Locale
    Default locale (e.g. 'ru') to add to frontmatter if missing.

.PARAMETER SlugPrefix
    Prefix for output filenames (e.g. 'kb' for knowledge-base sections -> kb-01-...).

.PARAMETER Owner
    Default owner to add to frontmatter.

.PARAMETER DryRun
    Print what would happen; don't write.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string]$Path,
    [string]$OutputDir,
    [string]$Locale = 'ru',
    [string]$SlugPrefix = '',
    [string]$Owner = 'product-team',
    [string]$Type = 'help',
    [string]$Tag = 'split-section',
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'

$fullPath = Resolve-Path $Path
if (-not $OutputDir) { $OutputDir = Split-Path -Path $fullPath -Parent }
if (-not (Test-Path $OutputDir)) { New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null }

$content = Get-Content -Path $fullPath -Raw -Encoding UTF8
$today = (Get-Date).ToString('yyyy-MM-dd')

# Strip existing frontmatter
$body = $content
if ($content -match '(?s)^---\r?\n(.*?)\r?\n---\r?\n?(.*)$') {
    $body = $Matches[2]
}

# Split by ## headers (only top-level ## not ### or deeper)
# Each section starts with "## N. <title>" or "## <title>"
$lines = $body -split "`r?`n"
$sections = @()
$current = $null
$headerPattern = '^##\s+(.+)$'

foreach ($line in $lines) {
    if ($line -match $headerPattern) {
        if ($current) { $sections += $current }
        $current = @{
            title = $Matches[1].Trim()
            lines = @($line)
        }
    } else {
        if ($current) {
            $current.lines += $line
        } else {
            # preamble (before first ## header)
            if (-not $sections) {
                $script:preamble = (@($script:preamble) + $line) -join "`n"
            }
        }
    }
}
if ($current) { $sections += $current }

Write-Host "Source: $Path"
Write-Host "Sections found: $($sections.Count)"

function To-Slug {
    param([string]$Title)
    # Take first 60 chars, lowercase, replace non-alphanumeric with -
    $t = $Title.ToLower()
    $t = $t -replace '^\d+[\.\s]*', ''  # strip leading numbers like "1. "
    $t = $t -replace '[^\w\s\-]', ''
    $t = $t -replace '\s+', '-'
    $t = $t -replace '-+', '-'
    $t = $t.Trim('-')
    if ($t.Length -gt 50) { $t = $t.Substring(0, 50).TrimEnd('-') }
    return $t
}

$idx = 0
foreach ($sec in $sections) {
    $idx++
    $slug = To-Slug -Title $sec.title
    if ($SlugPrefix) { $slug = "$SlugPrefix-$('{0:D2}' -f $idx)-$slug" }
    else { $slug = "$('{0:D2}' -f $idx)-$slug" }
    $filename = "$slug.md"
    $outPath = Join-Path $OutputDir $filename

    $fm = @(
        '---',
        "type: $Type",
        "title: $($sec.title)",
        'status: draft',
        "owner: $Owner",
        "locale: $Locale",
        "last_reviewed: $today",
        "tags: [$Tag]",
        'related: []',
        '---',
        ''
    ) -join "`n"

    $body = $sec.lines -join "`n"
    $full = $fm + "`n" + $body

    if ($DryRun) {
        Write-Host "  [would write] $filename"
    } else {
        Set-Content -Path $outPath -Value $full -Encoding UTF8 -NoNewline
        Write-Host "  [wrote] $filename"
    }
}

if ($DryRun) {
    Write-Host ""
    Write-Host "[DryRun] Would also delete original: $Path"
} else {
    Write-Host ""
    Write-Host "Deleting original: $Path"
    Remove-Item -Path $fullPath -Force
}
