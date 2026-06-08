output "organizational_units" {
  value = {
    root           = data.aws_organizations_organization.this.roots[0].id
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

output "accounts" {
  value = {
    management  = data.aws_organizations_organization.this.master_account_id
    log_archive = data.aws_organizations_account.log_archive.id
  }
}
}

output "management_account_id" {
  value = data.aws_organizations_organization.this.master_account_id
}
