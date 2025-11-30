variable "region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "domain_name" {
  description = "Primary domain name for the certificate"
  type        = string
}

variable "zone_id" {
  description = "Hosted zone ID for DNS validation records"
  type        = string
}
