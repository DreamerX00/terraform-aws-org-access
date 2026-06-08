data "aws_ssoadmin_instances" "this" {}
data "terraform_remote_state" "org" {
  backend = "s3"
  config = {
    bucket = "terraform-org-state-817690546479"
    key    = "org/terraform.tfstate"
    region = "ap-south-1"
  }
}

locals {
  identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]
  instance_arn      = tolist(data.aws_ssoadmin_instances.this.arns)[0]

  accounts = {
    management = "817690546479"
    logarchive = "287127677792"
  }

  # Management account: full workloads (infra, data, network, billing, dev, prod, sandbox)
  # LogArchive account: security & audit (GuardDuty, Config, CloudTrail, Security Hub)
  management_accounts = toset([local.accounts.management])
  security_accounts   = toset([local.accounts.logarchive])

  # Future: add new accounts here when limit increase is resolved
  # workload_accounts = toset([local.accounts.management, local.accounts.logarchive, ...])

  # Enabled regions (excluding ap-south-1 which is the home region)
  # Each gets a full-admin group restricted to that region only
  enabled_regions = toset([
    "ca-central-1", "ap-east-2", "eu-central-1", "eu-central-2",
    "us-west-1", "us-west-2", "af-south-1", "eu-north-1",
    "eu-west-3", "eu-west-2", "eu-west-1", "ap-northeast-3",
    "ap-northeast-2", "ap-northeast-1", "sa-east-1", "ap-east-1",
    "ap-southeast-1", "ap-southeast-2", "ap-southeast-3", "us-east-1",
    "ap-southeast-5", "ap-southeast-6", "us-east-2", "ap-southeast-7",
  ])

  # Global services excluded from regional Deny.
  # NOTE: iam, organizations, sso, identitystore are deliberately omitted —
  # a regional admin must NOT be able to modify global auth/identity.
  global_services = [
    "route53:*", "cloudfront:*",
    "budgets:*", "ce:*", "pricing:*", "support:*", "sts:*",
    "cur:*", "account:*", "aws-portal:*",
    "shield:*", "waf:*", "wafv2:*", "billing:*", "tax:*",
    "health:*", "wellarchitected:*",
  ]
}
