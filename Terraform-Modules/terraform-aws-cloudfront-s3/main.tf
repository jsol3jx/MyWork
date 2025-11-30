provider "aws" {
  region = "us-east-1" # CloudFront expects ACM resources in us-east-1 region only
}


#########################################
# CloudFront Function (Trailing Slash)
#########################################

resource "aws_cloudfront_function" "remove_trailing_slash" {
  name    = "${var.distribution_hostname}-remove-trailing-slash"
  runtime = "cloudfront-js-1.0"
  comment = "Redirect URLs that end with a trailing slash to the non-trailing-slash version (301)"

  # load the function code from the functions folder
  code = file("${path.module}/functions/remove_trailing_slash.js")
}

resource "aws_cloudfront_origin_access_identity" "this" {
  comment = "Access identity for CloudFront to reach ${aws_s3_bucket.s3_bucket.id}"
}


#############
# S3 bucket
#############

resource "aws_s3_bucket" "s3_bucket" {
  bucket = local.fqdn
  tags   = var.tags
}

resource "aws_s3_bucket_public_access_block" "s3_public_access_block" {
  bucket                  = aws_s3_bucket.s3_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "s3_ownership" {
  bucket = aws_s3_bucket.s3_bucket.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_object" "folders" {
  for_each = toset(compact(local.folders))

  bucket  = aws_s3_bucket.s3_bucket.id
  key     = each.value
  content = "" # empty object to represent a folder
}

resource "aws_s3_object" "files" {
  for_each = { for f in local.files : f => f }

  bucket       = aws_s3_bucket.s3_bucket.id
  key          = each.key
  source       = "${path.module}/files/${each.value}"
  etag         = filemd5("${path.module}/files/${each.value}")
  content_type = "text/html"
}

#########################################
# S3 Bucket Policy
#########################################

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.s3_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontReadOnly"
        Effect = "Allow"
        Principal = {
          AWS = aws_cloudfront_origin_access_identity.cf_access_id.iam_arn
        }
        Action   = ["s3:GetObject"]
        Resource = "${aws_s3_bucket.s3_bucket.arn}/*"
      }
    ]
  })
}

###########################
# Origin Access Identities
###########################

resource "aws_cloudfront_origin_access_identity" "cf_access_id" {
  comment = "Access identity for CloudFront to reach ${aws_s3_bucket.s3_bucket.id}"
}

#########################################
# CloudFront Distribution
#########################################

resource "aws_cloudfront_distribution" "foo_cf" {
  enabled             = var.enabled
  is_ipv6_enabled     = var.is_ipv6_enabled
  comment             = "${local.fqdn} CloudFront Distribution"
  default_root_object = var.default_root_object
  price_class         = var.price_class
  retain_on_delete    = var.retain_on_delete
  wait_for_deployment = var.wait_for_deployment

  aliases = [local.fqdn]

  origin {
    domain_name = aws_s3_bucket.s3_bucket.bucket_regional_domain_name
    origin_id   = "s3-origin"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.cf_access_id.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    target_origin_id       = "s3-origin"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6" # Managed-CachingOptimized policy

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.remove_trailing_slash.arn
    }
  }

  viewer_certificate {
    # Clean conditional SSL handling
    acm_certificate_arn            = var.ssl_enabled ? var.ssl_certificate_arn : null
    ssl_support_method             = var.ssl_enabled ? "sni-only" : null
    minimum_protocol_version       = var.minimum_protocol_version
    cloudfront_default_certificate = var.ssl_enabled ? false : true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = var.tags
}

#########################################
# Route53 Alias Record
#########################################

resource "aws_route53_record" "cloudfront_alias" {
  zone_id = var.zone_id
  name    = local.fqdn
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.foo_cf.domain_name
    zone_id                = aws_cloudfront_distribution.foo_cf.hosted_zone_id
    evaluate_target_health = false
  }
}
