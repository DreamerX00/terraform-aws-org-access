# ── INFRASTRUCTURE Groups ───────────────────────────────────────────────────

resource "aws_identitystore_group" "infra_read_all" {
  identity_store_id = local.identity_store_id
  display_name      = "GRP-ALL-INFRA-READ"
  description       = "Read-only infrastructure access across all accounts"
}

resource "aws_identitystore_group" "infra_poweruser_dev" {
  identity_store_id = local.identity_store_id
  display_name      = "GRP-DEV-INFRA-POWERUSER"
  description       = "Infrastructure power user in DEV accounts"
}

resource "aws_identitystore_group" "infra_admin_prod" {
  identity_store_id = local.identity_store_id
  display_name      = "GRP-PROD-INFRA-ADMIN"
  description       = "Infrastructure administrator in PROD accounts"
}

resource "aws_identitystore_group" "infra_admin_dev" {
  identity_store_id = local.identity_store_id
  display_name      = "GRP-DEV-INFRA-ADMIN"
  description       = "Infrastructure administrator in DEV accounts"
}

# ── DATA Groups ─────────────────────────────────────────────────────────────

resource "aws_identitystore_group" "data_read_all" {
  identity_store_id = local.identity_store_id
  display_name      = "GRP-ALL-DATA-READ"
  description       = "Read-only data access across all accounts"
}

resource "aws_identitystore_group" "data_admin_prod" {
  identity_store_id = local.identity_store_id
  display_name      = "GRP-PROD-DATA-ADMIN"
  description       = "Data administrator in PROD accounts"
}

resource "aws_identitystore_group" "data_admin_dev" {
  identity_store_id = local.identity_store_id
  display_name      = "GRP-DEV-DATA-ADMIN"
  description       = "Data administrator in DEV accounts"
}

# ── NETWORK Groups ──────────────────────────────────────────────────────────

resource "aws_identitystore_group" "network_read_all" {
  identity_store_id = local.identity_store_id
  display_name      = "GRP-ALL-NETWORK-READ"
  description       = "Read-only network access across all accounts"
}

resource "aws_identitystore_group" "network_admin_all" {
  identity_store_id = local.identity_store_id
  display_name      = "GRP-ALL-NETWORK-ADMIN"
  description       = "Full network administrator across all accounts"
}

# ── SECURITY Groups ─────────────────────────────────────────────────────────

resource "aws_identitystore_group" "security_read_all" {
  identity_store_id = local.identity_store_id
  display_name      = "GRP-ALL-SECURITY-READ"
  description       = "Read-only security access across all accounts"
}

resource "aws_identitystore_group" "security_admin_all" {
  identity_store_id = local.identity_store_id
  display_name      = "GRP-ALL-SECURITY-ADMIN"
  description       = "Full security administrator across all accounts"
}

# ── BILLING Groups ──────────────────────────────────────────────────────────

resource "aws_identitystore_group" "billing_read_all" {
  identity_store_id = local.identity_store_id
  display_name      = "GRP-ALL-BILLING-READ"
  description       = "Read-only billing access"
}

resource "aws_identitystore_group" "billing_admin_all" {
  identity_store_id = local.identity_store_id
  display_name      = "GRP-ALL-BILLING-ADMIN"
  description       = "Full billing administrator"
}

# ── BREAK GLASS Group ───────────────────────────────────────────────────────

resource "aws_identitystore_group" "break_glass" {
  identity_store_id = local.identity_store_id
  display_name      = "GRP-BREAK-GLASS"
  description       = "Emergency break-glass access - MFA enforced, time-limited, monitored"
}

# ── REGIONAL FULL-ADMIN Groups ───────────────────────────────────────────────
# One group per enabled region. Assign users to the group for their region.

resource "aws_identitystore_group" "regional_full" {
  for_each           = local.enabled_regions
  identity_store_id  = local.identity_store_id
  display_name       = "GRP-REGION-${replace(upper(each.key), "-", "")}-FULL"
  description        = "Full administrator access restricted to ${each.key}"
}
