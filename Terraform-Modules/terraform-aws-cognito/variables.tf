variable "eb_name" {
  description = "Name for the Elastic Beanstalk Application"
}

variable "eb_env" {
  description = "Name for the Elastic Beanstalk environment (prod, sandbox, dev, qa, or staging)"
}

variable "aws_region" {
  default = "us-west-1"
}
