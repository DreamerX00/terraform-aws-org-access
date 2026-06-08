data "aws_organizations_organization" "this" {}

locals {
  org_root_id = data.aws_organizations_organization.this.roots[0].id
}

# Management account stays at Root — cannot be moved into an OU

resource "aws_organizations_organizational_unit" "core" {
  name      = "CORE"
  parent_id = local.org_root_id
}

resource "aws_organizations_organizational_unit" "core_security" {
  name      = "Security"
  parent_id = aws_organizations_organizational_unit.core.id
}

resource "aws_organizations_organizational_unit" "infrastructure" {
  name      = "INFRASTRUCTURE"
  parent_id = local.org_root_id
}

resource "aws_organizations_organizational_unit" "infra_shared" {
  name      = "SharedServices"
  parent_id = aws_organizations_organizational_unit.infrastructure.id
}

resource "aws_organizations_organizational_unit" "workloads" {
  name      = "WORKLOADS"
  parent_id = local.org_root_id
}

resource "aws_organizations_organizational_unit" "workloads_prod" {
  name      = "PROD"
  parent_id = aws_organizations_organizational_unit.workloads.id
}

resource "aws_organizations_organizational_unit" "workloads_staging" {
  name      = "STAGING"
  parent_id = aws_organizations_organizational_unit.workloads.id
}

resource "aws_organizations_organizational_unit" "workloads_dev" {
  name      = "DEV"
  parent_id = aws_organizations_organizational_unit.workloads.id
}

resource "aws_organizations_organizational_unit" "workloads_sandbox" {
  name      = "SANDBOX"
  parent_id = aws_organizations_organizational_unit.workloads.id
}
