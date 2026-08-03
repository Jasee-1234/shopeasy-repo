# ---------------------------------------------------------------------------
# Remote state backend. State is stored in S3 (versioned + encrypted) and
# locked using S3's NATIVE locking (use_lockfile) - not DynamoDB.
#
# Terraform's S3 backend used to require a separate DynamoDB table purely
# for locking. Since Terraform 1.10+, S3 can lock on its own using
# conditional writes (S3 refuses to create a lock file if one already
# exists - that's the whole mechanism). The `dynamodb_table` argument is
# now deprecated in favor of `use_lockfile = true`.
#
# NOTE: Terraform backend blocks cannot use variables or interpolation -
# these values are literal strings. Run `bootstrap/` first (it creates the
# bucket below), then update this literal bucket name by hand if you
# changed project_name from the default "shopeasy":
# ---------------------------------------------------------------------------
terraform {
  backend "s3" {
    bucket       = "shopeasy-terraform-state-jaseew59"
    key          = "platform/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true # S3-native locking - replaces dynamodb_table
  }
}
