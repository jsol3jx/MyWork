variable "cloudflare_api_token" {
  description = "Cloudflare API token"
  sensitive   = true
}

variable "default_root_object" {
  description = "The object that you want CloudFront to return (for example, index.html) when an end user requests the root URL."
  type        = string
  default     = null
}

variable "distribution_hostname" {
  description = "The object that you want CloudFront to return (for example, index.html) when an end user requests the root URL."
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to assign to the resource."
  type        = map(string)
  default = {
    ManagedBy : "Terraform"
  }
}

variable "create_origin_access_identity" {
  description = "Controls if CloudFront origin access identity should be created"
  type        = bool
  default     = true
}

variable "origin_access_identities" {
  description = "Map of CloudFront origin access identities (value as a comment)"
  type        = map(string)
  default     = {}
}
variable "enabled" {
  description = "Whether the distribution is enabled to accept end user requests for content."
  type        = bool
  default     = true
}

variable "is_ipv6_enabled" {
  description = "Whether the IPv6 is enabled for the distribution."
  type        = bool
  default     = null
}

variable "price_class" {
  description = "The price class for this distribution. One of PriceClass_All, PriceClass_200, PriceClass_100"
  type        = string
  default     = "PriceClass_All"
}

variable "retain_on_delete" {
  description = "Disables the distribution instead of deleting it when destroying the resource through Terraform. If this is set, the distribution needs to be deleted manually afterwards."
  type        = bool
  default     = false
}

variable "wait_for_deployment" {
  description = "If enabled, the resource will wait for the distribution status to change from InProgress to Deployed. Setting this tofalse will skip the process."
  type        = bool
  default     = false
}

variable "minimum_protocol_version" {
  description = "The minimum TLS version for this distribution. SSLv3, TLSv1,	TLSv1_2016,	TLSv1.1_2016, TLSv1.2_2018, TLSv1.2_2019, TLSv1.2_2021"
  type        = string
  default     = "null"
}

variable "path_pattern" {
  description = "Set your path pattern"
  type        = string
  default     = "null"
}

variable "error_path_pattern" {
  description = "Set your error page path pattern"
  type        = string
  default     = 0
}

variable "cert_create" {
  description = "Defines whether to create a certificate."
  type        = number
  default     = 1
}

variable "error_caching_min_ttl" {
  type = number
  default = 10
}

variable "dns_validation" {
  description = "Set true or false for DNS validation for Cert generation"
}