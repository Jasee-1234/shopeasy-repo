# =============================================================================
# Two S3 buckets:
# 1. Pipeline_artifacts  → used by CodePipeline to store build artifacts (Private)
# 2. Assets              → used by the application for static files or images / frontend (served via CloudFront)
# =============================================================================

# =============================================================================
# 1. CodePipeline Artifacts Bucket
# =============================================================================
resource "aws_s3_bucket" "pipeline_artifacts" {
  bucket = "${local.name_prefix}-pipeline-artifacts"

  tags = merge(local.common_tags, {
    Name    = "${local.name_prefix}-pipeline-artifacts"
    Purpose = "CodePipeline Artifacts"
  })
}

resource "aws_s3_bucket_versioning" "pipeline_artifacts" {
  bucket = aws_s3_bucket.pipeline_artifacts.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "pipeline_artifacts" {
  bucket = aws_s3_bucket.pipeline_artifacts.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block ALL public access – this bucket must stay private
resource "aws_s3_bucket_public_access_block" "pipeline_artifacts" {
  bucket = aws_s3_bucket.pipeline_artifacts.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# =============================================================================
# 2. Application Assets Bucket - Frontend / Static Website Bucket
# =============================================================================

resource "aws_s3_bucket" "assets" {
  bucket = "${local.name_prefix}-assets"

  tags = merge(local.common_tags, {
    Name    = "${local.name_prefix}-assets"
    Purpose = "Frontend Static Website"
  })
}

# Enable Versioning
resource "aws_s3_bucket_versioning" "assets" {
  bucket = aws_s3_bucket.assets.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "assets" {
  bucket = aws_s3_bucket.assets.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Keep the bucket completely private
resource "aws_s3_bucket_public_access_block" "assets" {
  bucket = aws_s3_bucket.assets.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}




