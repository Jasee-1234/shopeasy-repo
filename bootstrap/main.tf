# =============================================================================
# This is a SEPARATE, tiny Terraform config from the rest of the project.
# It creates the resources that the main project needs BEFORE you can use
# a remote backend:
#   1. S3 bucket for Terraform state
#   2. DynamoDB table for state locking
#   3. terraform-admin IAM user
#
# Why separate? Terraform's backend block can't reference resources created
# in the same configuration - the backend has to already exist before you
# can point at it. This is the standard "chicken and egg" solution: a small
# bootstrap config with its own LOCAL state, run once, before you ever run
# `terraform init` in the main project.
#
# Run this once:
#   cd bootstrap
#   terraform init
#   terraform apply
#
# State for this bootstrap stays LOCAL (deliberately).
#
# This will create a terraform.tfstate file right here in bootstrap/ - that
# local state file is your literal, demonstrable proof (for your report/
# screenshots) that Terraform state gets created locally by default, before
# you deliberately move the main project to a remote backend.
# =============================================================================

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  # Deliberately no backend block here - this config's state stays local.
}

provider "aws" {
  region = var.aws_region
}

# =============================================================================
# Variables
# =============================================================================

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "project_name" {
  type    = string
  default = "shopeasy"
}

# =============================================================================
# 1. S3 Bucket for Terraform State
# =============================================================================

resource "aws_s3_bucket" "terraform_state" {
  bucket = "${var.project_name}-terraform-state-jaseew59"

  lifecycle {
    prevent_destroy = true # protect your state file from an accidental `destroy`
  }
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled" # lets you recover a previous state file if one gets corrupted
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket                  = aws_s3_bucket.terraform_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# =============================================================================
# 2. DynamoDB Table for State Locking
# =============================================================================

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "${var.project_name}-terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name      = "${var.project_name}-terraform-locks"
    ManagedBy = "Terraform"
    Purpose   = "State locking"
  }
}

