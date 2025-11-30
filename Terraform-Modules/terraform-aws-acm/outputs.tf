# Outputs
output "cert_arn" {
  description = "ARN of the validated ACM certificate"
  value       = aws_acm_certificate_validation.cert_check.certificate_arn
}

output "validation_records" {
  description = "Route53 validation record FQDNs"
  value       = [for record in aws_route53_record.validation : record.fqdn]
}

