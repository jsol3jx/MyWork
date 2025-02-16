provider "aws" {
  region = "us-west-1"
}

resource "aws_db_parameter_group" "default" {
  name        = "${var.app_name}-app-${var.env}-pg12"
  family      = var.parameter_group_family
  description = var.parameter_group_description == "null" ? "${var.app_name}-${var.env}" : var.parameter_group_description

  dynamic "parameter" {
    for_each = jsondecode(file("${path.module}/parameters/parameters.json"))
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = lookup(parameter.value, "apply_method", null)
    }
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.app_name}-app-${var.env}-pg12"
      ManagedBy   = "Terraform"
      Application = var.app_name
      Environment = var.env
    },
  )

  lifecycle {
    create_before_destroy = true
  }
}