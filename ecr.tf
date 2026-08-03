# =============================================================================
# Product Service Repository
# =============================================================================

resource "aws_ecr_repository" "product" {
  name                 = "${local.name_prefix}-product"
  image_tag_mutability = "MUTABLE"
  force_delete         = true # useful for dev environments

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256" # satisfies the encryption enabled
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-product"
  })
}

# =============================================================================
# Order Service Repository
# =============================================================================

resource "aws_ecr_repository" "order" {
  name                 = "${local.name_prefix}-order"
  image_tag_mutability = "MUTABLE"
  force_delete         = true # useful for dev environments

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256" # satisfies the encryption enabled
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-order"
  })
}

# =============================================================================
# Lifecycle policy (keeps only the last 10 images)
# =============================================================================
resource "aws_ecr_lifecycle_policy" "product" {
  repository = aws_ecr_repository.product.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last 10 images"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 10
      }
      action = {
        type = "expire"
      }
    }]
  })
}

resource "aws_ecr_lifecycle_policy" "order" {
  repository = aws_ecr_repository.order.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last 10 images"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 10
      }
      action = {
        type = "expire"
      }
    }]
  })
}




