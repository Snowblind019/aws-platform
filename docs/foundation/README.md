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

Every stack keeps its state in one S3 bucket in `lab`, created by the `bootstrap` stack. Bootstrap is the one stack that can't start with a remote backend, because the bucket it would point at is the thing it creates. So it was applied once with local state, and then its own state was moved into the bucket it had just made.

The bucket is named `<prefix>-tfstate-<account-id>`. Bucket names are global, so the account ID keeps it unique, and it's read at plan time with the `aws_caller_identity` data source instead of being typed into the code. The bucket's settings:

| Setting | Value | Why |
|---|---|---|
| Versioning | Enabled | Every change to a state file keeps the old copy, so a bad write can be rolled back |
| Encryption | SSE-S3 | State can hold secrets in plain text. New buckets are encrypted by default, but declaring it shows the intent in code. There's no customer managed key yet |
| Public access block | All four settings on | The bucket can't be made public by accident |
| Object ownership | Bucket owner enforced | ACLs are off, so access comes only from IAM and the bucket policy |
| Bucket policy | Deny every request where `aws:SecureTransport` is false | Nobody can read or write state over plain HTTP |
| Lifecycle | Old versions expire after 30 days with the newest 5 always kept. Incomplete uploads are aborted after 7 days | Versioning with no lifecycle grows forever |
| `prevent_destroy` | On | Terraform refuses any plan that would delete the bucket |

Tags come from the shared `modules/tags` module, passed into the provider's `default_tags`, so every resource in the stack carries `Project`, `ManagedBy`, `Owner`, and `Ephemeral` without tagging each one by hand. The module checks that the stack name only uses lowercase letters, digits, and hyphens, and it has no default for `Ephemeral`, so every stack has to say on purpose whether it gets torn down.

![Bootstrap applied with local state](img/s09-bootstrap-local-apply.png)

### Moving the state into the bucket

Stacks use partial backend configuration. The settings every stack shares (the bucket, its region, locking, and encryption) live in a gitignored `backend.hcl` at the repo root, and a committed `backend.hcl.example` shows its shape. Each stack's `backend "s3"` block holds only its own `key`, like `aws-platform/bootstrap/terraform.tfstate`. That keeps the bucket name, and the account ID in it, out of the repo. Backend blocks can't read variables anyway, so a file passed in at `terraform init` is how the settings get shared.

Bootstrap's state moved over with `terraform init -migrate-state -backend-config=../backend.hcl`. A plan afterward showed no changes, which proved Terraform was reading state from S3 and that it matched what was built. Only then were the local state files deleted.

![State migrated to S3](img/s10-migrate-state.png)

![State object with versions](img/s11-state-object-versions.png)

### Locking

Locking uses Terraform's native S3 lockfile (`use_lockfile = true`) instead of a DynamoDB table, which Terraform has deprecated for this. While a plan or apply runs, Terraform writes a `.tflock` object next to the state file, using a conditional write that only succeeds if that object doesn't already exist. When a second run tries, S3 rejects its write with a 412 PreconditionFailed, and Terraform reports it as a lock error.

To test it, one terminal ran `terraform apply -replace=aws_s3_bucket_ownership_controls.state` and left it sitting at the approval prompt. A plain `terraform apply` wouldn't have worked: with nothing to change, it prints No changes and exits without a prompt, so nothing holds the lock. `-replace` forces a plan with one change in it, and the ownership controls are harmless to recreate if the plan gets approved by mistake. While the first terminal waited, `terraform plan` in a second terminal failed with the lock error, showing the lock ID, the operation holding it, and when it was taken.

![State lock conflict](img/s12-lock-error.png)

The lock object sat next to the state file for as long as the first terminal waited. Its timestamp, 11:11:14 local time, is one second after the lock's created time in the error, 18:11:13 UTC. Answering no in the first terminal released the lock, and the object was gone on the next refresh.

![Lock file in S3](img/s13-tflock-object.png)

Because the bucket is versioned, S3 doesn't really delete the lock object when a run finishes. Each run leaves a small noncurrent version and a delete marker behind, and the lifecycle rule keeps those from piling up along with the old state versions.

If a crash ever leaves a lock behind, `terraform force-unlock <LOCK_ID>` removes it, but only after confirming nothing else is actually running. Unlocking while another run is writing state is how state gets corrupted.

### prevent_destroy

`terraform plan -destroy` in bootstrap lists all 7 resources for deletion, then stops with "Instance cannot be destroyed" pointing at the bucket. `prevent_destroy` is checked while the plan is built, so the whole plan fails and none of it can be applied, including the settings resources that aren't protected themselves. Deleting this bucket on purpose would mean moving every stack's state out of it first, removing `prevent_destroy`, and emptying every version before a destroy could run.

![prevent_destroy blocking destroy](img/s14-prevent-destroy.png)

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
| Terraform | v1.16.4 |
| AWS provider | 6.66.0 |
| AWS CLI | 2.37.4 |