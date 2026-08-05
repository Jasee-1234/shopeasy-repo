# =============================================================================
# SNS Topic for Critical Notifications (Pipeline Failures, Scaling alerts, etc.)
# =============================================================================

resource "aws_sns_topic" "alerts" {
  name = "${var.project_name}-alerts"

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-alerts"
  })
}

# Email subscription – you must confirm the email after terraform apply
resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
  # Note: AWS emails var.alert_email a confirmation link after `terraform apply`.
  # Click it once, or the subscription stays "PendingConfirmation"
  # and no emails will actually arrive.
}

# Allow CodeStar Notifications (used by CodePipeline) to publish
resource "aws_sns_topic_policy" "alerts" {
  arn = aws_sns_topic.alerts.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "AllowCodeStarNotifications"
      Effect    = "Allow"
      Principal = { Service = "codestar-notifications.amazonaws.com" }
      Action    = "SNS:Publish"
      Resource  = aws_sns_topic.alerts.arn
    }]
  })
}

# -----------------------------------------------------------------------------
# TEMPORARILY DISABLED — enable after aws_codepipeline.main exists
# -----------------------------------------------------------------------------

# Optional – notify on pipeline success/failure
# resource "aws_codestarnotifications_notification_rule" "pipeline" {
# name        = "${local.name_prefix}-pipeline-notifications"
# resource    = aws_codepipeline.main.arn
# detail_type = "BASIC"

# event_type_ids = [
#   "codepipeline-pipeline-pipeline-execution-succeeded",
#   "codepipeline-pipeline-pipeline-execution-failed",
# ]

# target {
#   address = aws_sns_topic.alerts.arn
# }
#}
