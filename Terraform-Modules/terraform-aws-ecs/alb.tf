resource "aws_lb_target_group" "target_group" {
  name     = "${var.ecs_name}-${var.env}-tg-${random_string.suffix.result}"
  port     = var.tg_port
  protocol = var.tg_protocol
  vpc_id   = var.vpc_id

  load_balancing_algorithm_type = "round_robin"
  slow_start                    = 30
  target_type                   = var.alb_target_type

  health_check {
    enabled             = true
    healthy_threshold   = var.hc_healthy_threshold   #2
    interval            = var.hc_interval            #30
    matcher             = var.hc_matcher             #"200-399"
    path                = var.hc_path                #"/"
    port                = var.hc_port                #"traffic-port"
    protocol            = var.hc_protocol            #"HTTP"
    timeout             = var.hc_timeout             #10
    unhealthy_threshold = var.hc_unhealthy_threshold #3
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = var.tags
}

resource "aws_lb" "load_balancer" {
  name               = "${var.ecs_name}-${var.env}-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = data.aws_subnets.public_subnets.ids

  enable_deletion_protection = false

  enable_http2               = true
  drop_invalid_header_fields = var.lb_drop_invalid_header_fields

  tags = var.tags
}

resource "aws_lb_listener" "alb_target_listener_http" {
  count             = var.enable_ssl ? 0 : 1
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }

  depends_on = [aws_lb_target_group.target_group]

  tags = var.tags
}

resource "aws_lb_listener" "alb_target_listener_https" {
  count = var.enable_ssl ? 1 : 0

  load_balancer_arn = aws_lb.load_balancer.arn
  port              = "443"
  protocol          = "HTTPS"

  ssl_policy      = "ELBSecurityPolicy-2016-08"
  certificate_arn = var.ssl_certificate

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }

  tags = var.tags
}

resource "random_string" "suffix" {
  length  = 3
  upper   = false
  lower   = true
  special = false

  keepers = {
    # Only generate a new random string when these attributes change
    port                   = var.tg_port
    protocol               = var.tg_protocol
    target_type            = var.alb_target_type
    hc_path                = var.hc_path
    hc_port                = var.hc_port
    hc_protocol            = var.hc_protocol
    hc_matcher             = var.hc_matcher
    hc_timeout             = var.hc_timeout
    hc_interval            = var.hc_interval
    hc_healthy_threshold   = var.hc_healthy_threshold
    hc_unhealthy_threshold = var.hc_unhealthy_threshold
  }
}