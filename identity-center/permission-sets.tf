# ── INFRASTRUCTURE Permissions ──────────────────────────────────────────────

resource "aws_ssoadmin_permission_set" "infra_read" {
  name             = "PS-INFRA-READ"
  description      = "Read-only access to infrastructure resources"
  instance_arn     = local.instance_arn
  session_duration = "PT8H"
}

resource "aws_ssoadmin_managed_policy_attachment" "infra_read" {
  instance_arn       = local.instance_arn
  managed_policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
  permission_set_arn = aws_ssoadmin_permission_set.infra_read.arn
}

resource "aws_ssoadmin_permission_set" "infra_poweruser" {
  name             = "PS-INFRA-POWERUSER"
  description      = "Infrastructure power user - deploy but limited security changes"
  instance_arn     = local.instance_arn
  session_duration = "PT8H"
}

resource "aws_ssoadmin_managed_policy_attachment" "infra_poweruser" {
  instance_arn       = local.instance_arn
  managed_policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
  permission_set_arn = aws_ssoadmin_permission_set.infra_poweruser.arn
}

resource "aws_ssoadmin_permission_set" "infra_admin" {
  name             = "PS-INFRA-ADMIN"
  description      = "Full infrastructure administrator"
  instance_arn     = local.instance_arn
  session_duration = "PT4H"
}

resource "aws_ssoadmin_managed_policy_attachment" "infra_admin" {
  instance_arn       = local.instance_arn
  managed_policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  permission_set_arn = aws_ssoadmin_permission_set.infra_admin.arn
}

# ── DATA Permissions ────────────────────────────────────────────────────────

resource "aws_ssoadmin_permission_set" "data_read" {
  name             = "PS-DATA-READ"
  description      = "Read-only access to data services (RDS, DynamoDB, S3, Athena)"
  instance_arn     = local.instance_arn
  session_duration = "PT8H"
}

resource "aws_ssoadmin_permission_set_inline_policy" "data_read" {
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.data_read.arn
  inline_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DataReadOnly"
        Effect = "Allow"
        Action = [
          "rds:Describe*",
          "rds:List*",
          "dynamodb:Describe*",
          "dynamodb:GetItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "s3:Get*",
          "s3:List*",
          "athena:Get*",
          "athena:List*",
          "athena:StartQueryExecution",
          "athena:StopQueryExecution",
          "glue:Get*",
          "glue:BatchGet*",
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_ssoadmin_permission_set" "data_poweruser" {
  name             = "PS-DATA-POWERUSER"
  description      = "Data power user - query, export, manage datasets"
  instance_arn     = local.instance_arn
  session_duration = "PT8H"
}

resource "aws_ssoadmin_permission_set_inline_policy" "data_poweruser" {
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.data_poweruser.arn
  inline_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DataPowerUser"
        Effect = "Allow"
        Action = [
          "rds:Describe*",
          "rds:List*",
          "rds:CreateDBSnapshot",
          "rds:RestoreDBInstanceFromDBSnapshot",
          "dynamodb:Describe*",
          "dynamodb:GetItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:BatchGetItem",
          "s3:Get*",
          "s3:List*",
          "s3:PutObject",
          "s3:DeleteObject*",
          "athena:*",
          "glue:*",
          "lambda:InvokeFunction",
          "lambda:GetFunctionConfiguration",
          "lambda:ListFunctions",
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_ssoadmin_permission_set" "data_admin" {
  name             = "PS-DATA-ADMIN"
  description      = "Full data administrator"
  instance_arn     = local.instance_arn
  session_duration = "PT4H"
}

resource "aws_ssoadmin_permission_set_inline_policy" "data_admin" {
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.data_admin.arn
  inline_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DataAdminFull"
        Effect = "Allow"
        Action = [
          "rds:*",
          "dynamodb:*",
          "s3:*",
          "athena:*",
          "glue:*",
          "elasticache:*",
          "redshift:*",
          "kinesis:*",
        ]
        Resource = "*"
      }
    ]
  })
}

# ── NETWORK Permissions ─────────────────────────────────────────────────────

resource "aws_ssoadmin_permission_set" "network_read" {
  name             = "PS-NETWORK-READ"
  description      = "Read-only access to networking resources"
  instance_arn     = local.instance_arn
  session_duration = "PT8H"
}

resource "aws_ssoadmin_permission_set_inline_policy" "network_read" {
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.network_read.arn
  inline_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "NetworkRead"
        Effect = "Allow"
        Action = [
          "ec2:Describe*",
          "ec2:Get*",
          "ec2:SearchLocalGatewayRoutes",
          "directconnect:Describe*",
          "route53:Get*",
          "route53:List*",
          "route53resolver:Get*",
          "route53resolver:List*",
          "cloudfront:Get*",
          "cloudfront:List*",
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_ssoadmin_permission_set" "network_admin" {
  name             = "PS-NETWORK-ADMIN"
  description      = "Full network administrator"
  instance_arn     = local.instance_arn
  session_duration = "PT4H"
}

resource "aws_ssoadmin_permission_set_inline_policy" "network_admin" {
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.network_admin.arn
  inline_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "NetworkAdmin"
        Effect = "Allow"
        Action = [
          "ec2:*",
          "directconnect:*",
          "route53:*",
          "route53resolver:*",
          "cloudfront:*",
          "globalaccelerator:*",
        ]
        Resource = "*"
      }
    ]
  })
}

# ── SECURITY Permissions ────────────────────────────────────────────────────

resource "aws_ssoadmin_permission_set" "security_read" {
  name             = "PS-SECURITY-READ"
  description      = "Read-only access to security services"
  instance_arn     = local.instance_arn
  session_duration = "PT8H"
}

resource "aws_ssoadmin_permission_set_inline_policy" "security_read" {
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.security_read.arn
  inline_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "SecurityRead"
        Effect = "Allow"
        Action = [
          "iam:Get*",
          "iam:List*",
          "guardduty:Get*",
          "guardduty:List*",
          "securityhub:Get*",
          "securityhub:List*",
          "cloudtrail:Get*",
          "cloudtrail:List*",
          "cloudtrail:LookupEvents",
          "config:Get*",
          "config:List*",
          "config:Describe*",
          "kms:Describe*",
          "kms:List*",
          "macie2:Get*",
          "macie2:List*",
          "access-analyzer:Get*",
          "access-analyzer:List*",
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_ssoadmin_permission_set" "security_admin" {
  name             = "PS-SECURITY-ADMIN"
  description      = "Full security administrator"
  instance_arn     = local.instance_arn
  session_duration = "PT4H"
}

resource "aws_ssoadmin_managed_policy_attachment" "security_admin" {
  instance_arn       = local.instance_arn
  managed_policy_arn = "arn:aws:iam::aws:policy/SecurityAudit"
  permission_set_arn = aws_ssoadmin_permission_set.security_admin.arn
}

resource "aws_ssoadmin_permission_set_inline_policy" "security_admin" {
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.security_admin.arn
  inline_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "SecurityAdminFull"
        Effect = "Allow"
        Action = [
          "iam:*",
          "guardduty:*",
          "securityhub:*",
          "cloudtrail:*",
          "config:*",
          "kms:*",
          "macie2:*",
          "access-analyzer:*",
          "waf:*",
          "waf-regional:*",
          "wafv2:*",
          "shield:*",
          "sso:*",
          "identitystore:*",
        ]
        Resource = "*"
      }
    ]
  })
}

# ── BILLING Permissions ─────────────────────────────────────────────────────

resource "aws_ssoadmin_permission_set" "billing_read" {
  name             = "PS-BILLING-READ"
  description      = "Read-only access to billing and cost data"
  instance_arn     = local.instance_arn
  session_duration = "PT8H"
}

resource "aws_ssoadmin_managed_policy_attachment" "billing_read" {
  instance_arn       = local.instance_arn
  managed_policy_arn = "arn:aws:iam::aws:policy/job-function/Billing"
  permission_set_arn = aws_ssoadmin_permission_set.billing_read.arn
}

resource "aws_ssoadmin_permission_set" "billing_admin" {
  name             = "PS-BILLING-ADMIN"
  description      = "Full billing administrator"
  instance_arn     = local.instance_arn
  session_duration = "PT4H"
}

resource "aws_ssoadmin_managed_policy_attachment" "billing_admin" {
  instance_arn       = local.instance_arn
  managed_policy_arn = "arn:aws:iam::aws:policy/job-function/Billing"
  permission_set_arn = aws_ssoadmin_permission_set.billing_admin.arn
}

resource "aws_ssoadmin_permission_set_inline_policy" "billing_admin" {
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.billing_admin.arn
  inline_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "BillingAdminExtras"
        Effect = "Allow"
        Action = [
          "aws-portal:*",
          "budgets:*",
          "ce:*",
          "pricing:*",
          "account:*",
          "cur:*",
          "tax:*",
        ]
        Resource = "*"
      }
    ]
  })
}

# ── BREAK GLASS Permissions ─────────────────────────────────────────────────

resource "aws_ssoadmin_permission_set" "break_glass" {
  name             = "PS-BREAK-GLASS"
  description      = "Emergency break-glass full administrator access"
  instance_arn     = local.instance_arn
  session_duration = "PT1H"
}

resource "aws_ssoadmin_managed_policy_attachment" "break_glass" {
  instance_arn       = local.instance_arn
  managed_policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  permission_set_arn = aws_ssoadmin_permission_set.break_glass.arn
}

# ── REGIONAL FULL-ADMIN Permissions ──────────────────────────────────────────
# One PS per enabled region (except ap-south-1) giving full admin restricted
# to that region only. Global services are excluded from the Deny condition.

resource "aws_ssoadmin_permission_set" "regional_full" {
  for_each         = local.enabled_regions
  name             = "PS-REGION-${replace(upper(each.key), "-", "")}-FULL"
  description      = "Full administrator access restricted to ${each.key}"
  instance_arn     = local.instance_arn
  session_duration = "PT8H"
}

resource "aws_ssoadmin_managed_policy_attachment" "regional_full" {
  for_each           = local.enabled_regions
  instance_arn       = local.instance_arn
  managed_policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  permission_set_arn = aws_ssoadmin_permission_set.regional_full[each.key].arn
}

resource "aws_ssoadmin_permission_set_inline_policy" "regional_full" {
  for_each           = local.enabled_regions
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.regional_full[each.key].arn
  inline_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DenyOutsideRegion"
        Effect = "Deny"
        NotAction = local.global_services
        Resource = "*"
        Condition = {
          StringNotEquals = {
            "aws:RequestedRegion" = each.key
          }
        }
      },
      {
        Sid      = "ProtectCriticalDNS"
        Effect   = "Deny"
        Action   = "route53:*"
        Resource = "arn:aws:route53:::hostedzone/Z0149110ESRQZA43NYDW"
      },
      {
        Sid      = "ProtectCloudFront"
        Effect   = "Deny"
        Action   = "cloudfront:*"
        Resource = "arn:aws:cloudfront::817690546479:distribution/E1H8OEG8S7C6TQ"
      }
    ]
  })
}
