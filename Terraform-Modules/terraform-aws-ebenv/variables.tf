variable "region" {
  default = "us-east-2"
}

variable "app_name" {
  description = "Name for the Elastic Beanstalk application"
}

variable "app_env" {
  description = "Name for the Elastic Beanstalk environment (prod, sandbox, dev, qa, or staging)"
}

variable "env_num" {
  default     = 1
  description = "Number of environments to provision"
}

variable "key_name" {
  description = "Key name for the key-pair"
}

variable "loadbalancer_certificate_arn" {
  description = "The ARN for the certificate in ACM"
}

variable "instance_type" {
  default     = "t3.micro"
  description = "Instance type/size"
}

variable "ssh_source_restriction" {
  description = "String of comma-separated CIDRs from which to restrict SSH access"
}

variable "solution_stack_name" {
  default     = "64bit Amazon Linux 2 v3.4.0 running Docker"
  description = "Supported Beanstalk solution stack name"
}

variable "tier" {
  default = "WebServer"
}

variable "stage" {
  default = ""
}

variable "env_vars" {
  type        = map(any)
  default     = {}
  description = "Define any extra environment variables in EB"
}

variable "root_volume_size" {
  default     = 8
  description = "The size of the EBS root volume"
}

variable "autoscale_min" {
  default     = 2
  description = "Minimum number of instances"
}

variable "autoscale_max" {
  default     = 4
  description = "Maximum number of instances"
}

variable "http_listener_enabled" {
  default     = false
  description = "Enable port 80 true or false"
}

# variable "additional_settings" {
#   default = [
#     {
#       namespace = "aws:elasticbeanstalk:customoption"
#       name      = "CloudWatchMetrics"
#       value     = "--mem-util --mem-used --mem-avail --disk-space-util --disk-space-used --disk-space-avail --disk-path=/ --auto-scaling=only"
#     },
#     {
#       namespace = "aws:autoscaling:launchconfiguration"
#       name      = "SSHSourceRestriction"
#       value     = "tcp,22,22,${data.aws_vpc.vpc.cidr_block}"
#     },
#   ]
#   description = "additional settings"
# }
variable "additional_settings" {
  type = list(object({
    namespace = string
    name      = string
    value     = string
  }))

  default     = []
  description = "Additional Elastic Beanstalk setttings. For full list of options, see https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/command-options-general.html"
}

variable "managed_actions_enabled" {
  default     = true
  description = "Enable managed platform updates. When you set this to true, you must also specify a PreferredStartTime and UpdateLevel"
}

variable "ami_id" {
  default     = ""
  description = "Provide a custom AMI id if needed"
}

variable "autoscale_measure_name" {
  default = "NetworkOut"
}

variable "autoscale_lower_bound" {
  default = 2000000
}

variable "autoscale_upper_bound" {
  default = 6000000
}

variable "autoscale_statistic" {
  default = ""
}

variable "autoscale_unit" {
  default = "Bytes"
}

variable "autoscale_upper_increment" {
  default = 1
}

variable "pcicompliant" {
  default = false
}

variable "version_label" {
  description = "Setting a label will override the default beanstalk deployment from calling out to docker hub for a docker image."
  default     = ""
}

variable "healthcheck_url" {
  description = "Application Health Check URL. Elastic Beanstalk will call this URL to check the health of the application running on EC2 instances"
  default     = "/"
}

variable "extended_ec2_policy_document" {
  description = "Extensions or overrides for the IAM role assigned to EC2 instances"
  default     = "{}"
}

variable "healthcheck_httpcodes_to_match" {
  description = "Application Health Check URL. Elastic Beanstalk will call this URL to check the health of the application running on EC2 instances"
  default     = ["200"]
}

variable "security_group_name" {
  type        = list(string)
  default     = []
  description = <<-EOT
    The name to assign to the created security group. Must be unique within the VPC.
    If not provided, will be derived from the `null-label.context` passed in.
    If `create_before_destroy` is true, will be used as a name prefix.
    EOT
}

variable "eb_envname_override" {
  type        = string
  default     = null
  description = "Override the EB env name"
}

variable "go_private" {
  default     = false
  description = "Variable that will set the loadbalancers to use private subnets instead of using public."
}

variable "elb_scheme" {
  type        = string
  default     = "public"
  description = "Specify `internal` if you want to create an internal load balancer in your Amazon VPC so that your Elastic Beanstalk application cannot be accessed from outside your Amazon VPC"
}

variable "s3_bucket_access_log_bucket_name" {
  default     = ""
  description = "Name of the S3 bucket where s3 access log will be sent to"
}

variable "security_group_create_before_destroy" {
  type = bool

  default     = false
  description = <<-EOT
    Set `true` to enable Terraform `create_before_destroy` behavior on the created security group.
    We recommend setting this `true` on new security groups, but default it to `false` because `true`
    will cause existing security groups to be replaced, possibly requiring the resource to be deleted and recreated.
    Note that changing this value will always cause the security group to be replaced.
    EOT
}