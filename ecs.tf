# =============================================================================
# ECS Cluster, CloudWatch Log Groups, Task Definitions and Services
# =============================================================================

# =============================================================================
# ECS Cluster
# =============================================================================
resource "aws_ecs_cluster" "primary" {
  name = "${local.name_prefix}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-cluster"
  })
}




# =============================================================================
# CloudWatch Logs Groups for ECS Containers
# =============================================================================
resource "aws_cloudwatch_log_group" "product" {
  name              = "/ecs/${local.name_prefix}-product"
  retention_in_days = 7

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-product-logs"
  })
}

resource "aws_cloudwatch_log_group" "order" {
  name              = "/ecs/${local.name_prefix}-order"
  retention_in_days = 7

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-order-logs"
  })
}

# =============================================================================
# Product Task Definition
# =============================================================================
resource "aws_ecs_task_definition" "product" {
  family                   = "${local.name_prefix}-product"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([{
    name      = "product"
    image     = "${aws_ecr_repository.product.repository_url}:latest"
    essential = true

    portMappings = [{
      containerPort = var.container_port
      hostPort      = var.container_port
      protocol      = "tcp"
    }]

    # =================Environment variables injected into the container=======================
    environment = [
      {
        name  = "TABLE_NAME"
        value = aws_dynamodb_table.transactions.name
      },
      {
        name  = "AWS_REGION"
        value = var.aws_region
      },
      {
        name  = "ALLOWED_ORIGIN"
        value = "*"
      },
      {
        name  = "PORT"
        value = tostring(var.container_port)
      }
    ]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.product.name
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "product"

      }
    }
  }])

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-product-task"
  })
}

# =============================================================================
# Order Task Definition
# =============================================================================
resource "aws_ecs_task_definition" "order" {
  family                   = "${local.name_prefix}-order"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([{
    name      = "order"
    image     = "${aws_ecr_repository.order.repository_url}:latest"
    essential = true

    portMappings = [{
      containerPort = var.container_port
      hostPort      = var.container_port
      protocol      = "tcp"
    }]

    # =================Environment variables injected into the container=======================
    environment = [
      {
        name  = "TABLE_NAME"
        value = aws_dynamodb_table.transactions.name
      },
      {
        name  = "AWS_REGION"
        value = var.aws_region
      },
      {
        name  = "ALLOWED_ORIGIN"
        value = "*"
      },
      {
        name  = "PORT"
        value = tostring(var.container_port)
      }
    ]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.order.name
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "order"

      }
    }
  }])

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-order-task"
  })
}

# =============================================================================
# Product ECS Service
# =============================================================================
resource "aws_ecs_service" "product" {
  name            = "${local.name_prefix}-product"
  cluster         = aws_ecs_cluster.primary.id
  task_definition = aws_ecs_task_definition.product.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = aws_subnet.public[*].id
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.product.arn
    container_name   = "product"
    container_port   = var.container_port
  }

  depends_on = [aws_lb_listener.product]

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-product"
  })

  # Ignore desired_count changes made by auto-scaling
  lifecycle {
    ignore_changes = [desired_count]
  }
}

# =============================================================================
# Order ECS Service
# =============================================================================
resource "aws_ecs_service" "order" {
  name            = "${local.name_prefix}-order"
  cluster         = aws_ecs_cluster.primary.id
  task_definition = aws_ecs_task_definition.order.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = aws_subnet.public[*].id
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.order.arn
    container_name   = "order"
    container_port   = var.container_port
  }

  depends_on = [aws_lb_listener.order]

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-order"
  })

  # Ignore desired_count changes made by auto-scaling
  lifecycle {
    ignore_changes = [desired_count]
  }
}






