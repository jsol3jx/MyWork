locals {
  resolved_task_definition = (
    var.task_definition_arn != ""
    ? var.task_definition_arn
    : (
      var.use_latest_task_definition
      ? data.aws_ecs_task_definition.latest[0].arn
      : aws_ecs_task_definition.squire_app_task[0].arn
    )
  )

  # Log group name - handles both Terraform-managed and external log groups
  log_group_name = var.create_log_group ? aws_cloudwatch_log_group.ecs_task_logger[0].name : data.aws_cloudwatch_log_group.existing_log_group[0].name
}