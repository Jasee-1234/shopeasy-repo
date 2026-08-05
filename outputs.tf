
# =============================================================================
# ShopEasy Infrastructure Outputs - Full Version (All Resources)
#
# After terraform apply finishes, outputs print important
# values of the terminal that need to know after the deployment
#
# A summary report printed at the
# end of a build — "here is everything you need to know
# now that the infrastructure exists"
#
# =============================================================================

# =============================================================================
# Deployment Context-Account & Region Outputs
# Confirms WHICH account and regionust deployed to
# Critical when managing multiple AWS accounts
# =============================================================================

output "aws_account_id" {
  description = "AWS Account ID this infrastructure was deployed to"
  value       = data.aws_caller_identity.current.account_id
}

output "aws_region" {
  description = "AWS Region this infrastructure was deployed to"
  value       = var.aws_region
}



# =============================================================================
# Networking Outputs
# =============================================================================
output "vpc_id" {
  description = "ID of the ShopEasy VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs of the two public subnets across AZ-A and AZ-B"
  value       = aws_subnet.public[*].id
}

# =============================================================================
# ALB Outputs
# These DNS names are how to access the services in a browser
# Example: http://shopeasy-order-alb-123456789.us-east-1.elb.amazonaws.com
# =============================================================================

output "product_alb_dns" {
  description = "Product Service ALB DNS Name-paste into browser to test"
  value       = aws_lb.product.dns_name
}

output "order_alb_dns" {
  description = "Order Service ALB DNS name-paste into browser to test"
  value       = aws_lb.order.dns_name
}

# =============================================================================
# ECS Outputs
# =============================================================================
output "ecs_cluster_name" {
  description = "Name of the ECS Fargate cluster"
  value       = aws_ecs_cluster.primary.name
}

output "ecs_cluster_arn" {
  description = "ARN of the ECS Fargate cluster"
  value       = aws_ecs_cluster.primary.arn
}

output "product_service_ecs_url" {
  description = " Product Service Endpoint (via ALB)"
  value       = " http://${aws_lb.product.dns_name}"
}

output "order_service_ecs_url" {
  description = " Order Service Endpoint (via ALB)"
  value       = " http://${aws_lb.order.dns_name}"
}

# =============================================================================
# ECR Outputs
# =============================================================================
output "product_repository_url" {
  description = "ECR repository URL for Product Service"
  value       = aws_ecr_repository.product.repository_url
}

output "order_repository_url" {
  description = "ECR repository URL for Order Service"
  value       = aws_ecr_repository.order.repository_url
}
# =============================================================================
# Frontend Outputs - requires s3-cloudfront
# =============================================================================
output "frontend_cloudfront_url" {
  description = "ShopEasy Customer Website (CloudFront url for the website)"
  value       = "https://${aws_cloudfront_distribution.web.domain_name}"
}

output "frontend_s3_bucket" {
  description = "S3 Bucket hosting the frontend"
  value       = aws_s3_bucket.assets.id
}

# =============================================================================
# Cloudfront Outputs
# =============================================================================
output "cloudfront_url" {
  description = "CloudFront distribution URL for frontend assets"
  value       = aws_cloudfront_distribution.web.domain_name
}

# =============================================================================
# Data & Storage Outputs
# =============================================================================
output "s3_assets_bucket_name" {
  description = "S3 bucket name for application assets"
  value       = aws_s3_bucket.assets.id
}

output "s3_artifacts_bucket_name" {
  description = "S3 bucket name of CodePipeline for build artifacts"
  value       = aws_s3_bucket.pipeline_artifacts.id
}

# =============================================================================
# DynamoDB Transactions Table
# =============================================================================

output "dynamodb_table" {
  description = "DynamoDB table name for ShopEasy transaction data"
  value       = aws_dynamodb_table.transactions.name
}

output "dynamodb_table_arn" {
  description = "DynamoDB Table ARN"
  value       = aws_dynamodb_table.transactions.arn
}

# =============================================================================
# SNS / Monitoring Outputs
# =============================================================================
output "sns_topic_arn" {
  description = "ARN of the SNS topic for critical alerts"
  value       = aws_sns_topic.alerts.arn
}

# =============================================================================
# CICD Outputs
# =============================================================================
# output "codepipeline_name" {
#  description = "CodePipeline Name"
#  value       = aws_codepipeline.main.name
# }


# =============================================================================
# Summary Output
#Prints a human-readable summary after apply completes
# =============================================================================

output "deployment_summary" {
  description = "Quick reference summary of all key endpoints"
  value       = <<EOT

# =============================================================================
ShopEasy Infrastructure — Deployment Complete!
KEY ENDPOINTS

Account & Region
AWS Account          	: ${data.aws_caller_identity.current.account_id}
Region               		: ${var.aws_region}

Networkiing
VPC ID                 	: ${aws_vpc.main.id}
	    		: ${var.aws_region}

ALBs
Product Service alb	: http://${aws_lb.product.dns_name}
Order Service alb		: http://${aws_lb.order.dns_name}

ECS cluster		: ${aws_ecs_cluster.primary.name}

ECR Repositories
Product Repo       		: ${aws_ecr_repository.product.repository_url}
Order Repo	         	: ${aws_ecr_repository.order.repository_url}

Frontend
Website (CloudFront URL)	: http://${aws_cloudfront_distribution.web.domain_name}


Storage
S3 Assets Bucket		: ${aws_s3_bucket.assets.id}
S3 Artifacts Bucket	: ${aws_s3_bucket.pipeline_artifacts.id}
DynamoDB Table		: ${aws_dynamodb_table.transactions.name}


Next Steps: 
1. terraform apply
Run: ./scripts/build-all.sh 
2. Approve GitHub connection in AWS Console 
3. Test services using the ALB URLs
4. Test Blue/Green deployment in CodePipeline 
5. Trigger manual backup: ./scripts/backup-to-gcp.sh

Documentation: ./documentation/
============================================================

  EOT
}

