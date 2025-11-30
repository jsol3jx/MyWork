data "aws_canonical_user_id" "current" {}

# Lookup existing certificate by domain name
/*
data "aws_acm_certificate" "acm_cert" {
  domain   = "*.johnnyterraform.tech"
  statuses = ["ISSUED"]

  # optional: pick the most recent if multiple certs exist
  most_recent = true
}

data "aws_route53_zone" "main" {
  name         = var.domain_name
  private_zone = false
}

*/