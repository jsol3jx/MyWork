variable "distribution_hostname" {
  description = "Hostname for the CloudFront distribution"
  type        = string
}

variable "domain_name" {
  description = "Base domain name"
  type        = string
}

variable "default_root_object" {
  description = "Default root object (like index.html)"
  type        = string
  default     = "index.html"
}

variable "enabled" {
  description = "Whether the distribution is enabled"
  type        = bool
  default     = true
}

variable "is_ipv6_enabled" {
  description = "Enable IPv6 for distribution"
  type        = bool
  default     = true
}

variable "price_class" {
  description = "CloudFront price class"
  type        = string
  default     = "PriceClass_All"
}

variable "retain_on_delete" {
  description = "Keep distribution on destroy"
  type        = bool
  default     = false
}

variable "wait_for_deployment" {
  description = "Wait until CloudFront is deployed"
  type        = bool
  default     = false
}

variable "minimum_protocol_version" {
  description = "Minimum TLS protocol version"
  type        = string
  default     = "TLSv1.2_2021"
}

variable "ssl_enabled" {
  description = "Enable SSL using an external ACM certificate"
  type        = bool
  default     = false
}

variable "ssl_certificate_arn" {
  description = "ARN of the ACM certificate for CloudFront (required if ssl_enabled = true)"
  type        = string
  default     = ""
}

variable "zone_id" {
  description = "Route53 Hosted Zone ID for the domain"
  type        = string
  default     = ""
}

variable "tags" {
  type = map(string)
  default = {
    ManagedBy = "Terraform"
  }
}
