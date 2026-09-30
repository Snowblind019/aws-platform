# Decisions

The conventions every stack in this repo follows, then a log of each time I chose between two ways of doing something: what I picked, what I passed on, and why. New entries go at the bottom of the current project's table as the choices are made.

## Conventions

| Item | Value | Notes |
|---|---|---|
| Primary region | `us-west-2` | Same prices as us-east-1 for everything in this plan. Identity Center lives here too |
| Second region | `us-east-1` | Needed for some global-service endpoints anyway, and becomes the DR region in project 10 |
| OU | `Workloads` | SCPs attach here, not at the root |
| Member account | `lab` | Every project deploys here. The management account holds only org-level resources |
| Member account email | Plus-address of the management account email | Every AWS account needs a unique email. The actual address stays out of the repo |
| State bucket | `<prefix>-tfstate-<account-id>` | Bucket names are global, so the account ID keeps it unique. The real name lives only in the gitignored `backend.hcl` |
| State keys | `aws-platform/<stack>/terraform.tfstate` | One state file per stack |
| CLI profiles | `mgmt-admin`, `lab-admin`, `lab-readonly` | One per Identity Center permission set |
| Tag keys | `Project`, `ManagedBy`, `Owner`, `Ephemeral` | Exact capitalization matters for cost reports |
| Tag values | `Project` = stack name, `ManagedBy` = `terraform`, `Owner` = `Snowblind019`, `Ephemeral` = `true` or `false` | `Ephemeral=true` marks anything that should be torn down after a session |
| Local-only files | `backend.hcl`, `terraform.tfvars` | Gitignored. Committed `.example` versions show the structure |
| Screenshots | `docs/<project>/img/sNN-short-name.png` | Numbered in build order |
| Diagrams | `docs/<project>/img/dN-short-name.png` | Exported PNG or SVG, never a share link |
| Redaction | Email addresses, phone numbers, the access portal URL, account IDs | AWS doesn't treat account IDs as secret, but the code keeps them out, so screenshots, issues, and commit messages do too |
| Git identity | GitHub noreply email | Keeps my real address out of public commit history |
| Commit messages | Short and plain, with the issue number: `Add tags module (#4)` | The last commit of a phase adds a `Closes #N` line |
| Bug issues | `Bug: <what broke, a few words>` | `bug` label, set to the project's milestone |

## Log

### Project 1: AWS Foundation

| Date | Decision | Instead of | Why |
|---|---|---|---|
| 09-25-2026 | One repo, `aws-platform`, for all ten projects, with each project's docs in `docs/<project>/` | A repo per project | The stacks share the tags module, the backend config, and the foundation outputs. One repo keeps the code, docs, and history together. App code for project 4 still gets its own repo |
| 09-25-2026 | A shared foundation plus stacks that can each be applied and destroyed on their own | One monolithic project, or ten unrelated ones | Keeps spend down. Each project gets built, captured, and torn down, and the persistent layer stays up for under $1 a month |
| 09-25-2026 | Dependencies point one way: a later stack can read an earlier stack's outputs, never the reverse | Stacks reading from each other freely | An earlier stack never depends on a later one, so any project can be torn down without breaking the ones it builds on |
| 09-25-2026 | Three stacks split by account: `bootstrap` and `foundation` in `lab`, `org` in the management account | One `foundation` stack with aliased providers pointing at both accounts | One stack, one account. Each plan runs against a single account, and the management account never shares a plan with `lab` |
| 09-25-2026 | `bootstrap` holds only the state bucket | Putting the GitHub OIDC provider in `bootstrap` too | Bootstrap is the one stack that has to start on local state, so it holds the minimum needed to have a backend. The OIDC provider goes in `foundation` |
| 09-25-2026 | Identity Center set up by hand in project 1, then imported into Terraform and scoped down in project 5 | Codifying it now | Human access has to exist before Terraform can run, and turning AdministratorAccess into scoped permission sets is the work project 5 is for |
| 09-25-2026 | Project 1 ships a read-only ephemeral check. The destroy workflow waits for project 3 | A GitHub destroy workflow now | A workflow that can destroy stacks needs a role that can delete almost anything, and designing that role properly is project 3's job. The check still proves the OIDC trust works, with read-only access |
| 09-25-2026 | No customer managed KMS key yet | Creating the shared key in project 1 | Nothing in project 1 needs one. It goes into `foundation` when the first stack does |
| 09-25-2026 | The organization CloudTrail trail starts in project 1 | Adding it later with the posture work | Project 5 generates least-privilege policies from CloudTrail history, so the earlier it starts recording, the more history there is to work with |
| 09-25-2026 | AWS Config stays off until project 8 | Turning it on with the foundation | It would be project 1's only real meter, and nothing uses it before the posture project |
| 09-25-2026 | Commit `.terraform.lock.hcl` | Gitignoring it | It pins the provider versions and hashes, so the pipeline in project 3 runs the exact provider build I tested with |
| 09-25-2026 | One milestone per project, one issue per phase, and a bug issue for anything that breaks | One issue per step, or a GitHub Projects board | One issue per step would be 60+ issues for project 1 alone. A board for one person is overhead, and the milestone already shows progress |
| 09-25-2026 | No separate repo for progress notes | A journal repo next to this one | Commit history, the roadmap, the milestones, each project's README, and this log already record progress |
| 09-25-2026 | A dedicated SSH key for the work machine | Reusing an existing key | If that machine gets reimaged or I stop using it, deleting that one key on GitHub cuts it off without touching anything else |
| 09-26-2026 | The organization and `lab` account created by hand in the console, then imported into Terraform in Phase 4 with `prevent_destroy` | Creating them with Terraform | Creating and closing accounts are one-way doors. A closed account sits in a post-closure period and the org limits how many accounts can be closed, so an account should never be anywhere near a `terraform destroy`. Importing lets the code describe them without being able to delete them |
| 09-26-2026 | Organization with all features enabled | Consolidated billing only | Billing-only mode can't use SCPs, tag policies, or trusted access for other services |
| 09-26-2026 | One `Workloads` OU holding `lab`, with the management account left at the root | Attaching the SCPs at the root | One OU is enough for one member account. With the SCPs on the OU, they only reach accounts I deliberately put in `Workloads`. They never apply to the management account either way |
| 09-26-2026 | Member account emails are plus-addresses of the management account email | A separate mailbox for each account | Every AWS account needs a unique email. Plus-addressing gives each account its own address while everything lands in one inbox |
| 09-26-2026 | Centralized root access turned on before creating `lab` | Creating `lab` first and removing its root credentials afterward | With it on, new member accounts are created with no root credentials, so `lab` never had a root password or keys to lock down. Root-only tasks go through short-lived privileged sessions from the management account |
| 09-26-2026 | Keep the default `OrganizationAccountAccessRole` in `lab` | Relying on Identity Center as the only way in | It's the break-glass path into `lab` if Identity Center ever breaks |
| 09-26-2026 | Leave `FullAWSAccess` attached everywhere and write SCPs as deny statements on top of it | Detaching it and allow-listing services instead | Detaching it without a replacement allow denies everything. Each SCP in this project blocks one specific thing, so deny statements on top of the full allow are all that's needed |
| 09-26-2026 | Human access through IAM Identity Center, set up as the organization instance in `us-west-2` | IAM users with passwords and access keys | One sign-in with MFA gives short-lived credentials for both accounts, with nothing long-lived to leak. The organization instance is the kind that can assign access to AWS accounts, and the region can't be moved later without deleting the instance and redoing every assignment |
| 09-26-2026 | MFA required at every sign-in, with authenticator apps and security keys allowed, and registration forced at first sign-in | Context-aware MFA that only prompts on a new device or IP | Most sessions behind it end up with admin rights, and I sign in from a work machine, so a remembered device shouldn't be enough to skip the prompt |
| 09-26-2026 | Three permission sets: OrgAdmin on the management account (1 hour), LabAdmin on `lab` (4 hours), LabReadOnly on `lab` (8 hours) | One admin permission set assigned to both accounts | The management account only gets touched for org-level work, so it gets its own set with the shortest session. LabAdmin covers a Terraform session. LabReadOnly lasts a whole shift for looking around without write access |
| 09-26-2026 | Permission sets assigned to the `platform-admins` group | Assigning them to my user directly | Project 5 changes access by changing group assignments, so nothing has to be rewired per user |
| 09-26-2026 | One SSO session shared by the three CLI profiles | A separate session per profile | One `aws sso login` covers all three profiles |
| 09-26-2026 | Old IAM user's access keys deleted, and no active access keys in either account | Keeping the keys around as a fallback | Every CLI call now uses short-lived SSO credentials. The fallback paths are the management account's root user and `OrganizationAccountAccessRole`, neither of which needs a stored key |
| 09-26-2026 | `aws sso logout` at the end of every shift | Leaving the session cached until it expires | SSO tokens are cached under `~/.aws/sso/cache` on a work machine, and logging out clears them |
| 09-28-2026 | Tags come from a shared `modules/tags` module, passed into each stack's provider `default_tags` | A `locals` block copied into every stack | The four tag keys are spelled in one place, so a typo like `Ephemral` can't slip into one stack and quietly break the cost reports and the ephemeral check. Validation on the stack name keeps `Project` values to lowercase letters, digits, and hyphens |
| 09-28-2026 | The tags module's `ephemeral` input has no default | Defaulting it to `false` | Every stack has to decide on purpose whether it's meant to be torn down, instead of silently getting one answer |
| 09-30-2026 | State bucket named `<prefix>-tfstate-<account-id>`, with the account ID read at plan time by the `aws_caller_identity` data source | Typing the account ID into the code | Bucket names are global, so the account ID keeps it unique, and reading it at plan time keeps it out of the repo |
| 09-30-2026 | SSE-S3 for the state bucket | SSE-KMS with a customer managed key | No customer managed key exists yet and nothing in project 1 needs one. Revisit when `foundation` gets its first key |
| 09-30-2026 | Encryption and object ownership declared in code even though they're already S3 defaults on new buckets | Relying on the defaults | The code shows what the bucket is supposed to be, scanners see it declared, and a change to an AWS default wouldn't change this bucket |
| 09-30-2026 | TLS-only bucket policy built with the `aws_iam_policy_document` data source | A JSON heredoc string | Terraform checks the structure at plan time, and it reads like the rest of the code instead of a block of raw JSON |
| 09-30-2026 | Lifecycle on the state bucket: noncurrent versions expire after 30 days with the newest 5 always kept, and incomplete uploads are aborted after 7 days | Versioning with no lifecycle | Versioning without a lifecycle grows forever. Keeping 5 old versions means there's always something to roll back to |
| 09-30-2026 | State locking with the native S3 lockfile (`use_lockfile = true`) | A DynamoDB lock table | DynamoDB locking is deprecated in Terraform. Native locking keeps the lock next to the state using an S3 conditional write, and it's one less resource to manage |
| 09-30-2026 | Partial backend config: a shared `backend.hcl` (gitignored) at the repo root, and only the `key` in each stack's `backend` block | A full backend block in every stack | Keeps the bucket name, which contains the account ID, out of the public repo. Backend blocks can't use variables, so a file passed in at `terraform init` is the standard way to share the settings |
| 09-30-2026 | Bootstrap's own state moved into the bucket it creates | Keeping bootstrap's state as a local file | A local file would only exist on one work machine. In the bucket it gets the same versioning, encryption, and locking as every other stack |
| 09-30-2026 | `terraform force-unlock` only after confirming nothing else is running | Force-unlocking whenever a lock error shows up | A lock left behind by a crash blocks every run, but unlocking while another run is really writing state is how state gets corrupted |
| 09-30-2026 | Modules never configure providers. Only stacks have `provider` blocks. Changed after review: the tags module had a leftover `provider` and `required_providers` block, now removed | Leaving a provider block in the module | A module with its own provider block can't be used with `count`, `for_each`, or `depends_on`, and it hardcoded a region into something every stack shares. The tags module creates nothing, so it needs no provider at all |
| 09-30-2026 | `required_version = "~> 1.10"` (any 1.x from 1.10) and the AWS provider at `~> 6.0`. Changed after review from `~> 1.16.0` | Pinning Terraform to one minor version | 1.10 is the real floor, since native S3 locking needs it. Pinning a minor version would break the stack on the next Terraform release, and the lock file already pins the exact provider build |