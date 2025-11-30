resource "aws_ecs_task_definition" "squire_app_task" {
  count                    = var.task_definition_arn == "" && !var.use_latest_task_definition ? 1 : 0
  depends_on               = [aws_cloudwatch_log_group.ecs_task_logger[0]]
  family                   = "${var.ecs_name}-${var.env}-task"
  network_mode             = var.network_mode
  requires_compatibilities = [var.launch_type]
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  cpu                      = var.task_level_cpu
  memory                   = var.task_level_memory

  container_definitions = jsonencode([
    {
      "name" : "${var.ecs_name}-${var.env}-app"
      "image" : var.ecs_task_image
      "essential" : true
      "memoryReservation" : var.ecs_task_memory
      "cpu" : var.ecs_task_cpu

      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-group" : local.log_group_name,
          "awslogs-region" : var.region,
          "awslogs-stream-prefix" : "${var.ecs_name}-${var.env}"
        }
      }

      "portMappings" : [
        {
          "containerPort" : var.ecs_containerPort,
          "hostPort" : var.ecs_hostPort
        },
      ]

      "healthCheck" : {
        "command" : [
          "CMD-SHELL",
          "curl -f http://localhost:3000/ || exit 1"
        ],
        "interval" : 30,
        "timeout" : 10,
        "retries" : 3,
        "startPeriod" : 90
      }
    }
  ])
}