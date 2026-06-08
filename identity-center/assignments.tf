# ── GROUP → PERMISSION SET → ACCOUNT assignment function ──────────────────
# 2-account architecture:
#   Management (817690546479): Full workloads — infra, data, network, billing
#   LogArchive (287127677792): Security & audit + read-only access to everything

# ── INFRASTRUCTURE ────────────────────────────────────────────────────────

resource "aws_ssoadmin_account_assignment" "infra_read_management" {
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.infra_read.arn
  principal_id       = aws_identitystore_group.infra_read_all.group_id
  principal_type     = "GROUP"
  target_id          = local.accounts.management
  target_type        = "AWS_ACCOUNT"
}

resource "aws_ssoadmin_account_assignment" "infra_read_logarchive" {
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.infra_read.arn
  principal_id       = aws_identitystore_group.infra_read_all.group_id
  principal_type     = "GROUP"
  target_id          = local.accounts.logarchive
  target_type        = "AWS_ACCOUNT"
}

resource "aws_ssoadmin_account_assignment" "infra_poweruser_management" {
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.infra_poweruser.arn
  principal_id       = aws_identitystore_group.infra_poweruser_dev.group_id
  principal_type     = "GROUP"
  target_id          = local.accounts.management
  target_type        = "AWS_ACCOUNT"
}

resource "aws_ssoadmin_account_assignment" "infra_admin_management" {
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.infra_admin.arn
  principal_id       = aws_identitystore_group.infra_admin_prod.group_id
  principal_type     = "GROUP"
  target_id          = local.accounts.management
  target_type        = "AWS_ACCOUNT"
}

resource "aws_ssoadmin_account_assignment" "infra_admin_dev_management" {
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.infra_admin.arn
  principal_id       = aws_identitystore_group.infra_admin_dev.group_id
  principal_type     = "GROUP"
  target_id          = local.accounts.management
  target_type        = "AWS_ACCOUNT"
}

# ── DATA ──────────────────────────────────────────────────────────────────

resource "aws_ssoadmin_account_assignment" "data_read_management" {
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.data_read.arn
  principal_id       = aws_identitystore_group.data_read_all.group_id
  principal_type     = "GROUP"
  target_id          = local.accounts.management
  target_type        = "AWS_ACCOUNT"
}

resource "aws_ssoadmin_account_assignment" "data_read_logarchive" {
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.data_read.arn
  principal_id       = aws_identitystore_group.data_read_all.group_id
  principal_type     = "GROUP"
  target_id          = local.accounts.logarchive
  target_type        = "AWS_ACCOUNT"
}

resource "aws_ssoadmin_account_assignment" "data_admin_prod_management" {
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.data_admin.arn
  principal_id       = aws_identitystore_group.data_admin_prod.group_id
  principal_type     = "GROUP"
  target_id          = local.accounts.management
  target_type        = "AWS_ACCOUNT"
}

resource "aws_ssoadmin_account_assignment" "data_admin_dev_management" {
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.data_admin.arn
  principal_id       = aws_identitystore_group.data_admin_dev.group_id
  principal_type     = "GROUP"
  target_id          = local.accounts.management
  target_type        = "AWS_ACCOUNT"
}

# ── NETWORK ───────────────────────────────────────────────────────────────

resource "aws_ssoadmin_account_assignment" "network_read_management" {
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.network_read.arn
  principal_id       = aws_identitystore_group.network_read_all.group_id
  principal_type     = "GROUP"
  target_id          = local.accounts.management
  target_type        = "AWS_ACCOUNT"
}

resource "aws_ssoadmin_account_assignment" "network_read_logarchive" {
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.network_read.arn
  principal_id       = aws_identitystore_group.network_read_all.group_id
  principal_type     = "GROUP"
  target_id          = local.accounts.logarchive
  target_type        = "AWS_ACCOUNT"
}

resource "aws_ssoadmin_account_assignment" "network_admin_management" {
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.network_admin.arn
  principal_id       = aws_identitystore_group.network_admin_all.group_id
  principal_type     = "GROUP"
  target_id          = local.accounts.management
  target_type        = "AWS_ACCOUNT"
}

# ── SECURITY ──────────────────────────────────────────────────────────────

resource "aws_ssoadmin_account_assignment" "security_read_logarchive" {
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.security_read.arn
  principal_id       = aws_identitystore_group.security_read_all.group_id
  principal_type     = "GROUP"
  target_id          = local.accounts.logarchive
  target_type        = "AWS_ACCOUNT"
}

resource "aws_ssoadmin_account_assignment" "security_admin_logarchive" {
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.security_admin.arn
  principal_id       = aws_identitystore_group.security_admin_all.group_id
  principal_type     = "GROUP"
  target_id          = local.accounts.logarchive
  target_type        = "AWS_ACCOUNT"
}

# ── BILLING ───────────────────────────────────────────────────────────────

resource "aws_ssoadmin_account_assignment" "billing_read_management" {
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.billing_read.arn
  principal_id       = aws_identitystore_group.billing_read_all.group_id
  principal_type     = "GROUP"
  target_id          = local.accounts.management
  target_type        = "AWS_ACCOUNT"
}

resource "aws_ssoadmin_account_assignment" "billing_admin_management" {
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.billing_admin.arn
  principal_id       = aws_identitystore_group.billing_admin_all.group_id
  principal_type     = "GROUP"
  target_id          = local.accounts.management
  target_type        = "AWS_ACCOUNT"
}

# ── BREAK GLASS ───────────────────────────────────────────────────────────

resource "aws_ssoadmin_account_assignment" "break_glass_management" {
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.break_glass.arn
  principal_id       = aws_identitystore_group.break_glass.group_id
  principal_type     = "GROUP"
  target_id          = local.accounts.management
  target_type        = "AWS_ACCOUNT"
}

resource "aws_ssoadmin_account_assignment" "break_glass_logarchive" {
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.break_glass.arn
  principal_id       = aws_identitystore_group.break_glass.group_id
  principal_type     = "GROUP"
  target_id          = local.accounts.logarchive
  target_type        = "AWS_ACCOUNT"
}

# ── REGIONAL FULL-ADMIN Assignments ──────────────────────────────────────────
# Each regional group gets access to the management account only.

resource "aws_ssoadmin_account_assignment" "regional_full" {
  for_each           = local.enabled_regions
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.regional_full[each.key].arn
  principal_id       = aws_identitystore_group.regional_full[each.key].group_id
  principal_type     = "GROUP"
  target_id          = local.accounts.management
  target_type        = "AWS_ACCOUNT"
}
