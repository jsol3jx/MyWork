resource "aws_ecs_cluster" "cluster" {
  name = "${var.ecs_name}-${var.env}-cluster"

  tags = var.tags
}

resource "aws_ecs_service" "ecs_service" {
  name                               = "${var.ecs_name}-${var.env}-service"
  cluster                            = aws_ecs_cluster.cluster.id
  launch_type                        = var.launch_type
  task_definition                    = local.resolved_task_definition
  desired_count                      = var.desired_capacity
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  enable_ecs_managed_tags            = true
  health_check_grace_period_seconds  = var.health_check_grace_period
  force_new_deployment               = var.force_new_deployment

  ordered_placement_strategy {
    type  = "spread"
    field = "instanceId"
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.arn
    container_name   = "${var.ecs_name}-${var.env}-app"
    container_port   = var.lb_container_port
  }

  network_configuration {
    subnets          = data.aws_subnets.private_subnets.ids
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = false # Set to true if you're using public subnets
  }

  tags = {
    ManagedBy   = "Terraform"
    Application = var.ecs_name
    Environment = var.env
  }
}