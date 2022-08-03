provider "aws" {
  region = "us-east-1" # CloudFront expects ACM resources in us-east-1 region only

  # Make it faster by skipping something
  skip_get_ec2_platforms      = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_credentials_validation = true

  # skip_requesting_account_id should be disabled to generate valid ARN in apigatewayv2_api_execution_arn
  skip_requesting_account_id = false
}
provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

module "cloudfront" {
  source = "terraform-aws-modules/cloudfront/aws"

  aliases = ["${var.distribution_hostname}.${local.domain_name}"]

  enabled             = var.enabled
  is_ipv6_enabled     = var.is_ipv6_enabled
  price_class         = var.price_class
  retain_on_delete    = var.retain_on_delete
  wait_for_deployment = var.wait_for_deployment
  default_root_object = var.default_root_object
  tags                = var.tags


  # When you enable additional metrics for a distribution, CloudFront sends up to 8 metrics to CloudWatch in the US East (N. Virginia) Region.
  # This rate is charged only once per month, per metric (up to 8 metrics per distribution). 
  create_monitoring_subscription = false

  create_origin_access_identity = var.create_origin_access_identity
  origin_access_identities = {
    s3_bucket_one = "${var.distribution_hostname}-origin-identity"
  }

  origin = {
    s3_bucket = {
      domain_name = module.s3_one.s3_bucket_bucket_regional_domain_name
      s3_origin_config = {
        origin_access_identity = "s3_bucket_one"
      }
    }
  }

  custom_error_response = {
    error400 = {
      error_code            = 400
      error_caching_min_ttl = var.error_caching_min_ttl
      response_code         = 200
      response_page_path    = var.error_path_pattern
    },
    error403 = {
      error_code            = 403
      error_caching_min_ttl = var.error_caching_min_ttl
      response_code         = 200
      response_page_path    = var.error_path_pattern
    },
    error404 = {
      error_code            = 404
      error_caching_min_ttl = var.error_caching_min_ttl
      response_code         = 200
      response_page_path    = var.error_path_pattern
    },
    error405 = {
      error_code            = 405
      error_caching_min_ttl = var.error_caching_min_ttl
      response_code         = 200
      response_page_path    = var.error_path_pattern
    }
  }

  default_cache_behavior = {
    target_origin_id       = "s3_bucket"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]
    compress        = false
    query_string    = false
  }

  ordered_cache_behavior = [
    {
      path_pattern           = var.path_pattern
      target_origin_id       = "s3_bucket"
      viewer_protocol_policy = "redirect-to-https"

      allowed_methods = ["GET", "HEAD"]
      cached_methods  = ["GET", "HEAD"]
      compress        = true
      query_string    = true

    }
  ]

  viewer_certificate = {
    #count                    = var.cert_create == 1 ? 1 : data.aws_acm_certificate.issued[0].arn
    acm_certificate_arn      = var.cert_create == 0 ? data.aws_acm_certificate.issued[0].arn : module.cert[0].cert_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = var.minimum_protocol_version
  }
}

#############
# S3 buckets
#############



module "s3_one" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 2.0"

  bucket                  = "${var.distribution_hostname}.${local.domain_name}"
  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
  force_destroy           = true
}


###########################
# Origin Access Identities
###########################

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = module.s3_one.s3_bucket_id
  policy = data.aws_iam_policy_document.s3_policy.json
}

#######
# ACM #
#######

module "cert" {
  source               = "example"
  count                = var.cert_create == 1 ? 1 : 0
  version              = "0.1.3"
  cloudflare_api_token = var.cloudflare_api_token
  domain_name          = "*.${local.domain_name}"
  dns_validation       = var.dns_validation
}
module "dns" {
  source      = "example"
  version     = "0.0.7"
  destination = module.cloudfront.cloudfront_distribution_domain_name
  api_token   = var.cloudflare_api_token
  hostname    = "${var.distribution_hostname}.${local.domain_name}"
  proxied     = true
}