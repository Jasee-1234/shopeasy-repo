# =============================================================================
# codedeploy.tf — Blue/Green for Product + Order
# =============================================================================

resource "aws_codedeploy_app" "product" {
  name             = "${local.name_prefix}-product"
  compute_platform = "ECS"
}

resource "aws_codedeploy_deployment_group" "product" {
  app_name               = aws_codedeploy_app.product.name
  deployment_group_name  = "${local.name_prefix}-product-dg"
  service_role_arn       = aws_iam_role.codedeploy.arn
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  blue_green_deployment_config {
    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 5
    }
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }
  }

  ecs_service {
    cluster_name = aws_ecs_cluster.main.name
    service_name = aws_ecs_service.product.name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [aws_lb_listener.product.arn]
      }
      target_group {
        name = aws_lb_target_group.product.name
      }
      target_group {
        name = aws_lb_target_group.product.name
      }
    }
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }
}

resource "aws_codedeploy_app" "order" {
  name             = "${local.name_prefix}-order"
  compute_platform = "ECS"
}

resource "aws_codedeploy_deployment_group" "order" {
  app_name               = aws_codedeploy_app.order.name
  deployment_group_name  = "${local.name_prefix}-order-dg"
  service_role_arn       = aws_iam_role.codedeploy.arn
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  blue_green_deployment_config {
    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 5
    }
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }
  }

  ecs_service {
    cluster_name = aws_ecs_cluster.main.name
    service_name = aws_ecs_service.order.name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [aws_lb_listener.order.arn]
      }
      target_group {
        name = aws_lb_target_group.order.name
      }
      target_group {
        name = aws_lb_target_group.order.name
      }
    }
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }
}