<#
.SYNOPSIS
    Create a docs/runbook/incident-response.md stub for a product.
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

$runbookDir = Join-Path $productDir "docs\runbook"
if (-not (Test-Path $runbookDir)) { New-Item -ItemType Directory -Force -Path $runbookDir | Out-Null }

$rbFile = Join-Path $runbookDir "incident-response.md"
if (Test-Path $rbFile) {
    Write-Host "Already exists: $rbFile"
    exit 0
}

$content = @"
---
type: runbook
title: Incident response -- what to do when paged
status: approved
owner: $Product-team
audience: ops
last_reviewed: $today
tags: [incident, on-call]
related: []
---

# Incident response -- what to do when paged

## When to open this runbook

- Alert from monitoring (Grafana / Prometheus / Sentry / etc.)
- Customer report of outage
- Error rate spike

## Pre-flight checklist (have these ready)

- [ ] Access to production cluster (kubectl / docker / ssh)
- [ ] Access to monitoring dashboards (URL: _________________________)
- [ ] Access to logs (URL: _________________________)
- [ ] Access to error tracker (Sentry / etc., URL: _________________________)
- [ ] Phone/SIM with pager (you are reading this from it)

## Step 1. Acknowledge (<2 min)

In PagerDuty / pager system, click **Acknowledge**. Announce in `#incidents`:

\`\`\`
[INC-START <timestamp>] <one-line summary of the alert>
\`\`\`

## Step 2. Assess scope (<5 min)

\`\`\`bash
# Adapt these to your stack
kubectl get pods -n $Product-prod
# OR
docker ps
\`\`\`

Look for:
- CrashLoopBackOff pods
- OOMKilled
- High restart counts
- Network connectivity errors

**Escalation criteria:**
- >20% of pods/containers in error state -> page tech-lead
- Database unreachable -> page DBA / managed-DB support
- Suspected security breach -> page security contact immediately

## Step 3. Mitigate immediately

Use the first applicable tactic:

### A. Roll back to last known good

\`\`\`bash
# Adapt to your deploy tooling
helm rollback $Product 1
# OR
kubectl rollout undo deployment/api -n $Product-prod
# OR
./scripts/deploy.sh --rollback
\`\`\`

### B. Scale out (if load-related)

\`\`\`bash
kubectl scale deployment/api --replicas=10 -n $Product-prod
\`\`\`

### C. Toggle feature flag (if you have one)

\`\`\`bash
./scripts/feature-flag.sh set <name> off
\`\`\`

### D. Drain traffic (if service is healthy but DB is not)

\`\`\`bash
kubectl scale deployment/api --replicas=0 -n $Product-prod
\`\`\`

## Step 4. Communicate

Every 15 min in `#incidents`:

\`\`\`
[INC-UPDATE <timestamp>] Status: <mitigating|monitoring|resolved>. Impact: <users affected>. Next: <what>.
\`\`\`

If customer-visible, update status page:
- Status page URL: _________________________
- Login: who owns the status page credentials

## Step 5. Resolve

When metrics return to baseline:
1. Remove mitigation (re-enable flagged feature, restore replicas, etc.)
2. Watch for 15+ minutes
3. Close the alert in PagerDuty
4. Final update in \`#incidents\`

## Step 6. Postmortem (within 48 hours)

Open a postmortem at \`tracking/postmortems/YYYY-MM-DD-<slug>.md\` with:
- Timeline
- Root cause
- What went well
- What went poorly
- Action items with owners and dates

## Quick reference

| Item | Location |
|---|---|
| Production cluster | (fill in) |
| Database host | (fill in) |
| Cache host | (fill in) |
| CDN dashboard | (fill in) |
| Logs URL | (fill in) |
| Dashboards URL | (fill in) |
| Status page | (fill in) |
| Last deploy | (check CI) |

## Related

- [Architecture overview](../arch/overview.md)
- ADRs: [../adr/](../adr/)
"@

[System.IO.File]::WriteAllText($rbFile, $content, $utf8NoBom)
Write-Host "Created: $rbFile"
