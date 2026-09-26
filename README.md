# Project 1: AWS Foundation

**Status:** In progress
**Started:** 09-25-2026
**Finished:**

<!-- One-line summary once built: what this layer gives every other stack. -->

## Overview

<!-- One paragraph: what the foundation is, why it exists, and what later stacks get from it. -->

## Architecture

<!-- D2 page 1: ![Account and access diagram](img/d2-account-access.png) -->
<!-- D2 page 2: ![Credential flow](img/d2-credential-flow.png) -->

## Stacks

| Stack | Account | What it holds | Lifecycle |
|---|---|---|---|
| `bootstrap` | lab | | Persistent |
| `org` | management | | Persistent |
| `foundation` | lab | | Persistent |
| `modules/tags` | n/a | | n/a |

## Accounts and access

<!-- Org layout, the Workloads OU, centralized root access, Identity Center, permission sets, and why no access keys exist. -->

<!-- S02: ![Organization tree](img/s02-org-tree.png) -->
<!-- S03: ![Centralized root access enabled](img/s03-root-access-features.png) -->
<!-- S04: ![Lab account has no root credentials](img/s04-lab-root-credentials.png) -->
<!-- S05: ![Identity Center MFA settings](img/s05-identity-center-mfa.png) -->
<!-- S06: ![Access portal](img/s06-access-portal.png) -->
<!-- S07: ![SSO profiles verified](img/s07-sso-caller-identity.png) -->
<!-- S08: ![No active access keys](img/s08-credential-report.png) -->

### Bringing the org under Terraform

<!-- Why the org and lab account were created by hand, then imported with prevent_destroy. -->

<!-- S15: ![Import plan](img/s15-org-import-plan.png) -->

## State backend

<!-- Bucket settings, native S3 locking, the local-to-remote migration, and the lock and prevent_destroy tests. -->

<!-- S09: ![Bootstrap applied with local state](img/s09-bootstrap-local-apply.png) -->
<!-- S10: ![State migrated to S3](img/s10-migrate-state.png) -->
<!-- S11: ![State object with versions](img/s11-state-object-versions.png) -->
<!-- S12: ![State lock conflict](img/s12-lock-error.png) -->
<!-- S13: ![Lock file in S3](img/s13-tflock-object.png) -->
<!-- S14: ![prevent_destroy blocking destroy](img/s14-prevent-destroy.png) -->

## Guardrails

### Service control policies

<!-- The three SCPs, what each one blocks, and where they attach. -->

<!-- S16: ![Region lock denial](img/s16-region-lock-deny.png) -->
<!-- S17: ![Access key creation denied](img/s17-access-key-deny.png) -->
<!-- S18: ![SCP targets](img/s18-scp-targets.png) -->

### Organization CloudTrail

<!-- Trail settings, where logs land, and why it started in project 1. -->

<!-- S19: ![Organization trail details](img/s19-org-trail-details.png) -->
<!-- S20: ![Lab account logs in the trail bucket](img/s20-trail-bucket-prefix.png) -->

### Account defaults

<!-- S3 account public access block, EBS encryption by default, IMDSv2 by default, and which regions they cover. -->

## Cost controls

<!-- Budgets, anomaly detection, and cost allocation tags. -->

<!-- S01: ![Billing baseline before project 1](img/s01-billing-baseline.png) -->
<!-- S21: ![Budgets](img/s21-budgets.png) -->
<!-- S22: ![Alert email](img/s22-alert-email.png) -->
<!-- S23: ![Cost allocation tags active](img/s23-cost-allocation-tags.png) -->
<!-- S24: ![Anomaly monitor](img/s24-anomaly-monitor.png) -->
<!-- S34: ![Cost Explorer by Project tag](img/s34-cost-explorer-project.png) -->

## GitHub OIDC and the ephemeral check

<!-- The OIDC provider, the read-only role and its trust conditions, and what the scheduled check looks for. -->

<!-- S25: ![GitHub OIDC provider](img/s25-oidc-provider.png) -->
<!-- S26: ![Role trust policy](img/s26-oidc-trust-policy.png) -->
<!-- S27: ![Check passing](img/s27-check-green.png) -->
<!-- S28: ![Check failing on an ephemeral resource](img/s28-check-red.png) -->
<!-- S29: ![Failure email](img/s29-check-email.png) -->
<!-- S30: ![Assume role denied from a branch](img/s30-check-denied.png) -->

## Drift and rebuild

<!-- Clean plans, the drift test, and the foundation destroy and re-apply. -->

<!-- S31: ![Clean plans](img/s31-clean-plans.png) -->
<!-- S32: ![Drift detected](img/s32-drift-plan.png) -->
<!-- S33: ![Foundation rebuilt](img/s33-foundation-rebuild.png) -->

## Outputs

| Output | Description | Used by |
|---|---|---|
| | | |

## Testing the guardrails

<!-- How to reproduce each denial and check yourself, and what the expected result looks like. -->

## Decisions

<!-- The main calls made in this project, linking to entries in ../decisions.md. -->

## What broke

| Problem | Cause | Fix |
|---|---|---|
| | | |

## Known gaps

<!-- What a production setup would do differently, and which later project closes each one. -->

## Cost

| Item | Amount |
|---|---|
| Standing monthly cost | |
| Actual spend during the project | |

## Tested with

| Tool | Version |
|---|---|
| Terraform | |
| AWS provider | |
| AWS CLI | |