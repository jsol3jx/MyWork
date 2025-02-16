variable "region" {
  description = "AWS Region where resources will be deployed"
  type        = string
  default     = "us-west-1"
}

variable "name" {
  description = "Unique anme used for deployed resources"
  type        = string
}

variable "tags" {
  description = "Common tags for resources"
  type        = map(string)
  default     = {} #ie {"Environment"="dev". "Managedby"="Terraform"}
}

#https://docs.aws.amazon.com/codebuild/latest/userguid/build-env-ref-compute-types.html
variable "build_compute_type" {
  description = "Build env computer type"
  type        = string
  default     = "BUILD_GENERAL1_SMALL"
}

#https://docs.aws.amazon.com/codebuild/latest/userguid/build-env-ref-available.html
variable "build_image" {
  description = "Build env image"
  type        = string
  default     = "aws/codebuild/amazonlinux2-x86-64-standard:3.0"
}

variable "build_timeout" {
  description = "Build timeout in minutes"
  type        = number
  default     = 60

  validation {
    condition     = var.build_timeout >= 5 && var.build_timeout <= 480
    error_message = "The build_timeout's value must be between 5 and 480"
  }
}

#https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-create-rule-schedule.html
variable "schedules" {
  description = "Eventbridge cron expressions to run pipeline on creation schedule"
  type        = list(string)
  default     = [] # Example ["0 22 ? * SUN *", "0 12 ? * 7#1 *"]
}

variable "vpc_id" {
  description = "VPC ID that build will run in. Must have at least one private/public subnet"
  type        = string

  validation {
    condition     = can(regex("^vpc-", var.vpc_id))
    error_message = "The vpc_id's value must be a valid VPC ID in the form of vpc-"
  }
}

variable "subnet_id" {
  description = "Subnet ID for builds. Must be a private subnet with Internet Access via a NAT Gateway/Instance"
  type        = string

  validation {
    condition     = can(regex("^subnet-", var.subnet_id))
    error_message = "The subnet_id's value must be a valid Subnet ID in the form of subnet-"
  }
}

variable "security_group_id" {
  description = " SG ID for running builds. Must allow ingress port 22 traffic"
  type        = string

  validation {
    condition     = can(regex("^sg-", var.security_group_id))
    error_message = "The security_group_id's value must be a valid Subnet ID in the form of subnet-"
  }
}

variable "branch_name" {
  description = "Source code repo branch name"
  type        = string
  default     = "master"
}

variable "enable_push_trigger" {
  description = "Trigger pipeline when a change is pushed to the source code repo"
  type        = string
  default     = false
}

variable "bitbucket_repository" {
  description = "Bitbucket repo with Packer/Codebuild files in <account>/<repo-name> format"
  type        = string
}

#https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucketnamingrules.html
variable "s3_bucket_name" {
  description = "Creates a custom S3 bucket name instead of default"
  type        = string
  default     = ""
}

variable "s3_paths" {
  description = "Paths to create inside s3 bucket"
  type        = string
  default     = ""
}

#https://releases.hashicorp.com/packer
variable "packer_version" {
  description = "Packer version"
  type        = string
  default     = ""
}

#https://docs.aws.amazon.com/AWSEC2/lates/userguide/ami-deprecate.html
variable "deprecate_ami_days" {
  description = "Days since the date of AMI was built to deprecate it(disabled by default)"
  type        = number
  default     = 0

  validation {
    condition     = var.deprecate_ami_days >= 0 && var.deprecate_ami_days <= 3650
    error_message = "The deprecate_ami_days value must be between 0 and 3650"
  }
}

variable "copy_ami_regions" {
  description = "A string of comma seperated list of additional AWS Regions to copy ami to"
  type        = string
  default     = "" #IE "123456789012, 987654321012"
}

variable "share_ami_accounts" {
  description = "A string of comma seperated list of account ARNs to share the AMI with"
  type        = string
  default     = "" #IE "123456789012, 987654321012"
}

variable "share_ami_organizations" {
  description = "A string of comma seperated list of organizations ARNs to share the AMI with"
  type        = string
  default     = ""
}

variable "share_ami_organizations_units" {
  description = "A string of comma seperated list of organizations units ARNs to share the AMI with"
  type        = string
  default     = ""
}

variable "enable_notifications" {
  description = "Enable pipeline notifications to an SNS Topic (disabled by default)"
  type        = bool
  default     = false
}


variable "notification_events" {
  description = "Notifcation rules on pipeline events"
  type        = list(string)
  default = [
    "codepipeline-pipeline-pipeline-execution-failed",
    "codepipeline-pipeline-pipeline-execution-canceled",
    "codepipeline-pipeline-pipeline-execution-starteded",
    "codepipeline-pipeline-pipeline-execution-resumed",
    "codepipeline-pipeline-pipeline-execution-succeeded",
    "codepipeline-pipeline-pipeline-execution-superseded"
  ]
}