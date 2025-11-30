variable "region" {
  default = "us-east-2"
}

variable "app_name" {
  description = "Name for the Elastic Beanstalk application"
}

variable "app_env" {
  description = "Name for the Elastic Beanstalk environment (prod, sandbox, dev, qa, or staging)"
}

variable "ebrolecreate" {
  default = 1
}

variable "docker_json" {
  description = "The file with the corresponding ecr uri for the docker image needed to run beanstalk deployment."
  default     = ""
}

variable "create_custom_appversion" {
  description = "If true, module will use a custom docker image for base beanstalk deployment"
  default     = false
}