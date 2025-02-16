variable "region" {
  default = "us-west-1"
}

variable "eb_name" {
  description = "Name for the Elastic Beanstalk application"
}

variable "eb_env" {
  description = "Name for the Elastic Beanstalk environment (prod, sandbox, dev, qa, or staging)"
}

variable "ec2_instance_profile_role_name" {
  description = "ec2_instance_profile_role_name"
}

variable "db_secret_arn" {
  description = "ARN of the AWS Secrets Manager Secret for the DB"
  type        = string
  default     = ""
}