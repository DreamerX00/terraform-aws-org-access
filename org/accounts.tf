# ── Existing accounts ─────────────────────────────────────────────────────
# Account limit (2) cannot be increased due to payment constraints on AWS.
# Architecture adapted for 2 accounts with consolidated roles.

data "aws_organizations_account" "log_archive" {
  account_id = "287127677792"
}

# Note: OUs remain deployed for future-proofing. When more accounts can be
# added, uncomment account resources here and in identity-center/main.tf.
