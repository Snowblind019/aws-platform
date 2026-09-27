# aws-platform

![Status](https://img.shields.io/badge/Status-Project%201%20of%2010%20in%20progress-yellow)
![Cloud](https://img.shields.io/badge/Cloud-AWS-FF9900)
![IaC](https://img.shields.io/badge/IaC-Terraform-7B42BC)
![CI](https://img.shields.io/badge/CI-GitHub%20Actions-2088FF)
![Method](https://img.shields.io/badge/Method-Build%2C%20destroy%2C%20rebuild-4479A1)

A multi-account AWS platform I'm building with Terraform, one project at a time. It starts with a foundation layer: an AWS Organization with a management account and a `lab` account, human access through IAM Identity Center, a shared S3 state backend, org-wide guardrails, and GitHub OIDC trust. Each project after that adds its own stack on top. Every stack has its own state file and can be applied and destroyed on its own, so a project gets built, documented, and torn down, and can be rebuilt from code when a later project needs it.

## Roadmap

| # | Project | What it adds | Status |
|---|---|---|---|
| 1 | [AWS foundation](docs/foundation/README.md) | Organization and accounts, Identity Center access, state backend with locking, SCPs, org CloudTrail, budgets and tagging, GitHub OIDC trust | In progress |
| 2 | Multi-VPC network | Transit Gateway, Network Firewall, centralized egress | Planned |
| 3 | CI/CD pipeline | GitHub Actions deploying the stacks through OIDC federation | Planned |
| 4 | Container service | A containerized service on ECS Fargate, shipped through the pipeline | Planned |
| 5 | IAM depth | Least-privilege roles and permission sets for everything built so far | Planned |
| 6 | Secrets management | Secrets Manager and Parameter Store with rotation, wired into the Fargate tasks | Planned |
| 7 | Observability and auto-remediation | Monitoring and alerting, with remediation Lambdas | Planned |
| 8 | Posture and compliance | Security Hub, GuardDuty, Config, and Prowler scans of what projects 1 to 7 built | Planned |
| 9 | Kubernetes | k3s at home, then EKS | Planned |
| 10 | Reliability and DR | Snapshot and failover automation, and a failover drill to a second region | Planned |

Progress on the current project: [Project 1 milestone](https://github.com/Snowblind019/aws-platform/milestone/1)

The conventions every stack follows, and every choice made along the way, are in [docs/decisions.md](docs/decisions.md).

<details>
<summary><b>How the work is tracked</b></summary>

Each project gets a GitHub milestone with one issue per phase of the build. Anything that breaks and takes real work to figure out gets its own bug issue, with the error, the cause, and the fix, and is closed by the commit that fixed it. Those issues become the What broke table in each project's README.

</details>

<!-- Phase 8: stack table (name, account, purpose, persistent or ephemeral, status) -->
<!-- Phase 8: the one-direction dependency rule -->
<!-- Phase 8: how to stand it up from zero, in order (good fit for a collapsed <details> block) -->
<!-- Phase 8: tested-with versions and standing monthly cost -->