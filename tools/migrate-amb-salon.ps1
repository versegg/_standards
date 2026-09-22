<#
.SYNOPSIS
    Migrate amb and salon to canonical structure.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][ValidateSet('amb','salon')][string]$Product
)

$ErrorActionPreference = 'Stop'

$root = "C:\src\products\$Product"
Set-Location $root

function Move-Doc {
    param([string]$From, [string]$To)
    $fromPath = Join-Path $root $From
    $toPath = Join-Path $root $To
    if (-not (Test-Path $fromPath)) {
        Write-Host "  [skip, not found] $From"
        return
    }
    if ($fromPath -eq $toPath) { return }
    $toParent = Split-Path -Path $toPath -Parent
    if (-not (Test-Path $toParent)) {
        New-Item -ItemType Directory -Force -Path $toParent | Out-Null
    }
    if (Test-Path $toPath) { Remove-Item -Path $toPath -Force }
    git mv $From $To 2>&1 | Out-Null
    Write-Host "  [moved] $From -> $To"
}

switch ($Product) {
    'amb' {
        Write-Host "=== amb ===" -ForegroundColor Cyan
        # Top-level docs that are clearly other types
        Move-Doc 'docs/architecture.md'           'docs/arch/overview.md'
        Move-Doc 'docs/domain-model.md'          'docs/tech/data-model.md'
        Move-Doc 'docs/feature-inventory.md'     'docs/tech/features.md'
        Move-Doc 'docs/landing-text.md'          'marketing/positioning.md'
        Move-Doc 'docs/manual-customer.md'       'docs/manual/ru/customer/getting-started.md'
        Move-Doc 'docs/purpose.md'               'docs/arch/purpose.md'
        Move-Doc 'docs/development.md'           'docs/tech/development.md'
        Move-Doc 'docs/deployment.md'            'docs/runbook/deployment.md'
        Move-Doc 'docs/deployment-laptop.md'     'docs/runbook/deployment-laptop.md'
        Move-Doc 'docs/deployment-laptop-prototype.md' 'docs/runbook/deployment-laptop-prototype.md'
        Move-Doc 'docs/design-system.md'         'docs/design/design-system.md'
        Move-Doc 'docs/handover.md'              'docs/runbook/handover.md'
        Move-Doc 'docs/git-flow.md'              'docs/tech/git-flow.md'
        Move-Doc 'docs/white-label.md'           'docs/tech/white-label.md'
        Move-Doc 'docs/versioning.md'            'docs/tech/versioning.md'
        Move-Doc 'docs/import.md'                'docs/tech/import.md'
        Move-Doc 'docs/bugs.md'                  'docs/roadmap/bugs.md'
        Move-Doc 'docs/audit-2026-08-15.md'      'docs/runbook/audit-2026-08-15.md'
        Move-Doc 'docs/admin-sweep-backlog.md'   'docs/roadmap/admin-sweep-backlog.md'
        Move-Doc 'docs/delegated-backend.md'     'docs/roadmap/delegated-backend.md'
        Move-Doc 'docs/delegated-frontend.md'    'docs/roadmap/delegated-frontend.md'
        Move-Doc 'docs/enhancements.md'          'docs/roadmap/enhancements.md'
        Move-Doc 'docs/launch-roadmap.md'        'docs/roadmap/launch.md'
        Move-Doc 'docs/next-session.md'          'docs/roadmap/next-session.md'
        Move-Doc 'docs/review.md'                'docs/roadmap/review.md'
        Move-Doc 'docs/roadmap.md'               'docs/roadmap/main.md'
        Move-Doc 'docs/roadmap-next.md'          'docs/roadmap/next.md'
        Move-Doc 'docs/roadmap-suspended.md'     'docs/roadmap/suspended.md'
        Move-Doc 'docs/max.md'                   'docs/arch/max.md'
        Move-Doc 'docs/USER_GUIDE.md'            'docs/manual/ru/index.md'
        Move-Doc 'docs/hero-video.md'            'marketing/hero/README.md'
        Move-Doc 'docs/image-spec.md'            'marketing/hero/image-spec.md'
        Move-Doc 'docs/installer.md'             'docs/runbook/installer.md'
        Move-Doc 'docs/release-checklist.md'     'docs/runbook/release-checklist.md'

        # 00-general/ -> tech/
        Write-Host "  00-general/ -> tech/"
        Move-Doc 'docs/00-general/DASHBOARD-QUICKSTART.md' 'docs/tech/dashboard-quickstart.md'
        Move-Doc 'docs/00-general/DESCRIPTION.md'          'docs/tech/description.md'
        Move-Doc 'docs/00-general/e2e-testing.md'         'docs/tech/e2e-testing.md'
        Move-Doc 'docs/00-general/EN.md'                   'marketing/pitch.md'
        Move-Doc 'docs/00-general/git-flow.md'            'docs/tech/git-flow-general.md'

        # 01-backend/ -> tech/ (avoid name clash with existing)
        Write-Host "  01-backend/ -> tech/"
        Move-Doc 'docs/01-backend/code-style-guide.md'     'docs/tech/backend-code-style.md'
        Move-Doc 'docs/01-backend/blueprints/blueprint.md' 'docs/tech/backend-blueprint.md'

        # archive/ -> keep but mark deprecated
        Write-Host "  archive/ -> archive/ (deprecated)"
        # Don't move archive files - they are intentionally archived

        # compliance/ -> keep (legal docs)
        Write-Host "  compliance/ stays"

        # release/v0.1/ -> releases/v0.1/
        Write-Host "  release/v0.1/ -> releases/v0.1/"
        Move-Doc 'docs/release/v0.1/README.md'       'docs/releases/v0.1/README.md'
        Move-Doc 'docs/release/v0.1/accounts.md'     'docs/releases/v0.1/accounts.md'
        Move-Doc 'docs/release/v0.1/environment.md'  'docs/releases/v0.1/environment.md'
        Move-Doc 'docs/release/v0.1/known-issues.md' 'docs/releases/v0.1/known-issues.md'
        Move-Doc 'docs/release/v0.1/verification.md' 'docs/releases/v0.1/verification.md'

        # plans/pwa-plan.md -> tech/pwa-plan.md
        Move-Doc 'docs/plans/pwa-plan.md' 'docs/tech/pwa-plan.md'

        # scenarios/ -> tech/scenarios/
        Write-Host "  scenarios/ -> tech/scenarios/"
        Move-Doc 'docs/scenarios/README.md'        'docs/tech/scenarios/README.md'
        Move-Doc 'docs/scenarios/01-booking.md'    'docs/tech/scenarios/01-booking.md'
        Move-Doc 'docs/scenarios/02-checkout.md'   'docs/tech/scenarios/02-checkout.md'
        Move-Doc 'docs/scenarios/03-order-lifecycle.md' 'docs/tech/scenarios/03-order-lifecycle.md'
        Move-Doc 'docs/scenarios/04-master-day.md' 'docs/tech/scenarios/04-master-day.md'
        Move-Doc 'docs/scenarios/05-warehouse.md'  'docs/tech/scenarios/05-warehouse.md'
        Move-Doc 'docs/scenarios/06-finance-and-salary.md' 'docs/tech/scenarios/06-finance-and-salary.md'
        Move-Doc 'docs/scenarios/07-notifications.md' 'docs/tech/scenarios/07-notifications.md'
        Move-Doc 'docs/scenarios/08-white-label.md' 'docs/tech/scenarios/08-white-label.md'

        # user-guide/ -> manual/<role>/
        Write-Host "  user-guide/ -> manual/<role>/"
        Move-Doc 'docs/user-guide/README.md'   'docs/manual/ru/README.md'
        Move-Doc 'docs/user-guide/admin.md'    'docs/manual/ru/admin/admin.md'
        Move-Doc 'docs/user-guide/client.md'   'docs/manual/ru/customer/client.md'
        Move-Doc 'docs/user-guide/faq.md'      'docs/help/ru/faq.md'
        Move-Doc 'docs/user-guide/features.md' 'docs/tech/features-guide.md'
        Move-Doc 'docs/user-guide/master.md'   'docs/manual/ru/manager/master.md'
        Move-Doc 'docs/user-guide/owner.md'    'docs/manual/ru/admin/owner.md'
        Move-Doc 'docs/user-guide/visitor.md'  'docs/help/ru/visitor.md'

        # user-guide-public/ -> marketing/<role>/
        Write-Host "  user-guide-public/ -> marketing/public/"
        Move-Doc 'docs/user-guide-public/README.md'   'marketing/public/README.md'
        Move-Doc 'docs/user-guide-public/admin.md'    'marketing/public/admin.md'
        Move-Doc 'docs/user-guide-public/client.md'   'marketing/public/client.md'
        Move-Doc 'docs/user-guide-public/faq.md'      'marketing/public/faq.md'
        Move-Doc 'docs/user-guide-public/features.md' 'marketing/public/features.md'
        Move-Doc 'docs/user-guide-public/master.md'   'marketing/public/master.md'
        Move-Doc 'docs/user-guide-public/owner.md'    'marketing/public/owner.md'
        Move-Doc 'docs/user-guide-public/visitor.md'  'marketing/public/visitor.md'
    }
    'salon' {
        Write-Host "=== salon ===" -ForegroundColor Cyan
        # Top-level numbered files
        Move-Doc 'docs/00-README.md'                 'docs/README.md'
        Move-Doc 'docs/21-execution-plan.md'         'docs/roadmap/execution-plan.md'
        Move-Doc 'docs/22-deploy-runbook.md'         'docs/runbook/deployment.md'
        Move-Doc 'docs/23-backup-recovery.md'        'docs/runbook/backup-recovery.md'
        Move-Doc 'docs/24-load-testing.md'           'docs/tech/load-testing.md'
        Move-Doc 'docs/26-security-audit.md'         'docs/tech/security-audit.md'
        Move-Doc 'docs/27-demo-walkthrough.md'       'marketing/showcase/demo-walkthrough.md'

        # 01-vision/ -> roadmap/
        Write-Host "  01-vision/ -> roadmap/"
        Move-Doc 'docs/01-vision/01-vision-and-scope.md' 'docs/roadmap/vision.md'

        # 02-personas/ -> marketing/personas.md
        Move-Doc 'docs/02-personas/02-personas-and-roles.md' 'marketing/personas.md'

        # 03-features/ -> tech/features.md
        Move-Doc 'docs/03-features/03-feature-catalog.md'   'docs/tech/feature-catalog.md'

        # 04-stories/ -> tech/user-stories.md
        Move-Doc 'docs/04-stories/04-user-stories.md'        'docs/tech/user-stories.md'

        # 05-use-cases/ -> tech/use-cases.md
        Move-Doc 'docs/05-use-cases/05-use-cases.md'         'docs/tech/use-cases.md'

        # 06-screens/ -> design/screens.md (combine)
        Move-Doc 'docs/06-screens/06-screens-inventory.md'   'docs/design/screens-inventory.md'

        # 07-admin/ -> design/admin-screens.md
        Move-Doc 'docs/07-admin/07-screen-specs-admin.md'     'docs/design/admin-screens.md'

        # 08-master/ -> design/master-screens.md
        Move-Doc 'docs/08-master/08-screen-specs-master.md'   'docs/design/master-screens.md'

        # 09-pwa/ -> design/pwa-screens.md
        Move-Doc 'docs/09-pwa/09-screen-specs-pwa.md'         'docs/design/pwa-screens.md'

        # 10-public/ -> design/public-screens.md
        Move-Doc 'docs/10-public/10-screen-specs-public.md'   'docs/design/public-screens.md'

        # 11-flows/ -> design/flows.md
        Move-Doc 'docs/11-flows/11-interaction-flows.md'      'docs/design/interaction-flows.md'

        # 12-architecture/ -> arch/
        Move-Doc 'docs/12-architecture/12-architecture.md'    'docs/arch/overview.md'

        # 13-tech-reuse/ -> tech/tech-stack.md
        Move-Doc 'docs/13-tech-reuse/13-tech-stack-and-reuse.md' 'docs/tech/tech-stack.md'

        # 14-data-model/ -> tech/data-model.md
        Move-Doc 'docs/14-data-model/14-data-model.md'        'docs/tech/data-model.md'

        # 15-api/ -> api/
        Move-Doc 'docs/15-api/15-api-contract.md'             'docs/api/contract.md'

        # 16-compliance/ -> arch/compliance.md
        Move-Doc 'docs/16-compliance/16-compliance-ru.md'     'docs/arch/compliance.md'

        # 17-integrations/ -> tech/integrations.md
        Move-Doc 'docs/17-integrations/17-integrations.md'    'docs/tech/integrations.md'

        # 18-nfr/ -> tech/nfr.md
        Move-Doc 'docs/18-nfr/18-nfr-and-security.md'         'docs/tech/nfr.md'

        # 19-deploy/ -> runbook/
        Move-Doc 'docs/19-deploy/19-deploy-and-ops.md'        'docs/runbook/deploy-and-ops.md'

        # 20-roadmap/ -> roadmap/
        Move-Doc 'docs/20-roadmap/20-roadmap.md'              'docs/roadmap/main.md'

        # 25-user-manuals/ -> manual/<role>/
        Write-Host "  25-user-manuals/ -> manual/<role>/"
        Move-Doc 'docs/25-user-manuals/README.md'      'docs/manual/ru/README.md'
        Move-Doc 'docs/25-user-manuals/25-administrator.md' 'docs/manual/ru/admin/administrator.md'
        Move-Doc 'docs/25-user-manuals/25-cashier.md'  'docs/manual/ru/manager/cashier.md'
        Move-Doc 'docs/25-user-manuals/25-master.md'   'docs/manual/ru/manager/master.md'
        Move-Doc 'docs/25-user-manuals/25-owner.md'    'docs/manual/ru/admin/owner.md'
        Move-Doc 'docs/25-user-manuals/25-pwa-client.md' 'docs/manual/ru/customer/pwa-client.md'

        if (Test-Path 'marketing/showcase-draft.md') {
            Move-Doc 'marketing/showcase-draft.md' 'marketing/showcase/draft.md'
        }
    }
}

Write-Host ""
Write-Host "Done."
