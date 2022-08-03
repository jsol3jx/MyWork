provider "aws" {
  region = "us-west-1"
}

resource "aws_db_parameter_group" "default" {
  name        = var.parameter_group_name
  family      = var.parameter_group_family
  description = var.parameter_group_description

  dynamic "parameter" {
    for_each = jsondecode(file("${path.module}/parameters/parameters.json")) #var.rds_group_parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = lookup(parameter.value, "apply_method", null)
    }
  }

  tags = merge(
    var.tags,
    {
      "Name" = var.parameter_group_name
    },
  )

  lifecycle {
    create_before_destroy = true
  }
}