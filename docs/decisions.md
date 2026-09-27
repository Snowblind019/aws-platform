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