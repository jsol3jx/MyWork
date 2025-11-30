# --- CloudWatch Log Group for ECS Task Logs ---
resource "aws_cloudwatch_log_group" "ecs_task_logger" {
  count = var.create_log_group ? 1 : 0

  name              = "${var.logs_group}${var.ecs_name}-${var.env}"
  retention_in_days = var.log_retention_period
  tags              = var.tags
}

# --- Alternative log group for when create_log_group is false ---
# This allows referencing the log group even when not created by Terraform
data "aws_cloudwatch_log_group" "existing_log_group" {
  count = var.create_log_group ? 0 : 1
  name  = "${var.logs_group}${var.ecs_name}-${var.env}"
}

# --- IAM Policy for CloudWatch Logs Access ---
resource "aws_iam_policy" "ecs_logging_policy" {
  name        = "ECSCloudWatchLogsAccess"
  description = "Allows ECS tasks to write logs to CloudWatch"
  path        = "/"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "ECSLogsWrite",
        Effect = "Allow",
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:*:*:log-group:${var.logs_group}${var.ecs_name}-${var.env}:*"
      },
      {
        Sid    = "ECSLogsGroup",
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup"
        ],
        Resource = "*"
      }
    ]
  })
}  