variable "region" {
  default = "us-east-2"
}

variable "app_name" {
  description = "Name for the Elastic Beanstalk Application"
}

variable "app_env" {
  description = "Name for the Elastic Beanstalk environment (prod, sandbox, dev, qa, or staging)"
}