output "s3_bucket_name" {
  value = aws_s3_bucket.s3_bucket.bucket
}

output "cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.foo_cf.id
}

output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.foo_cf.domain_name
}