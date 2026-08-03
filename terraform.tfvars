# =============================================================================
# terraform.tfvars.example
# Copy this file to terraform.tfvars and fill in your values
# DO NOT COMMIT terraform.tfvars (it contains secrets) - it's already listed in .gitignore
# =============================================================================

# =============================================================================
# Project Basics 
# =============================================================================
project_name = "shopeasy"
environment  = "dev"

# =============================================================================
# - AWS 
# =============================================================================
aws_region = "us-east-1"

# =============================================================================
# VPC/ Networking
# =============================================================================
vpc_cidr            = "10.0.0.0/16"
public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
availability_zones  = ["us-east-1a", "us-east-1b"]


# =============================================================================
#  ECS Task Settings 
# =============================================================================
container_port = 8080
task_cpu       = 256
task_memory    = 512
desired_count  = 1
min_capacity   = 1
max_capacity   = 4

# =============================================================================
# Github (For Codepipeline) 
# =============================================================================
github_owner  = "Jasee-1234" # GitHub username/org
github_repo   = "shopeasy-repo"
github_branch = "main"


# =============================================================================
# Notifications
# =============================================================================
alert_email = "jaseew59@gmail.com"

# =============================================================================
# AZURE
# =============================================================================
azure_tenant_id = "236f13ee-15cf-4f6a-934e-90c31d983022" # replace this with real Tenant Id
# Azure Portal > Microsoft Entra ID > Overview > Tenant ID


# ================================= Google Cloud =================================
gcp_project_id = "shopeasy-backup"
# replaced with google project id i.e. gcp_project_id = "shopeasy-backup"
# Google Cloud Console > top nav project dropdown > Project ID (not name)

gcp_region = "us-central1"



# project_name    = "shopeasy-backup"
# environment     = "dev"
# aws_region      = "us-east-1"
# gcp_region      = "us-central1"
# github_branch   = "main"

