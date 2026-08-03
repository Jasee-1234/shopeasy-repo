# =============================================================================
# Common data sources used across the project [read-only lookups (no resources created here)]
# =============================================================================

# Current AWS account ID and region (very useful for ARNs)
data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

# Available AZs in the region (optional but good practice)
data "aws_availability_zones" "available" {
  state = "available"
}