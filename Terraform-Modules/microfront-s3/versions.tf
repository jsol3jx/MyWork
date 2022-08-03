terraform {
  required_version = ">= 0.13"

  required_providers {
    aws    = ">= 3.48" #2.26.1
    random = "~> 2"
    null   = "~> 2"
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "2.26.1"
    }
  }
}