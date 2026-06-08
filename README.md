<div align="center">
  <h1>
    <img src="https://raw.githubusercontent.com/anomalyco/opencode/main/assets/logo.svg" alt="" width="32" height="32" style="vertical-align: middle; margin-right: 8px;">
    AWS Organization Access Control
  </h1>
  <p><strong>Production-grade IAM Identity Center architecture · Zero-touch provisioning · Terraform-driven</strong></p>
  <p>
    <img src="https://img.shields.io/badge/Terraform-7B42BC?style=flat-square&logo=terraform&logoColor=white" alt="Terraform">
    <img src="https://img.shields.io/badge/AWS_SSO-FF9900?style=flat-square&logo=amazonaws&logoColor=white" alt="AWS SSO">
    <img src="https://img.shields.io/badge/license-MIT-blue?style=flat-square" alt="License">
    <img src="https://img.shields.io/badge/status-production-green?style=flat-square" alt="Status">
  </p>
</div>

---

## 📋 Overview

Automated AWS Organization access-control using **IAM Identity Center Internal Users** with no external IdP. The only operational task is assigning users to groups — everything else is Terraform-managed.

### 🏗️ Architecture at a Glance

```
┌─────────────────────────────────────────────────────────────┐
│                      AWS Organization                        │
│  ┌──────────────────────────────────────────────────────┐   │
│  │                   Root (r-3ytq)                      │   │
│  │  ┌──────────┐  ┌──────────────┐  ┌───────────────┐ │   │
│  │  │   CORE   │  │INFRASTRUCTURE│  │   WORKLOADS   │ │   │
│  │  │ ┌──────┐ │  │ ┌──────────┐ │  │ ┌─┬─┬─┬─────┐│ │   │
│  │  │ │Security│  │ │SharedSvc │ │  │ │P│S│D│Sand ││ │   │
│  │  │ └──────┘ │  │ └──────────┘ │  │ └─┴─┴─┴─────┘│ │   │
│  │  └──────────┘  └──────────────┘  └───────────────┘ │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                              │
│  ┌──────────────┐  ┌──────────────┐                          │
│  │  Management  │  │  LogArchive  │                          │
│  │  817690546479│  │  287127677792│                          │
│  └──────────────┘  └──────────────┘                          │
└─────────────────────────────────────────────────────────────┘
```

---

## ✨ Features

| Feature | Description |
|---------|-------------|
| 🔐 **IAM Identity Center** | Internal users only — no Okta, Entra ID, or SAML complexity |
| 👥 **Group-based access** | Users → Groups → Permission Sets → Accounts (never direct) |
| 🛡️ **6 Service Control Policies** | Security, IAM, region, root, billing, and tag guardrails |
| 🌍 **24 Regional Admin Groups** | Full admin pinned to a single region with global-service protection |
| 🚨 **Break-glass** | Emergency `AdminBreakGlass` IAM role with MFA (bypasses SCPs) |
| 📦 **Terraform-managed** | 100% infrastructure-as-code, two-layer deployment |
| 🔄 **Future-proof OUs** | 9 OUs deployed — add accounts later, they inherit SCPs automatically |

---

## 🏛️ Resource Inventory

| Resource | Count |
|----------|:-----:|
| Organizational Units | **9** |
| Service Control Policies | **6** (15 attachments) |
| Permission Sets | **36** (12 domain + 24 regional) |
| Identity Center Groups | **38** (14 domain + 24 regional) |
| Account Assignments | **42** (18 domain + 24 regional) |
| Member Accounts | **2** (management + logarchive) |

---

## 🗺️ OU Hierarchy

```
Root (r-3ytq)
├── 🏠 CORE
│   └── 🛡️ Security
├── 🏗️ INFRASTRUCTURE
│   └── 🔗 SharedServices
└── 💼 WORKLOADS
    ├── 🚀 PROD
    ├── 🧪 STAGING
    ├── 🛠️ DEV
    └── 🧸 SANDBOX
```

---

## 🛡️ Service Control Policies

| SCP | Targets | Purpose |
|-----|---------|---------|
| `SCP-GUARD-SECURITY-PROTECT` | 🌐 Root | Protect CloudTrail, Config, GuardDuty, Security Hub |
| `SCP-GUARD-ROOT-LOCK` | 🏠🏗️💼 CORE, INFRA, WORKLOADS | Block root user actions (excludes `AdminBreakGlass`) |
| `SCP-GUARD-IAM-PROTECT` | 💼 WORKLOADS → PROD, STAGING | Restrict IAM role/policy creation |
| `SCP-GUARD-REGION-RESTRICT` | 💼🧪🛠️🧸 WORKLOADS → DEV, STAGING, SANDBOX | Allow only whitelisted regions |
| `SCP-GUARD-BILLING-PROTECT` | 🏠🏗️💼 CORE, INFRA, WORKLOADS | Prevent disabling billing data |
| `SCP-GUARD-TAGGING-ENFORCE` | 🚀 PROD | Require `cost-center` + `environment` tags |

---

## 👥 Permission Sets & Groups

### Domain Groups (14)

| Group | Permission Set | Access Level |
|-------|---------------|:------------:|
| `GRP-ALL-INFRA-READ` | `PS-INFRA-READ` | 📖 Read |
| `GRP-DEV-INFRA-POWERUSER` | `PS-INFRA-POWERUSER` | 🔧 Power User |
| `GRP-PROD-INFRA-ADMIN` | `PS-INFRA-ADMIN` | 👑 Admin |
| `GRP-DEV-INFRA-ADMIN` | `PS-INFRA-ADMIN` | 👑 Admin |
| `GRP-ALL-DATA-READ` | `PS-DATA-READ` | 📖 Read |
| `GRP-PROD-DATA-ADMIN` | `PS-DATA-ADMIN` | 👑 Admin |
| `GRP-DEV-DATA-ADMIN` | `PS-DATA-ADMIN` | 👑 Admin |
| `GRP-ALL-NETWORK-READ` | `PS-NETWORK-READ` | 📖 Read |
| `GRP-ALL-NETWORK-ADMIN` | `PS-NETWORK-ADMIN` | 👑 Admin |
| `GRP-ALL-SECURITY-READ` | `PS-SECURITY-READ` | 📖 Read |
| `GRP-ALL-SECURITY-ADMIN` | `PS-SECURITY-ADMIN` | 👑 Admin |
| `GRP-ALL-BILLING-READ` | `PS-BILLING-READ` | 📖 Read |
| `GRP-ALL-BILLING-ADMIN` | `PS-BILLING-ADMIN` | 👑 Admin |
| `GRP-BREAK-GLASS` | `PS-BREAK-GLASS` | 🚨 Emergency |

### Regional Groups (24)

One group per enabled AWS region, format: `GRP-REGION-{REGIONCODE}-FULL`

Each member gets `AdministratorAccess` **pinned to that region only** via an inline Deny on `aws:RequestedRegion`. IAM, Organizations, and SSO are **not** exempted — regional admins cannot modify auth/identity.

| Group Example | Region | Permissions |
|---------------|--------|:-----------:|
| `GRP-REGION-EUCENTRAL1-FULL` | `eu-central-1` | 👑 Full, region-restricted |
| `GRP-REGION-USEAST1-FULL` | `us-east-1` | 👑 Full, region-restricted |
| `GRP-REGION-APSOUTHEAST1-FULL` | `ap-southeast-1` | 👑 Full, region-restricted |
| ... | *(all 24 enabled regions)* | ... |

### Protected Resources

Every regional admin's inline policy includes a **hard Deny** on the critical Route53 hosted zone — preventing DNS takeover even though Route53 is a global service.

---

## 📁 Terraform Structure

```
terraform-aws-org-access/
│
├── 📜 ARCHITECTURE.md          # Full architecture documentation
├── 📋 REPLICATE.md             # Step-by-step reproduction guide
├── 🔒 .gitignore
│
├── 🏗️ org/                    # Layer 1: Organization structure
│   ├── main.tf                 # 9 OUs in 3-tier hierarchy
│   ├── scps.tf                 # 6 SCPs with 15 attachments
│   ├── accounts.tf             # Account data sources + creation (commented)
│   ├── backend.tf              # S3 remote state
│   ├── outputs.tf              # OU & account IDs for identity-center
│   └── providers.tf            # AWS provider config
│
└── 🎭 identity-center/         # Layer 2: Access control
    ├── main.tf                 # Locals (accounts, regions, global services)
    ├── permission-sets.tf      # 36 PS (12 domain + 24 regional)
    ├── groups.tf               # 38 groups (14 domain + 24 regional)
    ├── assignments.tf          # 42 account assignments
    ├── backend.tf              # S3 remote state
    └── providers.tf            # AWS provider config
```

---

## 🚀 Deployment

### Prerequisites

- AWS Organization with IAM Identity Center enabled
- Terraform ≥ 1.5
- S3 bucket + DynamoDB table for remote state (see `REPLICATE.md`)

### Commands

```bash
# Layer 1: OUs & SCPs
cd org/
terraform init
terraform plan
terraform apply

# Layer 2: Permission Sets, Groups & Assignments
cd identity-center/
terraform init
terraform plan
terraform apply
```

### Post-Deploy

| Step | Action | Method |
|:----:|--------|--------|
| 1 | Create `AdminBreakGlass` IAM role in each account | AWS CLI (see SCP bypass) |
| 2 | Enable MFA enforcement | IAM Identity Center Console → Settings |
| 3 | Register users | IAM Identity Center Console → Users |
| 4 | Assign users to groups | IAM Identity Center Console → Groups |

---

## 🔒 Security Design Principles

```
┌─────────────────────────────────────────────────────┐
│                Security Principles                    │
├─────────────────────────────────────────────────────┤
│  ✅  Least privilege — users get only what they need │
│  ✅  No direct user-to-account assignments           │
│  ✅  No direct IAM role creation                     │
│  ✅  MFA enforced at Identity Center level          │
│  ✅  Break-glass with audit trail                    │
│  ✅  SCPs protect critical services org-wide         │
│  ✅  Regional admins cannot modify IAM/Org/SSO       │
│  ✅  Critical DNS resources explicitly denied        │
└─────────────────────────────────────────────────────┘
```

---

## 📊 Account Distribution

| Account `ID` | Role |
|:------------:|------|
| `817690546479` | 🏢 **Management** — full workloads (infra, data, network, billing, all environments) |
| `287127677792` | 📋 **LogArchive** — security & audit (GuardDuty, Config, CloudTrail, Security Hub) + read-only |

> ⚠️ Account limit of 2 due to AWS payment constraints. OUs remain deployed for future expansion.

---

## 🧰 Quick Reference

```bash
# Show all groups
aws identitystore list-groups --identity-store-id <your-store-id>

# List account assignments
aws sso-admin list-account-assignments \
  --instance-arn <your-instance-arn> \
  --account-id <account-id>

# Refresh CLI session
aws sso logout && aws sso login

# Terraform outputs
cd org && terraform output accounts
```

---

<div align="center">
  <sub>Built with ❤️ using Terraform & AWS IAM Identity Center</sub>
  <br>
  <sub>© 2026 · MIT License</sub>
</div>
