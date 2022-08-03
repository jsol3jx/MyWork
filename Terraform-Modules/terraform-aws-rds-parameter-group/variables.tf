#variable "create" {
#  description = "Whether to create this resource or not?"
#  type        = bool
#  default     = true
#}

variable "parameter_group_name" {
  description = "The name of the DB parameter group"
  type        = string
  default     = ""
}
variable "parameter_group_description" {
  description = "The description of the DB parameter group"
  type        = string
  default     = ""
}

variable "parameter_group_family" {
  description = "The family of the DB parameter group"
  type        = string
  default     = ""
}

#variable "rds_group_parameters" {
#description = "A list of DB parameter maps to apply"
#type        = list(map(string))
#default = [ ]
#}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default = {
    ManagedBy : "Terraform"
  }
}