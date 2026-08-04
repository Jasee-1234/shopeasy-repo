# =============================================================================
# CodeBuild Project - Order Service
# =============================================================================
resource "aws_codebuild_project" "order" {
  name          = "${local.name_prefix}-order-build"
  description   = "Builds and pushes the order service Docker image to ECR"
  service_role  = aws_iam_role.codebuild.arn
  build_timeout = 15

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:7.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true # required for Docker builds

    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = data.aws_caller_identity.current.account_id
    }
    environment_variable {
      name  = "ECR_REPO_URL"
      value = aws_ecr_repository.order.repository_url
    }
    environment_variable {
      name  = "EXECUTION_ROLE_ARN"
      value = aws_iam_role.ecs_task_execution.arn
    }
    environment_variable {
      name  = "TASK_ROLE_ARN"
      value = aws_iam_role.ecs_task.arn
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec-order.yml"
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-order-build"
  })
}

# =============================================================================
# CodeBuild Project - Product Service
# =============================================================================
resource "aws_codebuild_project" "product" {
  name          = "${local.name_prefix}-product-build"
  description   = "Builds and pushes the product service Docker image to ECR"
  service_role  = aws_iam_role.codebuild.arn
  build_timeout = 15

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:7.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = data.aws_caller_identity.current.account_id
    }
    environment_variable {
      name  = "ECR_REPO_URL"
      value = aws_ecr_repository.product.repository_url
    }
    environment_variable {
      name  = "EXECUTION_ROLE_ARN"
      value = aws_iam_role.ecs_task_execution.arn
    }
    environment_variable {
      name  = "TASK_ROLE_ARN"
      value = aws_iam_role.ecs_task.arn
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec-product.yml"
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-product-build"
  })
}