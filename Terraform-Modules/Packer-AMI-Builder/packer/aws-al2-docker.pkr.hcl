variable "region" {
  description = "AWS Region where the AMI will be created."
  type        = string
  default     = env("AWS_REGION")

  validation {
    condition     = length(var.region) > 0
    error_message = "The 'region' var is not set. Make sure to set it or set the 'AWS_REGION' env var."
  }
}

variable "ami_regions" {
  description = "A string of comma separated list of additional AWS Regions to copy the AMI to."
  type        = string
  default     = ""
}

variable "ami_users" {
  description = "A string of comma separated list of Accounts' ARNs to share the AMI with."
  type        = string
  default     = ""
}

variable "ami_org_arns" {
  description = "A string of comma separated list of Organizations' ARNs to share the AMI with."
  type        = string
  default     = ""
}

variable "ami_ou_arns" {
  description = "A string of comma separated list of Organizational Units' ARNs to share the AMI with."
  type        = string
  default     = ""
}

variable "ami_prefix" {
  description = "A string to prefix the name of the AMI."
  type        = string
  default     = "AWS-Docker-AL2-64bit"
}

variable "ami_description" {
  description = "Description of the created AMI."
  type        = string
  default     = "Custom AMI based on Amazon Linux 2 with Docker and several agents"
}

variable "instance_type" {
  description = "Instance Type for the temporary EC2 instance."
  type        = string
  default     = "t3.small"
}

variable "iam_instance_profile" {
  description = "Instance Profile for the temporary EC2 instance."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID within which to run the temporary EC2 instance."
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID within which to run the temporary EC2 instance."
  type        = string
}

variable "security_group_id" {
  description = "Security Group ID to assign to the temporary EC2 instance."
  type        = string
}

variable "s3_bucket" {
  description = "S3 bucket name used to access the agent files."
  type        = string
}

variable "secretsmanager_secret" {
  description = "Secret Manager's secret used to access tokens."
  type        = string
}

variable "deprecate_ami_days" {
  description = "Days from the date the AMI is built to deprecate it (0 to disable deprecation)."
  type        = number
  default     = 0
}

locals {
  timestamp = formatdate("YYYYMMDDhhmmss", timestamp())
}

variable "volume_type" {
  description = "Disk type to run the temporary EC2 instance."
  type        = string
  default     = "gp3"
}

variable "volume_size" {
  description = "Disk size in which to run the temporary EC2 instance."
  type        = number
  default     = 50
}

variable "iops" {
  description = "Days from the date the AMI is built to deprecate it (0 to disable deprecation)."
  type        = number
  default     = 3000
}

source "amazon-ebs" "docker_al2" {
  ami_name             = "${var.ami_prefix}-${local.timestamp}"
  ami_description      = var.ami_description
  instance_type        = var.instance_type
  region               = var.region
  ami_regions          = var.ami_regions != "" ? split(",", replace(var.ami_regions, " ", "")) : []
  ami_users            = var.ami_users != "" ? split(",", replace(var.ami_users, " ", "")) : []
  ami_org_arns         = var.ami_org_arns != "" ? split(",", replace(var.ami_org_arns, " ", "")) : []
  ami_ou_arns          = var.ami_ou_arns != "" ? split(",", replace(var.ami_ou_arns, " ", "")) : []
  iam_instance_profile = var.iam_instance_profile
  vpc_id               = var.vpc_id
  subnet_id            = var.subnet_id
  security_group_ids   = [var.security_group_id]
  ssh_username         = "ec2-user"
  ssh_timeout          = "5m"
  deprecate_at         = var.deprecate_ami_days != 0 ? "${timeadd(timestamp(), "${abs(var.deprecate_ami_days) * 24}h")}" : ""
  
 

  tags = {
    Name          = "SquireAMI"
    #Version       = "0.0.1"
    OSVersion     = "Amazon Linux 2 Docker"
    OSRelease     = "Latest"
    SourceAMIID   = "{{ .SourceAMI }}"
    SourceAMIName = "{{ .SourceAMIName }}"
    CreatedBy     = "Packer ${packer.version}"
    App1          = "CrowdStrike Falcon Agent"
    App2          = "Rapid7 Insight Agent"
  }

  source_ami_filter {
    filters = {
      name                = "aws-elasticbeanstalk-amzn-2.*.*eb_docker_amazon_linux_2-hvm-*" #"aws-elasticbeanstalk-amzn-2.*docker*" #
      root-device-type    = "ebs"
      virtualization-type = "hvm"
      architecture        = "x86_64"
    }

    most_recent = true
    owners      = ["amazon"]
  }

  launch_block_device_mappings {  
    device_name = "/dev/xvda"          
    volume_type = var.volume_type
    volume_size = var.volume_size
    iops        = var.iops
  }
  
}

build {
  sources = ["source.amazon-ebs.docker_al2"]

  provisioner "shell" {
    environment_vars = [
      "S3_BUCKET=${var.s3_bucket}",
      "CROWDSTRIKE_CID=${aws_secretsmanager(var.secretsmanager_secret, "CROWDSTRIKE_CID")}"
    ]

    scripts = fileset(".", "scripts/*")
  }
}