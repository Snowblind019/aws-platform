# Project 2: Multi-VPC Network

![Status](https://img.shields.io/badge/Status-In%20progress-yellow)
![Milestone](https://img.shields.io/github/milestones/progress/Snowblind019/aws-platform/2?label=Milestone)
![Lifecycle](https://img.shields.io/badge/Lifecycle-Ephemeral-orange)
![IaC](https://img.shields.io/badge/IaC-CloudFormation-FF4F8B)
![AWS](https://img.shields.io/badge/AWS-VPC%20%7C%20Transit%20Gateway%20%7C%20Network%20Firewall%20%7C%20Route%2053-FF9900)

**Status:** In progress\
**Started:** 10-29-2026\
**Finished:**

Sections fill in as each phase of the build closes. Progress is tracked in the [Project 2 milestone](https://github.com/Snowblind019/aws-platform/milestone/2).

<!-- One-line summary once built: what this network gives the stacks after it. -->

## Overview

<!-- One paragraph: hub and spoke in CloudFormation, a fully private shared services VPC, inspection and egress in one VPC, and what later stacks get from it. -->

## Architecture

<!-- D2 page 1: ![Network topology](img/d2-network-topology.png) -->
<!-- D2 page 2: ![Packet walk](img/d2-packet-walk.png) -->
<!-- D2 page 3: ![Stack map](img/d2-stack-map.png) -->

## Stacks

| Stack | Account | What it holds | Lifecycle |
|---|---|---|---|
| `cfn-bootstrap` | lab | | Persistent |
| `cfn-drills` | lab | | Ephemeral |
| `network` | lab | | Ephemeral |
| `network-test` | lab | | Ephemeral |
| `org-stacksets` | management | | Persistent |
| `spoke-vpc.yaml` | n/a | | n/a |

## Running it

### The session loop

### Parameters

### Cost

Before any project 2 work, October's bill so far was $0.16. That's the baseline this project's cost gets measured against.

![S01: Billing baseline](img/s01-billing-baseline.png)

<!-- ![S03: Budgets for project 2](img/s03-budgets-project-2.png) -->
<!-- ![S04: Ephemeral check with the new rows](img/s04-ephemeral-check-new-rows.png) -->

## CloudFormation setup

<!-- ![S05: Bootstrap change set](img/s05-bootstrap-change-set.png) -->
<!-- ![S06: Bootstrap outputs](img/s06-bootstrap-outputs.png) -->
<!-- ![S07: Termination protection](img/s07-termination-protection.png) -->
<!-- ![S08: Stack policy denial](img/s08-stack-policy-denied.png) -->
<!-- ![S09: cfn-guard](img/s09-cfn-guard.png) -->

## CloudFormation drills

| Drill | What broke | Status it left | How I found it | Way out |
|---|---|---|---|---|
| C1 | | | | |
| C2 | | | | |
| C3 | | | | |
| C4 | | | | |
| C5 | | | | |
| C6 | | | | |
| C7 | | | | |
| C8 | | | | |

<!-- ![S10a: Validation failure](img/s10a-validation-failure.png) -->
<!-- ![S10b: First failed event](img/s10b-first-failed-event.png) -->
<!-- ![S11: Fixed name and replacement](img/s11-fixed-name-replacement.png) -->
<!-- ![S12a: Drift detected](img/s12a-drift-detected.png) -->
<!-- ![S12b: Drift-aware change set](img/s12b-revert-drift-change-set.png) -->
<!-- ![S13a: UPDATE_ROLLBACK_FAILED](img/s13a-update-rollback-failed.png) -->
<!-- ![S13b: Continue rollback](img/s13b-continue-rollback.png) -->
<!-- ![S13c: Force rollback](img/s13c-force-rollback.png) -->
<!-- ![S14a: IaC generator](img/s14a-iac-generator.png) -->
<!-- ![S14b: Import in sync](img/s14b-import-in-sync.png) -->
<!-- ![S15a: Custom resource timeout](img/s15a-custom-resource-timeout.png) -->
<!-- ![S15b: Custom resource fixed](img/s15b-custom-resource-fixed.png) -->
<!-- ![S16: Rollback trigger](img/s16-rollback-trigger.png) -->
<!-- ![S17: Express mode timing](img/s17-express-mode-timing.png) -->

## Address plan

The default VPCs in `lab` were deleted in us-west-2 and us-east-1 before anything was built, so nothing can land in a VPC with a public route by mistake.

![S02a: No default VPC in us-west-2](img/s02a-default-vpc-deleted-usw2.png)

![S02b: No default VPC in us-east-1](img/s02b-default-vpc-deleted-use1.png)

## VPCs

<!-- ![S18: Network change set](img/s18-network-change-set.png) -->
<!-- ![S19: Inspection VPC resource map](img/s19-inspection-resource-map.png) -->
<!-- ![S20: Shared VPC resource map](img/s20-shared-resource-map.png) -->
<!-- ![S21: Empty default security group](img/s21-default-sg-empty.png) -->
<!-- ![S22: Ephemeral check red with the network up](img/s22-ephemeral-check-red-network-up.png) -->
<!-- ![S23: Network deleted](img/s23-network-delete.png) -->

## Transit Gateway

<!-- ![S24: spokes route table](img/s24-tgw-rt-spokes.png) -->
<!-- ![S25: inspection route table](img/s25-tgw-rt-inspection.png) -->
<!-- ![S26: Appliance mode](img/s26-appliance-mode.png) -->
<!-- ![S27: Shared has no default route](img/s27-shared-no-default-route.png) -->

## The fully private spoke

<!-- ![S28: Endpoints in shared](img/s28-shared-endpoints.png) -->
<!-- ![S29: ssm zone, shared only](img/s29-ssm-zone-shared-only.png) -->
<!-- ![S30: Both instances managed](img/s30-fleet-manager-both.png) -->
<!-- ![S33: Private VPC tests from shared](img/s33-shared-private-tests.png) -->
<!-- ![S35: Reachability Analyzer, shared has no way out](img/s35-reachability-shared-no-internet.png) -->

## Contract

| Export or parameter | What it is | Read by |
|---|---|---|

<!-- ![S37: Export refuses the delete](img/s37-export-blocks-delete.png) -->

## Network Firewall

<!-- ![S38: Firewall details](img/s38-firewall-details.png) -->
<!-- ![S39: TGW subnet routes through the firewall](img/s39-tgw-subnet-routes-firewall.png) -->
<!-- ![S40: Allowed and blocked egress](img/s40-egress-allow-and-block.png) -->
<!-- ![S41: Alert log for the blocked request](img/s41-alert-log-egress-drop.png) -->
<!-- ![S42a: East-west filtered](img/s42a-east-west-filtered.png) -->
<!-- ![S42b: Alert log naming the east-west rule](img/s42b-alert-log-east-west.png) -->
<!-- ![S43: Reachability Analyzer and firewall rules](img/s43-reachability-firewall-info.png) -->

## DNS

<!-- ![S44: Zone associations](img/s44-phz-associations.png) -->
<!-- ![S45: Resolving by name](img/s45-dns-by-name.png) -->
<!-- ![S46a: DNS Firewall NXDOMAIN](img/s46a-dns-firewall-nxdomain.png) -->
<!-- ![S46b: Query log showing the block](img/s46b-query-log-block.png) -->
<!-- ![S47: Layered controls](img/s47-layered-controls.png) -->

## VPC endpoints

<!-- ![S48a: app SSM traffic before](img/s48a-app-ssm-egress-before.png) -->
<!-- ![S48b: app S3 traffic before](img/s48b-app-s3-before.png) -->
<!-- ![S49: Zones on both spokes](img/s49-zones-both-spokes.png) -->
<!-- ![S50a: app SSM traffic after](img/s50a-app-ssm-private-after.png) -->
<!-- ![S50b: app S3 traffic after](img/s50b-app-s3-after.png) -->

## Baseline

<!-- ![S51: Terraform would remove the StackSets principal](img/s51-terraform-wants-to-remove.png) -->
<!-- ![S52: StackSet instances](img/s52-stackset-instances.png) -->
<!-- ![S53: Block Public Access in both regions](img/s53-bpa-both-regions.png) -->
<!-- ![S54: Egress with Block Public Access on](img/s54-egress-with-bpa.png) -->

## Patching and hardening

| Scan | Passed | Failed | Skipped |
|---|---|---|---|
| CIS Level 1, before STIG | | | |
| CIS Level 1, after STIG Medium | | | |

<!-- ![S55: Patch baseline and association](img/s55-patch-baseline-association.png) -->
<!-- ![S56: Patch compliance](img/s56-patch-compliance-scan.png) -->
<!-- ![S57: Patch install output](img/s57-patch-install-output.png) -->
<!-- ![S58: CIS before](img/s58-cis-before.png) -->
<!-- ![S59: STIG Run Command](img/s59-stig-run-command.png) -->
<!-- ![S60: CIS after](img/s60-cis-after.png) -->
<!-- ![S61a: Endpoint policy too tight](img/s61a-endpoint-policy-too-tight.png) -->
<!-- ![S61b: Endpoint policy fixed](img/s61b-endpoint-policy-fixed.png) -->

## Flow logs and troubleshooting

<!-- ![S31a: checkip from app](img/s31a-checkip-from-app.png) -->
<!-- ![S31b: The NAT gateway's IP](img/s31b-nat-eip.png) -->
<!-- ![S32: East-west open before the firewall](img/s32-east-west-open.png) -->
<!-- ![S34: Reachability Analyzer, app to shared](img/s34-reachability-app-to-shared.png) -->
<!-- ![S36: Flow log query](img/s36-flow-logs-query.png) -->

The full walk of every path is in [packet-walk.md](packet-walk.md).

## Drills

| Drill | What broke | Symptom | Found with | Drift detection said | Fix |
|---|---|---|---|---|---|
| N1 | | | | | |
| N2 | | | | | |
| N3 | | | | | |
| N4 | | | | | |
| N5 | | | | | |
| N6 | | | | | |
| N7 | | | | | |
| N8 | | | | | |

<!-- ![S62a: Blackhole in Reachability Analyzer](img/s62a-blackhole-reachability.png) -->
<!-- ![S62b: Blackhole drift](img/s62b-blackhole-drift.png) -->
<!-- ![S63a: Stateless drop, empty logs and the metric](img/s63a-stateless-drop-metric.png) -->
<!-- ![S63b: Stateless drop in Reachability Analyzer](img/s63b-stateless-drop-reachability.png) -->
<!-- ![S64a: HOME_NET drop](img/s64a-home-net-drop.png) -->
<!-- ![S64b: HOME_NET fixed](img/s64b-home-net-fixed.png) -->
<!-- ![S65a: Endpoint DNS fallback](img/s65a-endpoint-dns-fallback.png) -->
<!-- ![S65b: Endpoint DNS restored](img/s65b-endpoint-dns-restored.png) -->
<!-- ![S66: Proxy in curl -v](img/s66-proxy-curl-verbose.png) -->
<!-- ![S67a: NACL in Reachability Analyzer](img/s67a-nacl-reachability.png) -->
<!-- ![S67b: NACL, no drift](img/s67b-nacl-no-drift.png) -->
<!-- ![S68a: Block Public Access bidirectional](img/s68a-bpa-bidirectional.png) -->
<!-- ![S68b: StackSet drift](img/s68b-stackset-drift.png) -->
<!-- ![S69a: Appliance mode off](img/s69a-appliance-mode-off.png) -->
<!-- ![S69b: Appliance mode back on](img/s69b-appliance-mode-on.png) -->
<!-- ![S69c: The export wall](img/s69c-export-wall.png) -->

## Proving it

<!-- ![S70: No-change change sets](img/s70-no-change-change-sets.png) -->
<!-- ![S71: Drift in sync](img/s71-drift-in-sync.png) -->
<!-- ![S72a: Cheap mode change set](img/s72a-cheap-mode-change-set.png) -->
<!-- ![S72b: Cheap mode egress](img/s72b-cheap-mode-egress.png) -->
<!-- ![S73a: Full delete](img/s73a-full-delete.png) -->
<!-- ![S73b: Check green after delete](img/s73b-check-green.png) -->
<!-- ![S74: Timed rebuild](img/s74-timed-rebuild.png) -->

## Decisions

<!-- The main calls, each linking to its row in ../decisions.md -->

## What broke

| Problem | Cause | Fix |
|---|---|---|

## Known gaps

## Cost

<!-- ![S75: Cost Explorer by Project](img/s75-cost-explorer-network.png) -->
<!-- ![S76: Cost alert email](img/s76-cost-alert-email.png) -->

## Tested with

| Tool | Version |
|---|---|
| AWS CLI | 2.39.2 |
| Session Manager plugin | 1.2.896.0 |
| cfn-lint | 1.59.0 |
| cfn-guard | 3.2.1 |
