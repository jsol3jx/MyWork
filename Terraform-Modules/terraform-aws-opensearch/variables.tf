#provider "aws" {
#  region = var.region
#}

####################################################################################################
# Elasticsearch
####################################################################################################

variable "eb_name" {
  type        = string
  description = "Name for Elasticsearch domain, also used as prefix for related resources."
}

variable "eb_env" {
  type        = string
  description = "Environment Name for Elasticsearch domain, also used as prefix for related resources. Staging, Sandbox, QA, Demo, Prod"
}

variable "opensearch_version" {
  type    = string
  default = "7.10"
}

variable "create_service_role" {
  description = "Indicates whether to create the service-linked role. See https://docs.aws.amazon.com/opensearch-service/latest/developerguide/slr.html"
  type        = bool
  default     = true
}

variable "aos_data_instance_type" {
  description = "Data instance size."
  default     = " "
}
variable "aos_data_instance_storage" {
  type        = number
  description = 50
}
variable "aos_data_instance_count" {
  type    = number
  default = 2
}

variable "aos_master_instance_type" {
  type = string
}

variable "aos_master_instance_count" {
  type    = number
  default = 2
}

variable "aos_encrypt_at_rest" {
  type        = bool
  default     = true
  description = "Default is 'true'. Can be disabled for unsupported instance types."
}

variable "aos_zone_awareness_enabled" {
  type    = bool
  default = true
}

variable "aos_private_subnets" {
  type = list(string)
}

variable "aos_private_subnet_ids" {
  type = list(string)
}

variable "aos_ebs_enabled" {
  default = true
}

variable "aos_node_to_node_encryption" {
  default = true
}

variable "aos_enforce_https" {
  default = true
}

variable "aos_cognito_enabled" {
  description = "Is cognito authentication required?"
  default     = true
}

variable "kms_arn" {
  description = "KMS key ARN"
}

variable "loadbalancer_certificate_arn" {
  description = "The ARN for the certificate in ACM"
}

variable "identity_pool_id" {
  type    = string
  default = ""
}

variable "user_pool_id" {
  type    = string
  default = ""
}

####################################################################################################
# VPC
####################################################################################################
#variable "vpc_id" {
#  type = string
#}

#variable "proxy_inbound_cidr_blocks" {
#  type = list
#}

#variable "proxy_inbound_ipv6_cidr_blocks" {
#  type = list
#  default = []
#}