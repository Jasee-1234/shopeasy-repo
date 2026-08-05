# ============================================================================
# Shopeasy Enterprise Multi-cloud Platform
# ============================================================================

variable "project_name" {
  description = "Short name used to prefix/tag every resource"
  type        = string
  default     = "shopeasy"
}

variable "environment" {
  description = "Deployment environment name"
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "state_bucket_name" {
  description = "Globally unique S3 bucket name for Terraform state"
  type        = string
  default     = "shopeasy-terraform-state-jaseew59" # must be globally unique
}

variable "lock_table_name" {
  description = "DynamoDB table name for state locking"
  type        = string
  default     = "shopeasy-terraform-locks"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the two public subnets (one per AZ) - ALBs and ECS tasks both live here; see vpc.tf for why there's no separate private tier"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "availability_zones" {
  description = "AZs to deploy the public subnets into"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "container_port" {
  description = "Port each microservice container listens on"
  type        = number
  default     = 8080
}

variable "task_cpu" {
  description = "Fargate task CPU units (256 = 0.25 vCPU)"
  type        = number
  default     = 256
}

variable "task_memory" {
  description = "Fargate task memory in MB"
  type        = number
  default     = 512
}

variable "desired_count" {
  description = "Starting number of tasks per ECS service"
  type        = number
  default     = 1
}

variable "min_capacity" {
  description = "Minimum number of tasks for ECS services for autoscaling"
  type        = number
  default     = 1
}

variable "max_capacity" {
  description = "Maximum number of tasks for ECS services for autoscaling"
  type        = number
  default     = 4
}

variable "alert_email" {
  description = "Email address that receives SNS deployment and CloudWatch alarm notifications"
  type        = string
  default     = "you@example.com"
}

variable "frontend_index_document" {
  description = "Default document served by the S3 website"
  type        = string
  default     = "index.html"
}

variable "frontend_error_document" {
  description = "Error document for the S3 website"
  type        = string
  default     = "index.html"
}

# --- CodePipeline / GitHub source ---
# CodeStar Connections require a one-time manual authorization step in the
# AWS Console (Developer Tools > Connections > Connect to GitHub). Terraform
# can create the connection resource, but you must click "Update pending
# connection" once by hand before the pipeline can pull code.

variable "github_owner" {
  description = "GitHub org/username that owns the repo"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
}

variable "github_branch" {
  description = "Branch CodePipeline should track"
  type        = string
  default     = "main"
}

variable "image_tag" {
  description = "Initial image tag used the first time task definitions are created (CodePipeline updates it afterwards)"
  type        = string
  default     = "latest"
}

