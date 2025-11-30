data "aws_vpcs" "vpcs" {
  tags = {
    Name = "shared-${var.app_env}"
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


data "aws_availability_zones" "name" {}

data "aws_ami" "non-pci" {
  count       = var.pcicompliant == true ? 0 : 1
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "name"
    values = ["*eb_docker_amazon_linux_2-hvm-*"]
  }

}