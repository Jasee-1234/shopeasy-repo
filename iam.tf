# =============================================================================
# IAM Roles, Policies for ECS, Codebuild, CodePipeline, CodeDeploy
# + Microsoft Entra ID (Azure AD) SAML Federation
# =============================================================================

# =============================================================================
# Note: data "aws_caller_identity" "current" and data "aws_region" "current"
# are already declared in data.tf and are used throughout this file.
# =============================================================================
# 1. ECS Task Execution Role
# Used by ECS agent itself to:
# - Pull Docker images from ECR
# - Write logs to CloudWatch
# =============================================================================

resource "aws_iam_role" "ecs_task_execution" {
  name = "${local.name_prefix}-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-ecs-task-execution-role"
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# =============================================================================
# 2. ECS Task Role (Application Role)
# Used by the application code running inside the container
# =============================================================================

resource "aws_iam_role" "ecs_task" {
  name = "${local.name_prefix}-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-ecs-task-role"
  })
}

# Inline least-privilege policy for the application
resource "aws_iam_role_policy" "ecs_task" {
  name = "${local.name_prefix}-ecs-task-policy"
  role = aws_iam_role.ecs_task.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DynamoDBAccess"
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:BatchGetItem",
          "dynamodb:BatchWriteItem"
        ]
        Resource = [
          aws_dynamodb_table.transactions.arn,
          "${aws_dynamodb_table.transactions.arn}/index/*"
        ]
      },
      {
        Sid    = "AssetsBucketAccess"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = "${aws_s3_bucket.assets.arn}/*"
      },
      {
        Sid      = "AssetsBucketList"
        Effect   = "Allow"
        Action   = ["s3:ListBucket"]
        Resource = aws_s3_bucket.assets.arn
      }

    ]
  })
}

# =============================================================================
# 3. CodeBuild Service Role
# =============================================================================
resource "aws_iam_role" "codebuild" {
  name = "${local.name_prefix}-codebuild-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "codebuild.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-codebuild-role"
  })
}

resource "aws_iam_role_policy" "codebuild" {
  name = "${local.name_prefix}-codebuild-policy"
  role = aws_iam_role.codebuild.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "CloudWatchLogs"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/*"
      },
      {
        Sid    = "ECRAccess"
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
        Resource = "*"
      },
      {
        Sid    = "S3Artifacts"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject"
        ]
        Resource = "${aws_s3_bucket.pipeline_artifacts.arn}/*"
      },
      {
        Sid      = "S3ArtifactsList"
        Effect   = "Allow"
        Action   = ["s3:ListBucket"]
        Resource = aws_s3_bucket.pipeline_artifacts.arn
      }
    ]
  })
}

# =============================================================================
# 6. Microsoft Entra ID (Azure AD) SAML Federation
# Place the metadata XML file (downloaded from Azure Enterprise Application)
# next to this Terraform code and name it entra-id-metadata.xml
# =============================================================================
# You will upload the Entra ID metadata XML (or the IdP certificate + SSO URL)
# This creates the SAML provider that AWS trusts.

resource "aws_iam_saml_provider" "entra_id" {
  name                   = "${local.name_prefix}-entra-id-provider"
  saml_metadata_document = file("${path.root}/entra-id-metadata.xml")

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-entra-id-provider"
  })
}

resource "aws_iam_role" "entra_devops" {
  name = "${local.name_prefix}-entra-devops-engineer"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_saml_provider.entra_id.arn
      }
      Action = "sts:AssumeRoleWithSAML"
      Condition = {
        StringEquals = {
          "SAML:aud" = "https://signin.aws.amazon.com/saml"
        }
      }
    }]
  })

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-entra-devops-engineer"
  })
}

resource "aws_iam_role_policy_attachment" "entra_devops" {
  role       = aws_iam_role.entra_devops.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_role" "entra_readonly" {
  name = "${local.name_prefix}-entra-readonly-auditor"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_saml_provider.entra_id.arn
      }
      Action = "sts:AssumeRoleWithSAML"
      Condition = {
        StringEquals = {
          "SAML:aud" = "https://signin.aws.amazon.com/saml"
        }
      }
    }]
  })

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-entra-readonly-auditor"
  })
}

resource "aws_iam_role_policy_attachment" "entra_readonly" {
  role       = aws_iam_role.entra_readonly.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}
