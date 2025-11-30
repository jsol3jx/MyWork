data "aws_caller_identity" "current" {}

data "aws_region" "current" {}



data "aws_vpcs" "vpcs" {
  tags = {
    Name = "shared-${var.env}"
  }
}



data "aws_vpc" "vpc" {
  id = tolist(data.aws_vpcs.vpcs.ids)[0]
}

data "aws_subnets" "private_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }

  tags = {
    Name = "*private*"
  }
}

data "aws_subnets" "public_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }

  tags = {
    Name = "*public*"
  }
}

data "aws_subnets" "db_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }

  tags = {
    Name = "*-db-*"
  }
}

data "aws_availability_zones" "name" {}


data "aws_ami" "ecs" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

####### IAM Data Lookups ########

data "aws_iam_policy" "ecs_instance_role_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

data "aws_iam_policy_document" "ecs_instance_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy" "ecs_task_execution_role_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "ecs_execution_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy" "AmazonSSMManagedInstanceCore" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

data "aws_iam_policy" "AmazonSSMPatchAssociation" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMPatchAssociation"
}

###### ECS Task Definition Auto-Detection ########

# Auto-detect the latest task definition for the service if it exists
data "aws_ecs_task_definition" "latest" {
  count           = var.use_latest_task_definition ? 1 : 0
  task_definition = "${var.ecs_name}-${var.env}-task"

  # Note: No depends_on here - we want to find the actual latest task definition
  # deployed by external tools like Harness, not force creation of our own
}