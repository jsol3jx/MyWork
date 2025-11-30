resource "aws_launch_template" "ecs_launch_template" {
  name                   = "${var.ecs_name}-${var.env}-asg-launch-template"
  image_id               = data.aws_ami.ecs.id
  vpc_security_group_ids = [aws_security_group.ecs_sg.id]
  user_data              = base64encode("#!/bin/bash\necho ECS_CLUSTER=${aws_ecs_cluster.cluster.name} >> /etc/ecs/ecs.config")
  instance_type          = var.instance_type

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_instance_role_profile.name
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_type           = var.volume_type
      volume_size           = var.volume_size
      iops                  = var.volume_iops
      throughput            = var.volume_throughput
      encrypted             = var.encrypted_volume
      delete_on_termination = var.delete_on_termination
    }
  }
}

resource "aws_autoscaling_group" "ecs_asg" {
  name                      = "${var.ecs_name}-${var.env}-asg-${random_string.asg.result}"
  vpc_zone_identifier       = data.aws_subnets.private_subnets.ids
  min_size                  = var.min_size
  max_size                  = var.max_size
  desired_capacity          = var.desired_capacity
  health_check_grace_period = 300
  health_check_type         = var.health_check_type #"ELB"

  launch_template {
    id      = aws_launch_template.ecs_launch_template.id
    version = aws_launch_template.ecs_launch_template.latest_version
  }

  instance_refresh {
    strategy = var.instance_refresh_strategy
    preferences {
      min_healthy_percentage = 50
      instance_warmup        = 300
    }
  }

  tag {
    key                 = "Name"
    value               = "${var.ecs_name}-${var.env}-ecs-instance"
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = var.tags

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}

resource "random_string" "asg" {
  length  = 3
  upper   = false
  lower   = true
  special = false
  keepers = {
    # Only generate a new random string when these attributes change
    min_size         = var.min_size
    max_size         = var.max_size
    desired_capacity = var.desired_capacity
  }
}