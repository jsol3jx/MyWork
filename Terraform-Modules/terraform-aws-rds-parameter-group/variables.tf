variable "parameter_group_description" {
  description = "The description of the DB parameter group"
  type        = string
  default     = ""
}

variable "parameter_group_family" {
  description = "The family of the DB parameter group ie. postgres"
  type        = string
  default     = ""
}

variable "env" {
  description = "Name for the environment (prod, demo, staging, or qa)"
}

variable "app_name" {
  description = "capital, tokens, subscriptions, etc"
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default = {
    ManagedBy : "Terraform"
  }
}