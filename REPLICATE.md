# Replicate This Setup in a New AWS Account

> Use this guide to deploy the same IAM Identity Center access-control architecture
> in a different AWS Organization. Terraform code in `org/` and `identity-center/`
> serves as the reference; adapt the placeholder values below.

---

## Prerequisites

| Requirement | Details |
|-------------|---------|
| AWS Organization | Existing, with at least 2 accounts (management + member) |
| IAM Identity Center | Enabled in your home region (e.g., `ap-south-1`) |
| Terraform | >= 1.5 |
| AWS Credentials | Admin access to the management account |
| Account limit | Default 10; if you need more, request via AWS Support |

---

## Step 1: Clone & Replace Placeholders

Clone this repo. Search for every occurrence of these values and replace with yours:

| Find | Replace with |
|------|-------------|
| `817690546479` | Your management account ID |
| `287127677792` | Your LogArchive/security account ID |
| `o-sn1t47psxh` | Your organization ID |
| `r-3ytq` | Your root ID |
| `ap-south-1` | Your home region (if different) |
| `terraform-org-state-817690546479` | Your state bucket name |
| `Z0149110ESRQZA43NYDW` | Your Route53 hosted zone ID (or remove if not applicable) |
| `aws-security+org@akashsinghcloud.store` | Your email addresses |
| `aws-infra+org@akashsinghcloud.store` | Your email addresses |
| `aws-sandbox+org@akashsinghcloud.store` | Your email addresses |

Key files to check:
- `identity-center/main.tf` — account IDs, enabled_regions list
- `org/accounts.tf` — account IDs, emails
- `org/backend.tf` — S3 bucket name
- `org/outputs.tf` — account references
- `identity-center/backend.tf` — S3 bucket name
- `identity-center/permission-sets.tf` — Route53 hosted zone ARN (if applicable)

---

## Step 2: Bootstrap Remote State (S3 + DynamoDB)

Create a state bucket and DynamoDB lock table **before** running Terraform.

```bash
# Variables
BUCKET="terraform-org-state-<YOUR_MGMT_ACCOUNT_ID>"
TABLE="terraform-org-state-lock"
REGION="<YOUR_HOME_REGION>"

# S3 bucket
aws s3api create-bucket \
  --bucket "$BUCKET" \
  --region "$REGION" \
  --create-bucket-configuration LocationConstraint="$REGION"

aws s3api put-bucket-versioning \
  --bucket "$BUCKET" \
  --versioning-configuration Status=Enabled

aws s3api put-public-access-block \
  --bucket "$BUCKET" \
  --public-access-block-configuration \
    BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

# DynamoDB table
aws dynamodb create-table \
  --table-name "$TABLE" \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region "$REGION"
```

Then update `org/backend.tf` and `identity-center/backend.tf` with your bucket name and region.

---

## Step 3: Deploy Org Layer (OUs + SCPs)

```bash
cd org/
terraform init
terraform plan
terraform apply
```

This creates:
- **9 Organizational Units** in a 3-tier hierarchy (CORE, INFRASTRUCTURE, WORKLOADS with children)
- **6 Service Control Policies** with 15 attachments:
  - `SCP-GUARD-SECURITY-PROTECT` — Root (protects CloudTrail, Config, GuardDuty, Security Hub)
  - `SCP-GUARD-ROOT-LOCK` — CORE, INFRASTRUCTURE, WORKLOADS (restricts root user)
  - `SCP-GUARD-IAM-PROTECT` — WORKLOADS, PROD, STAGING (restricts IAM changes)
  - `SCP-GUARD-REGION-RESTRICT` — WORKLOADS, DEV, STAGING, SANDBOX (region lock)
  - `SCP-GUARD-BILLING-PROTECT` — CORE, INFRASTRUCTURE, WORKLOADS
  - `SCP-GUARD-TAGGING-ENFORCE` — PROD (tag enforcement)
- **LogArchive account** data source

### SCP Break-Glass Bypass

All SCPs that restrict IAM or root actions include a condition to bypass
the `AdminBreakGlass` role. Create this role manually in each account:

```bash
aws iam create-role \
  --role-name AdminBreakGlass \
  --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Principal": { "AWS": "arn:aws:iam::<MGMT_ACCOUNT_ID>:root" },
      "Action": "sts:AssumeRole",
      "Condition": { "Bool": { "aws:MultiFactorAuthPresent": "true" } }
    }]
  }' \
  --description "Break-glass role for emergency access with MFA"
```

Attach `AdministratorAccess`:

```bash
aws iam attach-role-policy \
  --role-name AdminBreakGlass \
  --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
```

Do this in every member account that needs break-glass access.

---

## Step 4: Discover Enabled Regions

```bash
aws ec2 describe-regions --region us-east-1 \
  --query 'Regions[?OptInStatus!=`not-opted-in`].[RegionName]' \
  --output text
```

Update `identity-center/main.tf` → `enabled_regions` list with the output
(excluding your home region if you want).

---

## Step 5: Deploy Identity Center Layer (PS + Groups + Assignments)

```bash
cd identity-center/
terraform init
terraform plan
terraform apply
```

This creates:
- **12 domain permission sets** (infra, data, network, security, billing, break-glass)
- **24 regional permission sets** (one per enabled region)
- **38 groups** (14 domain + 24 regional)
- **42 account assignments** (18 domain + 24 regional)

---

## Step 6: Post-Deploy Steps

### 6a. Create Break-Glass IAM Role

Create the `AdminBreakGlass` role in each member account (see Step 3 above).
The SCPs reference this role in their bypass conditions.

### 6b. Enable MFA

IAM Identity Center → Settings → Authentication → enable MFA (Required).

### 6c. Register Users

IAM Identity Center → Users → Add user. Then assign them to groups.

### 6d. Assign Users to Groups

Users are never assigned directly to accounts. The process is:
1. User → Group (e.g., `GRP-REGION-EUCENTRAL1-FULL`)
2. Group → Permission Set → Account (already configured via Terraform)

---

## Architecture Summary

### OU Hierarchy

```
Root
├── CORE
│   └── Security
├── INFRASTRUCTURE
│   └── SharedServices
└── WORKLOADS
    ├── PROD
    ├── STAGING
    ├── DEV
    └── SANDBOX
```

### Account Distribution (2-account model)

| Account | Role |
|---------|------|
| Management | Full workloads (infra, data, network, billing, all envs) |
| LogArchive | Security & audit + read-only access |

### Permission Set Naming

`PS-{DOMAIN}-{ROLE}` — e.g., `PS-INFRA-ADMIN`, `PS-DATA-READ`

### Group Naming

`GRP-{SCOPE}-{DOMAIN}-{ROLE}` — e.g., `GRP-ALL-INFRA-READ`, `GRP-DEV-DATA-ADMIN`

For regional groups: `GRP-REGION-{REGIONCODE}-FULL`

### Regional Admin Protection

Regional full-admin groups include an inline policy with:
1. **DenyOutsideRegion** — blocks regional services (EC2, RDS, Lambda, etc.) outside the assigned region
2. **ProtectCriticalDNS** — blocks Route53 on the primary hosted zone
3. IAM, Organizations, SSO/IdentityStore are deliberately excluded from the global-services exemption — regional admins cannot modify auth/identity

---

## Quick Reference

```bash
# Deploy org layer
cd org && terraform init && terraform apply

# Deploy identity-center layer
cd identity-center && terraform init && terraform apply

# Get account IDs
terraform output -state=org/terraform.tfstate accounts

# List all groups (from management account CLI)
aws identitystore list-groups \
  --identity-store-id <YOUR_IDENTITY_STORE_ID>
```

---

## File Structure

```
terraform-aws-org-access/
├── REPLICATE.md               ← This file
├── .gitignore
├── org/
│   ├── main.tf                # OU hierarchy
│   ├── scps.tf                # SCP policies + attachments
│   ├── accounts.tf            # Account resources
│   ├── backend.tf             # S3 backend
│   └── outputs.tf             # Outputs
└── identity-center/
    ├── main.tf                # Locals, remote state
    ├── permission-sets.tf     # Permission sets + policies
    ├── groups.tf              # Identity Center groups
    ├── assignments.tf         # Account assignments
    └── backend.tf             # S3 backend
```
