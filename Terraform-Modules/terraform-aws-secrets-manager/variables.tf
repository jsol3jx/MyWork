variable "secret_name" {
  description = "Name of Secret"
  type        = map(string)
  default = {
    key1 = "",
    key2 = "",
    key3 = ""
  }
}
variable "region" {
  default = "us-west-1"
}

variable "secret_tag" {
  description = "The use case of the secret being created"
  default     = ""
}
variable "username" {
  description = "ID assigned to new password creation of each key"
  default     = ""
}

variable "password" {
  description = "The password associated with the username"
}

variable "recovery_window" {
  description = "How many days to keep before permanently deleted. 35 for Prod and 7 for everything else."
  default     = 7
}

variable "env" {
  description = "Name for the Elastic Beanstalk environment (prod, sandbox, dev, qa, or staging)"
}

variable "name" {
  description = "Name for the Elastic Beanstalk Application"
}

variable "kms_key_id" {
  description = " ARN or Id of the AWS KMS customer master key (CMK) to be used to encrypt the secret values in the versions stored in this secret"
  default     = null
}

variable "dbtype" {
  description = "When the env has two DBs such as app and vault, call this module twice and set this variable for each one"
  default     = "app"
}