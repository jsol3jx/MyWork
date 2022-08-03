data "aws_acm_certificate" "issued" {
  count    = var.cert_create == 0 ? 1 : 0
  domain   = "example.com"
  statuses = ["ISSUED"]
}

data "aws_canonical_user_id" "current" {}

data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${module.s3_one.s3_bucket_arn}/${var.path_pattern}"]

    principals {
      type        = "AWS"
      identifiers = module.cloudfront.cloudfront_origin_access_identity_iam_arns
    }
  }
  statement {
    actions   = ["s3:*"]
    resources = ["${module.s3_one.s3_bucket_arn}"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::###:user/user"]

    }
  }
}