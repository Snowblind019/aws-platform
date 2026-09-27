# Project 1: AWS Foundation

![Status](https://img.shields.io/badge/Status-In%20progress-yellow)
![Milestone](https://img.shields.io/github/milestones/progress/Snowblind019/aws-platform/1?label=Milestone)
![Lifecycle](https://img.shields.io/badge/Lifecycle-Persistent-blue)
![AWS](https://img.shields.io/badge/AWS-Organizations%20%7C%20Identity%20Center%20%7C%20S3%20%7C%20CloudTrail-FF9900)

**Status:** In progress\
**Started:** 09-25-2026\
**Finished:**

Sections fill in as each phase of the build closes. Progress is tracked in the [Project 1 milestone](https://github.com/Snowblind019/aws-platform/milestone/1).

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

The organization runs with all features enabled, since consolidated-billing-only mode can't use SCPs, tag policies, or trusted access for other services. It has two accounts. The management account holds only org-level resources, and `lab` is where every project deploys. `lab` sits in a `Workloads` OU under the root, and the guardrail SCPs attach to that OU rather than the root. Member account emails are plus-addresses of the management account's email.

The SCP policy type is enabled. AWS attached `FullAWSAccess` to the root, the OU, and both accounts, and it stays attached. The SCPs added later are deny statements on top of it, and detaching it would deny everything.

![Organization tree](img/s02-org-tree.png)

Centralized root access is on, with both of its features: root credentials management and privileged root actions in member accounts. It was turned on before `lab` was created, so `lab` came with no root credentials at all, no password and no access keys. When a task needs root, like unlocking an S3 bucket whose policy denies everyone, the management account opens a short-lived root session into `lab` instead of anyone signing in as its root user.

Once these features are on, the Root access management page in the console only lists the accounts, so the feature check below comes from the CLI.

![Centralized root access enabled](img/s03-root-access-features.png)

![Lab account has no root credentials](img/s04-lab-root-credentials.png)

### Identity Center

People get into both accounts through IAM Identity Center, set up as the organization instance in `us-west-2`. MFA is required at every sign-in, not only when the device or location changes. Authenticator apps and security keys are both allowed, and anyone without a registered device has to register one before they can get in.

![Identity Center MFA settings](img/s05-identity-center-mfa.png)

Access is assigned to a `platform-admins` group, not to my user directly, through three permission sets:

| Permission set | Policy | Session | Account | Used for |
|---|---|---|---|---|
| OrgAdmin | AdministratorAccess | 1 hour | Management | Org-level work only, the `org` stack |
| LabAdmin | AdministratorAccess | 4 hours | `lab` | Terraform work on every other stack |
| LabReadOnly | ReadOnlyAccess | 8 hours | `lab` | Looking around without write access |

AdministratorAccess is on purpose for now. Least privilege needs something built to be least-privileged against, so project 5 replaces OrgAdmin and LabAdmin with scoped custom permission sets and brings all of this into Terraform. Because access hangs off the group, that change is a matter of changing group assignments, with nothing to rewire per user.

![Permission sets assigned to platform-admins in lab](img/s06a-lab-assignments.png)

![Permission set assigned to platform-admins in the management account](img/s06b-management-assignments.png)

On the command line, one SSO session feeds three profiles, `mgmt-admin`, `lab-admin`, and `lab-readonly`, one per permission set. A single `aws sso login` covers all three, and each profile lands in the right account with the right permission set:

![SSO profiles verified](img/s07-sso-caller-identity.png)

On the work machine, the session gets closed with `aws sso logout` at the end of each shift, which clears the cached tokens.

If Identity Center ever breaks, `lab` keeps the default `OrganizationAccountAccessRole`, which the management account can assume. It's the break-glass way back into `lab`.

### No long-lived keys

Every CLI call now uses short-lived credentials from the SSO session, so the old IAM user's access keys were deleted from the management account and from `~/.aws/credentials`. The credential report in both accounts shows no active access keys, root users included.

![No active access keys in either account](img/s08a-credential-report.png)

![Old IAM user with its access keys deleted](img/s08b-old-user-no-keys.png)

### Bringing the org under Terraform

The organization and `lab` were created by hand in the console, not with Terraform. Creating and closing accounts are one-way doors: a closed account sits in a post-closure period, and an organization can only close so many, so an account should never be anywhere near a `terraform destroy`.

<!-- Phase 4: the import, and prevent_destroy so the code describes the org and account without being able to delete them. -->

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

Before any project 1 work, the account's month-to-date cost was $0.00, and all of August 2026 came to $0.02. That's the baseline the rest of this project is measured against.

![Billing baseline before project 1](img/s01-billing-baseline.png)

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
| Baseline before the project | $0.00 month to date on 09-26-2026 ($0.02 for all of August 2026) |
| Standing monthly cost | |
| Actual spend during the project | |

## Tested with

| Tool | Version |
|---|---|
| Terraform | v1.15.9 |
| AWS provider | |
| AWS CLI | 2.32.19 |