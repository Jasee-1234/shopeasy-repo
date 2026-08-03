
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
# ALB Outputs
# These DNS names are how to access the services in a browser
# Example: http://shopeasy-order-alb-123456789.us-east-1.elb.amazonaws.com
# =============================================================================

output "product_service_alb_dns" {
  description = "Product Service ALB DNS Name-paste into browser to test"
  value       = aws_lb.product.dns_name
}

output "order_service_alb_dns" {
  description = "Order Service ALB DNS name-paste into browser to test"
  value       = aws_lb.order.dns_name
}

