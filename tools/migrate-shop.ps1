<#
.SYNOPSIS
    Migrate shop product to canonical documentation structure.
#>

[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$root = "C:\src\products\shop"
Set-Location $root

function Move-Doc {
    param([string]$From, [string]$To)
    $fromPath = Join-Path $root $From
    $toPath = Join-Path $root $To
    if (-not (Test-Path $fromPath)) {
        Write-Host "  [skip, not found] $From"
        return
    }
    if ($fromPath -eq $toPath) {
        Write-Host "  [skip, same] $From"
        return
    }
    $toParent = Split-Path -Path $toPath -Parent
    if (-not (Test-Path $toParent)) {
        New-Item -ItemType Directory -Force -Path $toParent | Out-Null
    }
    # If target exists (stub), remove it
    if (Test-Path $toPath) {
        Remove-Item -Path $toPath -Force
    }
    git mv $From $To 2>&1 | Out-Null
    Write-Host "  [moved] $From -> $To"
}

Write-Host "=== shop: arch/ -> arch/ + tech/ + runbook/" -ForegroundColor Cyan
Move-Doc 'docs/arch/01-adrs.md'           'docs/adr/0001-use-postgres.md'
Move-Doc 'docs/arch/02-kernel-extension-plan.md' 'docs/tech/kernel-extension.md'
Move-Doc 'docs/arch/03-module-dependencies.md'  'docs/arch/components.md'
Move-Doc 'docs/arch/04-deployment.md'     'docs/runbook/deployment.md'
Move-Doc 'docs/arch/05-compliance-architecture.md' 'docs/arch/compliance.md'
Move-Doc 'docs/arch/06-roadmap.md'        'docs/roadmap/_legacy-2026-q3-snapshot.md'

Write-Host ""
Write-Host "=== shop: design/ -> design/ + mockups/" -ForegroundColor Cyan
Move-Doc 'docs/design/01-design-system.md'           'docs/design/design-system.md'
Move-Doc 'docs/design/02-palettes.md'                'docs/design/design-tokens.md'
Move-Doc 'docs/design/03-theme-packs.md'             'docs/design/themes.md'
Move-Doc 'docs/design/04-page-constructor-blocks.md' 'docs/design/patterns.md'
Move-Doc 'docs/design/05-storefront-ux.md'           'docs/design/storefront-ux.md'
Move-Doc 'docs/design/06-admin-manager-ux.md'        'docs/design/admin-ux.md'
Move-Doc 'docs/design/07-mobile-ux.md'               'docs/design/mobile-ux.md'
Move-Doc 'docs/design/08-shop-lab.md'                'docs/design/shop-lab.md'
Move-Doc 'docs/design/09-ui-primitives.md'           'docs/design/ui-primitives.md'
Move-Doc 'docs/design/mockups/README.md'             'mockups/README.md'
Move-Doc 'docs/design/mockups/wireframes-admin.md'         'mockups/wireframes-admin.md'
Move-Doc 'docs/design/mockups/wireframes-manager.md'       'mockups/wireframes-manager.md'
Move-Doc 'docs/design/mockups/wireframes-mobile.md'         'mockups/wireframes-mobile.md'
Move-Doc 'docs/design/mockups/wireframes-ordering-themes.md' 'mockups/wireframes-ordering-themes.md'
Move-Doc 'docs/design/mockups/wireframes-storefront.md'     'mockups/wireframes-storefront.md'

Write-Host ""
Write-Host "=== shop: features/ -> tech/features/" -ForegroundColor Cyan
Move-Doc 'docs/features/00-product-model.md'           'docs/tech/features/product-model.md'
Move-Doc 'docs/features/01-catalog.md'                 'docs/tech/features/catalog.md'
Move-Doc 'docs/features/02-media-gallery.md'           'docs/tech/features/media.md'
Move-Doc 'docs/features/03-cart-checkout-ordering.md'  'docs/tech/features/checkout.md'
Move-Doc 'docs/features/04-payments-fiscalization.md'  'docs/tech/features/payments.md'
Move-Doc 'docs/features/05-warehouse-inventory.md'     'docs/tech/features/inventory.md'
Move-Doc 'docs/features/06-orders-fulfillment.md'      'docs/tech/features/orders.md'
Move-Doc 'docs/features/07-employees-rbac.md'          'docs/tech/features/employees-rbac.md'
Move-Doc 'docs/features/08-profiles.md'                'docs/tech/features/profiles.md'
Move-Doc 'docs/features/09-analytics.md'               'docs/tech/features/analytics.md'
Move-Doc 'docs/features/10-finance-audit.md'           'docs/tech/features/finance.md'
Move-Doc 'docs/features/11-page-constructor.md'        'docs/tech/features/page-constructor.md'
Move-Doc 'docs/features/12-branding-themes.md'         'docs/tech/features/branding.md'
Move-Doc 'docs/features/13-changelog-help.md'          'docs/tech/features/changelog-help.md'
Move-Doc 'docs/features/14-integrations.md'            'docs/tech/features/integrations.md'
Move-Doc 'docs/features/15-platform-multiclient.md'    'docs/tech/features/multi-tenant.md'
Move-Doc 'docs/features/16-permissions-matrix.md'      'docs/tech/features/permissions.md'
Move-Doc 'docs/features/17-seeder-app.md'              'docs/tech/features/seeder.md'

Write-Host ""
Write-Host "=== shop: tech/ -> api/ + tech/" -ForegroundColor Cyan
Move-Doc 'docs/tech/01-api-contract.md'    'docs/api/contract.md'
Move-Doc 'docs/tech/02-data-model.md'      'docs/tech/data-model.md'
Move-Doc 'docs/tech/03-caching.md'         'docs/tech/caching.md'
Move-Doc 'docs/tech/04-media-pipeline.md'  'docs/tech/media-pipeline.md'
Move-Doc 'docs/tech/05-integrations.md'    'docs/tech/integrations.md'
Move-Doc 'docs/tech/06-security.md'        'docs/tech/security.md'

Write-Host ""
Write-Host "=== shop: top-level + marketing" -ForegroundColor Cyan
Move-Doc 'docs/technical-specification.md' 'docs/tech/architecture-overview.md'
Move-Doc 'docs/market-research.md'         'marketing/positioning.md'
Move-Doc 'docs/roadmap.md'                 'docs/roadmap/_legacy-main.md'
Move-Doc 'marketing/showcase-draft.md'     'marketing/showcase/draft.md'

Write-Host ""
Write-Host "Done."
