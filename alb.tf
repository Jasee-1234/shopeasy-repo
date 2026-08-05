# =============================================================================
# Application Load Balancers
# Creates:
# - Product Application Load Balancer
# - Order Application Load Balancer
# - Target Groups
# - HTTP Listeners
#
# HTTPS (ACM certificates) will be added in a later lesson once
# =============================================================================


# =============================================================================
# Product Load Balancer
# =============================================================================
resource "aws_lb" "product" {
  name               = "${local.name_prefix}-product-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.public[*].id

  enable_deletion_protection = false

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-product-alb"
  })
}

# =============================================================================
# Order Load Balancer
# =============================================================================

resource "aws_lb" "order" {
  name               = "${local.name_prefix}-order-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.public[*].id

  enable_deletion_protection = false

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-order-alb"
  })
}

# =============================================================================
# Product Target Group
# =============================================================================

resource "aws_lb_target_group" "product_blue" {

  name = "${local.name_prefix}-product-blue"

  port     = var.container_port
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  target_type = "ip"

  health_check {
    path = "/health"
  }

}


resource "aws_lb_target_group" "product_green" {

  name = "${local.name_prefix}-product-green"

  port     = var.container_port
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  target_type = "ip"

  health_check {
    path = "/health"
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-product-tg"
  })
}

# =============================================================================
# Order Target Group
# =============================================================================

resource "aws_lb_target_group" "order_blue" {

  name = "${local.name_prefix}-order-blue"

  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"
}

resource "aws_lb_target_group" "order_green" {

  name = "${local.name_prefix}-order-green"

  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-order-tg"
  })
}

# =============================================================================
# Product Listeners (HTTP)
# =============================================================================
resource "aws_lb_listener" "product" {
  load_balancer_arn = aws_lb.product.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.product_blue.arn
  }
}

# =============================================================================
# Order Listeners (HTTP)
# =============================================================================
resource "aws_lb_listener" "order" {
  load_balancer_arn = aws_lb.order.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.order_blue.arn
  }
}
