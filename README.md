# aws-platform

![Cloud](https://img.shields.io/badge/Cloud-AWS-FF9900)
![IaC](https://img.shields.io/badge/IaC-Terraform-7B42BC)
![IaC](https://img.shields.io/badge/IaC-CloudFormation-FF4F8B)
![CI](https://img.shields.io/badge/CI-GitHub%20Actions-2088FF)
![Method](https://img.shields.io/badge/Method-Build%2C%20destroy%2C%20rebuild-4479A1)


A multi-account AWS platform I'm building with Terraform and CloudFormation, one project at a time.It starts with a foundation layer: an AWS Organization with a management account and a `lab` account, human access through IAM Identity Center, a shared S3 state backend, org-wide guardrails, and GitHub OIDC trust. Each project after that adds its own stack on top. Every stack has its own state file and can be applied and destroyed on its own, so a project gets built, documented, and torn down, and can be rebuilt from code when a later project needs it.

## What's built

- **Project 1: [AWS foundation](docs/foundation/README.md).** The organization and its accounts, Identity Center access, a state backend with locking, SCPs, an organization CloudTrail trail, budgets and tagging, and GitHub OIDC trust. Its phase issues and bug issues are in the [Project 1 milestone](https://github.com/Snowblind019/aws-platform/milestone/1).

Now building: [project 2, a multi-VPC network](docs/network/README.md), in CloudFormation. Progress is in the [Project 2 milestone](https://github.com/Snowblind019/aws-platform/milestone/2).

The conventions every stack follows, and every choice made along the way, are in [docs/decisions.md](docs/decisions.md).

<details>
<summary><b>How the work is tracked</b></summary>

Each project gets a GitHub milestone with one issue per phase of the build. Anything that breaks and takes real work to figure out gets its own bug issue, with the error, the cause, and the fix, and is closed by the commit that fixed it. Those issues become the What broke table in each project's README.

</details>

## Stacks

| Stack | Account | Purpose | Lifecycle | Status |
|---|---|---|---|---|
| [`bootstrap`](bootstrap/) | lab | The S3 bucket every stack keeps its state in | Persistent | Applied |
| [`org`](stacks/org/) | management | The organization and the `lab` account, SCPs, the organization CloudTrail trail, budgets, anomaly detection, and cost allocation tags | Persistent | Applied |
| [`foundation`](stacks/foundation/) | lab | Account defaults, the GitHub OIDC provider, and the read-only role the ephemeral check uses | Persistent | Applied |
| [`modules/tags`](modules/tags/) | n/a | The four standard tags every stack passes into `default_tags` | n/a | In use |

Persistent stacks stay up between projects. Ephemeral stacks, starting with project 2, get applied for a work session and destroyed after it. The [ephemeral check](.github/workflows/ephemeral-check.yml) runs every day and fails if anything tagged `Ephemeral=true`, or any NAT gateway or Elastic IP, is still running in `lab`.

## Dependencies point one way

A stack can read an earlier stack's outputs through `terraform_remote_state`. An earlier stack never reads a later one.

```
org  -->  foundation  -->  every later stack
```

`bootstrap` sits under all of them as the state backend. Later stacks read `foundation` only, never `org`, and only through its outputs. If a later stack needs something that isn't there, it becomes a new output. So any project's stacks can be destroyed without breaking the layer under them, and everything one layer shares with the next is in one `outputs.tf`.

## Building it from zero

<details>
<summary><b>Steps, in order</b></summary>

Part of this is console work on purpose. The organization and its accounts are one-way doors, and human access has to exist before Terraform can run. Everything after that is code.

**Console, in the management account**

1. Root user: MFA with two devices, no access keys, and alternate contacts set. Turn on IAM access to billing information in the account settings.
2. Create the organization with all features. Then turn on centralized root access in IAM: root credentials management and privileged root actions.
3. Create the `Workloads` OU. Create `lab` from Organizations with a plus-address email and the default `OrganizationAccountAccessRole`, and move it into `Workloads`. Because centralized root access is already on, `lab` is created with no root credentials.
4. Enable the SCP policy type and leave `FullAWSAccess` attached.
5. Enable IAM Identity Center as the organization instance in `us-west-2`. Require MFA at every sign-in, create the `platform-admins` group with your user in it, and create the `OrgAdmin`, `LabAdmin`, and `LabReadOnly` permission sets, assigned to the group.

**Workstation**

6. `aws configure sso`: one SSO session with three profiles, `mgmt-admin`, `lab-admin`, and `lab-readonly`. Then `aws sso login`.

**Terraform**, with `AWS_PROFILE=lab-admin` throughout

7. `bootstrap`, on local state first: rename `backend.tf` to `backend.tf.off`, then `terraform init` and `terraform apply`. Copy `backend.hcl.example` to `backend.hcl` at the repo root and fill in the bucket name from the output. Rename `backend.tf.off` back and run `terraform init -migrate-state -backend-config=../backend.hcl`. Once a plan shows no changes, delete the local state files.
8. `org`: copy `terraform.tfvars.example` to `terraform.tfvars` and fill in both emails. Add `import` blocks for the organization, the `Workloads` OU, and `lab`, with their IDs from `aws organizations describe-organization`, `list-roots`, `list-organizational-units-for-parent`, and `list-accounts` run as `mgmt-admin`. Run `terraform init -backend-config=../../backend.hcl` and plan until it shows the three imports and nothing being replaced or destroyed. Apply, then delete the import blocks. The provider reaches the management account through `mgmt-admin` on its own. If a cost allocation tag fails because the key doesn't exist yet, billing hasn't seen the tags on the `bootstrap` bucket, which can take up to a day. Apply again then.
9. `foundation`: `terraform init -backend-config=../../backend.hcl`, then apply. For a repo other than `Snowblind019/aws-platform`, first change `github_sub_prefix` in `github-oidc.tf` to that repo's owner and repo IDs, from `https://api.github.com/repos/<owner>/<repo>`.

**GitHub**

10. Add the repository secret `AWS_EPHEMERAL_CHECK_ROLE_ARN`, set to the output of `aws iam get-role --role-name gha-ephemeral-check --query Role.Arn --output text`. Add the repository variables `AWS_REGION` set to `us-west-2` and `AWS_ALLOWED_REGIONS` set to `us-west-2 us-east-1`. Run the ephemeral check from the Actions tab. It should go green.

</details>

## Tested with

| Tool | Version |
|---|---|
| Terraform | v1.16.4 |
| AWS provider | 6.69.1 |
| AWS CLI | 2.37.4 |

Each stack's `.terraform.lock.hcl` pins the exact provider build.

## Standing cost

The persistent layer costs about $0.15 a month, almost all of it S3 for the CloudTrail log bucket. The breakdown is in [project 1's cost section](docs/foundation/README.md#cost).