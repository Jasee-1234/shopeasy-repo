# =============================================================================
# ECS Service Auto-Scaling + CloudWatch Alarms
# Product-service & Order-service:
# 4 scaling policies (2 scale-out + 2 scale-in)
# 4 CloudWatch alarms (2 High-CPU + 2 Low-CPU)
# =============================================================================

# =============================================================================
# ECS Service (Product) Auto-Scaling Target 
# =============================================================================

resource "aws_appautoscaling_target" "product" {
  max_capacity       = var.max_capacity
  min_capacity       = var.min_capacity
  resource_id        = "service/${aws_ecs_cluster.primary.name}/${aws_ecs_service.product.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# Product Scale-Out Policy (High CPU)
resource "aws_appautoscaling_policy" "product_scale_out" {
  name               = "${local.name_prefix}-product-scale-out"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.product.resource_id
  scalable_dimension = aws_appautoscaling_target.product.scalable_dimension
  service_namespace  = aws_appautoscaling_target.product.service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }
}

# Product Scale-In Policy (Low CPU)
resource "aws_appautoscaling_policy" "product_scale_in" {
  name               = "${local.name_prefix}-product-scale-in"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.product.resource_id
  scalable_dimension = aws_appautoscaling_target.product.scalable_dimension
  service_namespace  = aws_appautoscaling_target.product.service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 120
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }
}

# Product High-CPU Alarm → Scale Out
resource "aws_cloudwatch_metric_alarm" "product_cpu_high" {
  alarm_name          = "${local.name_prefix}-product-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 70
  alarm_description   = "Scale out product service when CPU > 70%"
  alarm_actions       = [aws_appautoscaling_policy.product_scale_out.arn]

  dimensions = {
    ClusterName = aws_ecs_cluster.primary.name
    ServiceName = aws_ecs_service.product.name
  }

  tags = local.common_tags
}

# Product Low-CPU Alarm → Scale In
resource "aws_cloudwatch_metric_alarm" "product_cpu_low" {
  alarm_name          = "${local.name_prefix}-product-cpu-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 30
  alarm_description   = "Scale in product service when CPU < 30%"
  alarm_actions       = [aws_appautoscaling_policy.product_scale_in.arn]

  dimensions = {
    ClusterName = aws_ecs_cluster.primary.name
    ServiceName = aws_ecs_service.product.name
  }

  tags = local.common_tags
}

# =============================================================================
# Order Service – Auto-Scaling Target
# =============================================================================
resource "aws_appautoscaling_target" "order" {
  max_capacity       = var.max_capacity
  min_capacity       = var.min_capacity
  resource_id        = "service/${aws_ecs_cluster.primary.name}/${aws_ecs_service.order.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# Order Scale-Out Policy (High CPU)
resource "aws_appautoscaling_policy" "order_scale_out" {
  name               = "${local.name_prefix}-order-scale-out"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.order.resource_id
  scalable_dimension = aws_appautoscaling_target.order.scalable_dimension
  service_namespace  = aws_appautoscaling_target.order.service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }
}

# Order Scale-In Policy (Low CPU)
resource "aws_appautoscaling_policy" "order_scale_in" {
  name               = "${local.name_prefix}-order-scale-in"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.order.resource_id
  scalable_dimension = aws_appautoscaling_target.order.scalable_dimension
  service_namespace  = aws_appautoscaling_target.order.service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 120
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }
}

# Order High-CPU Alarm → Scale Out
resource "aws_cloudwatch_metric_alarm" "order_cpu_high" {
  alarm_name          = "${local.name_prefix}-order-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 70
  alarm_description   = "Scale out order service when CPU > 70%"
  alarm_actions       = [aws_appautoscaling_policy.order_scale_out.arn]

  dimensions = {
    ClusterName = aws_ecs_cluster.primary.name
    ServiceName = aws_ecs_service.order.name
  }

  tags = local.common_tags
}

# Order Low-CPU Alarm → Scale In
resource "aws_cloudwatch_metric_alarm" "order_cpu_low" {
  alarm_name          = "${local.name_prefix}-order-cpu-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 30
  alarm_description   = "Scale in order service when CPU < 30%"
  alarm_actions       = [aws_appautoscaling_policy.order_scale_in.arn]

  dimensions = {
    ClusterName = aws_ecs_cluster.primary.name
    ServiceName = aws_ecs_service.order.name
  }

  tags = local.common_tags
}