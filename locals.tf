# =============================================================================
# ShopEasy Platform - locals.tf
# =============================================================================

locals {
  # Common naming prefix
  name_prefix = "${var.project_name}-${var.environment}"

  # Standard tags (applied to almost everything)
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Owner       = "Jasee Wong"
    Application = "${var.github_owner}/${var.github_repo}"
    Repository  = " GitHub"
    Terraform   = "true"
    Portfolio   = "Cloud Engineer Capstone"
  }

  # Microservice names
  product_service_name = "product"
  order_service_name   = "order"

  # Log groups
  product_log_group = "/ecs/${local.name_prefix}-product" # → /ecs/shopeasy-dev-product
  order_log_group   = "/ecs/${local.name_prefix}-order"   # → /ecs/shopeasy-dev-order

  # Container images (will be updated after first build)
  product_image = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${local.product_service_name}:latest"
  order_image   = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${local.order_service_name}:latest"
}
