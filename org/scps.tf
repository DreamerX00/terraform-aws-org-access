locals {
  ou_map = {
    core           = aws_organizations_organizational_unit.core.id
    core_security  = aws_organizations_organizational_unit.core_security.id
    infrastructure = aws_organizations_organizational_unit.infrastructure.id
    infra_shared   = aws_organizations_organizational_unit.infra_shared.id
    workloads      = aws_organizations_organizational_unit.workloads.id
    prod           = aws_organizations_organizational_unit.workloads_prod.id
    staging        = aws_organizations_organizational_unit.workloads_staging.id
    dev            = aws_organizations_organizational_unit.workloads_dev.id
    sandbox        = aws_organizations_organizational_unit.workloads_sandbox.id
  }
}

# ── SCP: Region Restriction ──────────────────────────────────────────────────
resource "aws_organizations_policy" "region_restriction" {
  name        = "SCP-GUARD-REGION-RESTRICT"
  description = "Restrict AWS operations to approved regions only"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DenyUnapprovedRegions"
        Effect = "Deny"
        NotAction = [
          "a4b:*",
          "acm:*",
          "aws-portal:*",
          "budgets:*",
          "ce:*",
          "chime:*",
          "cloudfront:*",
          "globalaccelerator:*",
          "iam:*",
          "importexport:*",
          "organizations:*",
          "route53:*",
          "s3:*",
          "shield:*",
          "sts:*",
          "support:*",
          "trustedadvisor:*",
          "waf:*",
          "waf-regional:*",
          "wafv2:*",
        ]
        Resource = "*"
        Condition = {
          StringNotEquals = {
            "aws:RequestedRegion" = [
              "ap-south-1",
              "eu-north-1",
              "us-east-1",
              "us-east-2",
              "eu-west-1",
            ]
          }
        }
      }
    ]
  })

  tags = {
    Name = "SCP-GUARD-REGION-RESTRICT"
  }
}

resource "aws_organizations_policy_attachment" "region_restriction_workloads" {
  policy_id = aws_organizations_policy.region_restriction.id
  target_id = local.ou_map["workloads"]
}

resource "aws_organizations_policy_attachment" "region_restriction_dev" {
  policy_id = aws_organizations_policy.region_restriction.id
  target_id = local.ou_map["dev"]
}

resource "aws_organizations_policy_attachment" "region_restriction_staging" {
  policy_id = aws_organizations_policy.region_restriction.id
  target_id = local.ou_map["staging"]
}

resource "aws_organizations_policy_attachment" "region_restriction_sandbox" {
  policy_id = aws_organizations_policy.region_restriction.id
  target_id = local.ou_map["sandbox"]
}

# ── SCP: Root User Protection ───────────────────────────────────────────────
resource "aws_organizations_policy" "root_protection" {
  name        = "SCP-GUARD-ROOT-LOCK"
  description = "Prevent root user activities except break-glass scenarios"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DenyRootAccess"
        Effect = "Deny"
        Action = "*"
        Resource = "*"
        Condition = {
          StringLike = {
            "aws:PrincipalArn" = [
              "arn:aws:iam::*:root",
            ]
          }
        }
      }
    ]
  })

  tags = {
    Name = "SCP-GUARD-ROOT-LOCK"
  }
}

resource "aws_organizations_policy_attachment" "root_protection_all" {
  policy_id = aws_organizations_policy.root_protection.id
  target_id = aws_organizations_organizational_unit.workloads.id
}

resource "aws_organizations_policy_attachment" "root_protection_core" {
  policy_id = aws_organizations_policy.root_protection.id
  target_id = aws_organizations_organizational_unit.core.id
}

resource "aws_organizations_policy_attachment" "root_protection_infra" {
  policy_id = aws_organizations_policy.root_protection.id
  target_id = aws_organizations_organizational_unit.infrastructure.id
}

# ── SCP: Security Services Protection ───────────────────────────────────────
resource "aws_organizations_policy" "security_protection" {
  name        = "SCP-GUARD-SECURITY-PROTECT"
  description = "Prevent disabling or modifying critical security services"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DenyCloudTrailChanges"
        Effect = "Deny"
        Action = [
          "cloudtrail:DeleteTrail",
          "cloudtrail:StopLogging",
          "cloudtrail:UpdateTrail",
          "cloudtrail:PutEventSelectors",
        ]
        Resource = "*"
      },
      {
        Sid    = "DenyConfigChanges"
        Effect = "Deny"
        Action = [
          "config:DeleteConfigRule",
          "config:DeleteConfigurationRecorder",
          "config:StopConfigurationRecorder",
          "config:DeleteDeliveryChannel",
        ]
        Resource = "*"
      },
      {
        Sid    = "DenyGuardDutyChanges"
        Effect = "Deny"
        Action = [
          "guardduty:DeleteDetector",
          "guardduty:StopMonitoringMembers",
          "guardduty:UpdateDetector",
        ]
        Resource = "*"
      },
      {
        Sid    = "DenySecurityHubChanges"
        Effect = "Deny"
        Action = [
          "securityhub:DisableSecurityHub",
          "securityhub:DeleteActionTarget",
          "securityhub:DisableImportFindingsForProduct",
        ]
        Resource = "*"
      },
    ]
  })

  tags = {
    Name = "SCP-GUARD-SECURITY-PROTECT"
  }
}

resource "aws_organizations_policy_attachment" "security_protection_all" {
  policy_id = aws_organizations_policy.security_protection.id
  target_id = data.aws_organizations_organization.this.roots[0].id
}

# ── SCP: IAM Privilege Escalation Protection ────────────────────────────────
resource "aws_organizations_policy" "iam_protection" {
  name        = "SCP-GUARD-IAM-PROTECT"
  description = "Prevent IAM privilege escalation and unauthorized changes"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DenyIAMChanges"
        Effect = "Deny"
        Action = [
          "iam:AttachRolePolicy",
          "iam:CreatePolicy",
          "iam:CreateRole",
          "iam:DeleteRole",
          "iam:DeletePolicy",
          "iam:DetachRolePolicy",
          "iam:PutRolePolicy",
          "iam:DeleteRolePolicy",
          "iam:PassRole",
          "iam:UpdateAssumeRolePolicy",
        ]
        Resource = "*"
        Condition = {
          ArnNotLike = {
            "aws:PrincipalARN" = "arn:aws:iam::*:role/AdminBreakGlass*"
          }
        }
      }
    ]
  })

  tags = {
    Name = "SCP-GUARD-IAM-PROTECT"
  }
}

resource "aws_organizations_policy_attachment" "iam_protection_workloads" {
  policy_id = aws_organizations_policy.iam_protection.id
  target_id = local.ou_map["workloads"]
}

resource "aws_organizations_policy_attachment" "iam_protection_prod" {
  policy_id = aws_organizations_policy.iam_protection.id
  target_id = local.ou_map["prod"]
}

resource "aws_organizations_policy_attachment" "iam_protection_staging" {
  policy_id = aws_organizations_policy.iam_protection.id
  target_id = local.ou_map["staging"]
}

# ── SCP: Billing Protection ─────────────────────────────────────────────────
resource "aws_organizations_policy" "billing_protection" {
  name        = "SCP-GUARD-BILLING-PROTECT"
  description = "Protect billing and cost management controls"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DenyBillingChanges"
        Effect = "Deny"
        Action = [
          "aws-portal:*",
          "budgets:DeleteBudget",
          "budgets:ModifyBudget",
          "ce:UpdateCostAllocationTags",
          "ce:CreateCostCategoryDefinition",
          "ce:DeleteCostCategoryDefinition",
          "ce:UpdateCostCategoryDefinition",
          "account:PutAlternateContact",
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Name = "SCP-GUARD-BILLING-PROTECT"
  }
}

resource "aws_organizations_policy_attachment" "billing_protection_workloads" {
  policy_id = aws_organizations_policy.billing_protection.id
  target_id = local.ou_map["workloads"]
}

resource "aws_organizations_policy_attachment" "billing_protection_core" {
  policy_id = aws_organizations_policy.billing_protection.id
  target_id = local.ou_map["core"]
}

resource "aws_organizations_policy_attachment" "billing_protection_infra" {
  policy_id = aws_organizations_policy.billing_protection.id
  target_id = local.ou_map["infrastructure"]
}

# ── SCP: Tagging Enforcement ────────────────────────────────────────────────
resource "aws_organizations_policy" "tagging_enforcement" {
  name        = "SCP-GUARD-TAGGING-ENFORCE"
  description = "Require mandatory tags on supported resources"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DenyUntaggedResources"
        Effect = "Deny"
        Action = [
          "ec2:CreateVolume",
          "ec2:CreateInstance",
          "ec2:RunInstances",
        ]
        Resource = "*"
        Condition = {
          Null = {
            "aws:RequestTag/Environment" = "true"
            "aws:RequestTag/Name"        = "true"
            "aws:RequestTag/CostCenter"  = "true"
          }
        }
      }
    ]
  })

  tags = {
    Name = "SCP-GUARD-TAGGING-ENFORCE"
  }
}

resource "aws_organizations_policy_attachment" "tagging_enforcement_prod" {
  policy_id = aws_organizations_policy.tagging_enforcement.id
  target_id = local.ou_map["prod"]
}
