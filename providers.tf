# =============================================================================
# providers.tf + versions.tf
#
# versions.tf
# Locks the exact versions of Terraform and all providers.
# The "minimum requirements" label on a product.
#
# ~> 5.0 means "5.anything is fine, but not 6.0"
# >= 1.8.0 means "1.10.0 or newer is required"
#
# providers.tf
# ShopEasy Infrastructure — Provider Configuration
#
# Providers are plugins that let Terraform talk to each
# cloud platform's API.
#
# Defines every cloud provider used by Terraform.
# Terraform is a universal remote control.
# Each provider is the specific adapter that makes it
# work with a particular TV brand (AWS, Azure, GCP).
#
# Without providers, Terraform has no idea what
# "aws_vpc" or "google_storage_bucket" means.
# AWS
# Azure
# Google Cloud
# =============================================================================

terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

# =============================================================================
# AWS Provider
# Tells Terraform to talk to Amazon Web Services
#
# Region: where resources are physically created
# us-east-1 = Northern Virginia data centres
#
# default_tags: every single AWS resource created by this
# project automatically gets these tags applied.
# Tags are like sticky labels on resources — they help:
# - Find all ShopEasy resources in the AWS console
# - Track costs per project in your AWS bill
# - Know which environment (production/dev) a resource belongs to
# - Know it was created by Terraform, not manually
# =============================================================================
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}

