# AWS Organization Access-Control Architecture

> Generated: 2026-06-06
> Terraform Root: `/home/akash-singh/terraform-aws-org-access`

---

## Goal

Production-grade AWS Organization access-control using **IAM Identity Center Internal Users** (no external IdP). The only operational task is assigning users to groups — all provisioning, SCPs, and governance is automated via Terraform.

**2-Account Architecture** — AWS denied account limit increase (payment conflict). OUs and SCPs remain deployed for future-proofing.

---

## Organization Details

| Property | Value |
|----------|-------|
| Organization ID | `o-sn1t47psxh` |
| Root ID | `r-3ytq` |
| Management Account | `817690546479` (DreamerX0) — full workloads |
| LogArchive Account | `287127677792` — security & audit |
| IAM Identity Center Instance | `arn:aws:sso:::instance/ssoins-659531b6a425b515` |
| Identity Store ID | `d-9f6755da1e` |
| Region | `ap-south-1` |
| State Backend | `s3://terraform-org-state-817690546479/org/terraform.tfstate` |
| State Backend (IC) | `s3://terraform-org-state-817690546479/identity-center/terraform.tfstate` |

---

## OU Hierarchy (future-proof — stays deployed)

```
Root (r-3ytq)
├── CORE (ou-3ytq-vgjq7hus)
│   └── Security (ou-3ytq-xmncn1tg)
├── INFRASTRUCTURE (ou-3ytq-9qhg8zq7)
│   └── SharedServices (ou-3ytq-zjkuy09g)
└── WORKLOADS (ou-3ytq-1w8yen35)
    ├── PROD (ou-3ytq-oyi4a6gr)
    ├── STAGING (ou-3ytq-2skglook)
    ├── DEV (ou-3ytq-78vqdk06)
    └── SANDBOX (ou-3ytq-3cz5jp8m)
```

> When account limit is resolved, new accounts can be added under the appropriate OU and auto-inherit SCPs.

---

## Service Control Policies (6 policies, 15 attachments)

| SCP | Target | Effect |
|-----|--------|--------|
| `SCP-GUARD-SECURITY-PROTECT` | Root | Protects CloudTrail, Config, GuardDuty, Security Hub org-wide |
| `SCP-GUARD-ROOT-LOCK` | CORE, INFRASTRUCTURE, WORKLOADS | Prevents root user actions except BreakGlass role |
| `SCP-GUARD-IAM-PROTECT` | WORKLOADS, PROD, STAGING | Restricts IAM role/policy creation except BreakGlass role |
| `SCP-GUARD-REGION-RESTRICT` | WORKLOADS, DEV, STAGING, SANDBOX | Restricts to ap-south-1, eu-north-1, us-east-1, us-east-2, eu-west-1 |
| `SCP-GUARD-BILLING-PROTECT` | CORE, INFRASTRUCTURE, WORKLOADS | Prevents disabling billing data sharing |
| `SCP-GUARD-TAGGING-ENFORCE` | PROD | Requires cost-center and environment tags on create |

---

## Account Role Distribution

| Account | ID | Role | Groups Assigned |
|---------|----|------|-----------------|
| **Management** (DreamerX0) | `817690546479` | Full workloads — infra, data, network, billing, dev, prod, sandbox | infra-admin, infra-poweruser, infra-read, data-admin, data-read, network-admin, network-read, billing-admin, billing-read, break-glass |
| **LogArchive** | `287127677792` | Security & audit — GuardDuty, Config, CloudTrail, Security Hub | security-admin, security-read, infra-read, data-read, network-read, break-glass |

---

## IAM Identity Center — Permission Sets (12)

| PS Name | Domain | Managed Policy | Inline Policy | Session |
|---------|--------|---------------|---------------|---------|
| `PS-INFRA-ADMIN` | Infrastructure | AdministratorAccess | — | 4h |
| `PS-INFRA-POWERUSER` | Infrastructure | PowerUserAccess | — | 8h |
| `PS-INFRA-READ` | Infrastructure | ReadOnlyAccess | — | 8h |
| `PS-DATA-ADMIN` | Data | — | Full: rds, dynamodb, s3, athena, glue, elasticache, redshift, kinesis | 4h |
| `PS-DATA-POWERUSER` | Data | — | Read+Write: rds snapshots, s3 put/delete, athena, glue, lambda invoke | 8h |
| `PS-DATA-READ` | Data | — | Read: rds describe, dynamodb get/query, s3 get/list, athena, glue | 8h |
| `PS-NETWORK-ADMIN` | Network | — | Full: ec2, directconnect, route53, cloudfront, globalaccelerator | 4h |
| `PS-NETWORK-READ` | Network | — | Read: ec2 describe, directconnect describe, route53 get/list | 8h |
| `PS-SECURITY-ADMIN` | Security | SecurityAudit | Full: iam, guardduty, securityhub, cloudtrail, config, kms, macie2, waf, shield, sso | 4h |
| `PS-SECURITY-READ` | Security | — | Read: iam get/list, guardduty, securityhub, cloudtrail, config, kms | 8h |
| `PS-BILLING-ADMIN` | Billing | Billing | Extras: aws-portal, budgets, ce, pricing, account, cur, tax | 4h |
| `PS-BILLING-READ` | Billing | Billing (job-function) | — | 8h |
| `PS-BREAK-GLASS` | Emergency | AdministratorAccess | — | 1h |

---

## IAM Identity Center — Regional Full-Admin Groups (24)

Each enabled region gets a group giving full `AdministratorAccess` pinned to that region via a Deny condition on `aws:RequestedRegion`. Global services (IAM, Route53, CloudFront, Organizations, billing, etc.) are excluded from the Deny — accessible from any region.

| Region | PS Name | Group Name |
|--------|---------|------------|
| ca-central-1 | `PS-REGION-CACENTRAL1-FULL` | `GRP-REGION-CACENTRAL1-FULL` |
| ap-east-2 | `PS-REGION-APEAST2-FULL` | `GRP-REGION-APEAST2-FULL` |
| eu-central-1 | `PS-REGION-EUCENTRAL1-FULL` | `GRP-REGION-EUCENTRAL1-FULL` |
| eu-central-2 | `PS-REGION-EUCENTRAL2-FULL` | `GRP-REGION-EUCENTRAL2-FULL` |
| us-west-1 | `PS-REGION-USWEST1-FULL` | `GRP-REGION-USWEST1-FULL` |
| us-west-2 | `PS-REGION-USWEST2-FULL` | `GRP-REGION-USWEST2-FULL` |
| af-south-1 | `PS-REGION-AFSOUTH1-FULL` | `GRP-REGION-AFSOUTH1-FULL` |
| eu-north-1 | `PS-REGION-EUNORTH1-FULL` | `GRP-REGION-EUNORTH1-FULL` |
| eu-west-3 | `PS-REGION-EUWEST3-FULL` | `GRP-REGION-EUWEST3-FULL` |
| eu-west-2 | `PS-REGION-EUWEST2-FULL` | `GRP-REGION-EUWEST2-FULL` |
| eu-west-1 | `PS-REGION-EUWEST1-FULL` | `GRP-REGION-EUWEST1-FULL` |
| ap-northeast-3 | `PS-REGION-APNORTHEAST3-FULL` | `GRP-REGION-APNORTHEAST3-FULL` |
| ap-northeast-2 | `PS-REGION-APNORTHEAST2-FULL` | `GRP-REGION-APNORTHEAST2-FULL` |
| ap-northeast-1 | `PS-REGION-APNORTHEAST1-FULL` | `GRP-REGION-APNORTHEAST1-FULL` |
| sa-east-1 | `PS-REGION-SAEAST1-FULL` | `GRP-REGION-SAEAST1-FULL` |
| ap-east-1 | `PS-REGION-APEAST1-FULL` | `GRP-REGION-APEAST1-FULL` |
| ap-southeast-1 | `PS-REGION-APSOUTHEAST1-FULL` | `GRP-REGION-APSOUTHEAST1-FULL` |
| ap-southeast-2 | `PS-REGION-APSOUTHEAST2-FULL` | `GRP-REGION-APSOUTHEAST2-FULL` |
| ap-southeast-3 | `PS-REGION-APSOUTHEAST3-FULL` | `GRP-REGION-APSOUTHEAST3-FULL` |
| us-east-1 | `PS-REGION-USEAST1-FULL` | `GRP-REGION-USEAST1-FULL` |
| ap-southeast-5 | `PS-REGION-APSOUTHEAST5-FULL` | `GRP-REGION-APSOUTHEAST5-FULL` |
| ap-southeast-6 | `PS-REGION-APSOUTHEAST6-FULL` | `GRP-REGION-APSOUTHEAST6-FULL` |
| us-east-2 | `PS-REGION-USEAST2-FULL` | `GRP-REGION-USEAST2-FULL` |
| ap-southeast-7 | `PS-REGION-APSOUTHEAST7-FULL` | `GRP-REGION-APSOUTHEAST7-FULL` |

Each assigned to Management account. To add a user: assign them to the group for their region.

---

## IAM Identity Center — Groups (14 base + 24 regional = 38) & Assignments (18 base + 24 regional = 42)

| Group | PS | Management | LogArchive |
|-------|----|:-----------:|:----------:|
| `GRP-INFRA-READ-ALL` | PS-INFRA-READ | ✅ | ✅ |
| `GRP-INFRA-POWERUSER-DEV` | PS-INFRA-POWERUSER | ✅ | — |
| `GRP-INFRA-ADMIN-PROD` | PS-INFRA-ADMIN | ✅ | — |
| `GRP-INFRA-ADMIN-DEV` | PS-INFRA-ADMIN | ✅ | — |
| `GRP-DATA-READ-ALL` | PS-DATA-READ | ✅ | ✅ |
| `GRP-DATA-ADMIN-PROD` | PS-DATA-ADMIN | ✅ | — |
| `GRP-DATA-ADMIN-DEV` | PS-DATA-ADMIN | ✅ | — |
| `GRP-NETWORK-READ-ALL` | PS-NETWORK-READ | ✅ | ✅ |
| `GRP-NETWORK-ADMIN-ALL` | PS-NETWORK-ADMIN | ✅ | — |
| `GRP-SECURITY-READ-ALL` | PS-SECURITY-READ | — | ✅ |
| `GRP-SECURITY-ADMIN-ALL` | PS-SECURITY-ADMIN | — | ✅ |
| `GRP-BILLING-READ-ALL` | PS-BILLING-READ | ✅ | — |
| `GRP-BILLING-ADMIN-ALL` | PS-BILLING-ADMIN | ✅ | — |
| `GRP-BREAK-GLASS` | PS-BREAK-GLASS | ✅ | ✅ |

**Total: 18 assignments** (was 28 before 2-account consolidation)

---

## What's Deployed (Completed ✅)

| Layer | Resources | Status |
|-------|-----------|--------|
| **Org: OUs** | 9 OUs | ✅ Applied |
| **Org: SCPs** | 6 policies, 15 attachments | ✅ Applied |
| **Org: Accounts** | LogArchive data source | ✅ State |
| **Identity Center: PS** | 12 permission sets | ✅ Applied |
| **Identity Center: Policies** | 5 managed + 8 inline | ✅ Applied |
| **Identity Center: Groups** | 38 groups (14 domain + 24 regional) | ✅ Applied |
| **Identity Center: Assignments** | 42 assignments (18 domain + 24 regional) | ✅ Applied |
| **Cleanup** | 4 pre-existing OUs deleted | ✅ Done |
| **MFA Enforcement** | Configured in console | ✅ Done |
| **2-Account Redesign** | Remapped assignments | ✅ Done |
| **Regional Full-Admin Groups** | 24 PS + 24 groups + 24 assignments | ✅ Applied |

---

## Still Pending (if limit resolved)

1. **Uncomment 3 accounts** in `org/accounts.tf`
2. **Add account IDs** to `identity-center/main.tf` `workload_accounts`
3. **Re-apply** both layers

---

## Design Principles

1. **No direct user assignments** — users → groups only
2. **No direct IAM roles** — all access through Identity Center PS
3. **Group naming**: `GRP-{DOMAIN}-{ROLE}-{SCOPE}`
4. **PS naming**: `PS-{DOMAIN}-{ROLE}`
5. **Session durations**: Admin 4h, Read/PowerUser 8h, BreakGlass 1h
6. **Break-glass bypass**: SCPs exclude `AdminBreakGlass*` role ARN

---

## File Structure

```
/home/akash-singh/terraform-aws-org-access/
├── ARCHITECTURE.md
├── org/
│   ├── main.tf              # OU hierarchy (9 OUs)
│   ├── scps.tf              # 6 SCPs + 15 attachments
│   ├── accounts.tf          # Account resources (2-account constraint noted)
│   ├── backend.tf           # S3 backend
│   └── outputs.tf           # OU + account IDs
└── identity-center/
    ├── main.tf              # Remote state + account/workload locals
    ├── permission-sets.tf   # 12 PS + policies
    ├── groups.tf            # 14 groups
    ├── assignments.tf       # 18 group → PS → account assignments
    └── backend.tf           # S3 backend
```

---

## Quick Reference

```bash
cd /home/akash-singh/terraform-aws-org-access/org && terraform apply
cd /home/akash-singh/terraform-aws-org-access/identity-center && terraform apply
terraform output -state=org/terraform.tfstate accounts
```
