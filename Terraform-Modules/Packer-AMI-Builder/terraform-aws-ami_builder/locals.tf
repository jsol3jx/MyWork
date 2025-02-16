locals {
  full_name                 = "AMI-Builder-${var.name}"
  cloudwatch_log_group_name = "/arn/codebuild/${local.full_name}"
  cloudwatch_log_group_arn  = "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:${local.cloudwatch_log_group_name}"
  bucket_name = var.s3_bucket_name != "" ? var.s3_bucket_name : "ami-builder-${var.name}"

  packer_vars = {
    vpc_id                   = var.vpc_id
    subnet_id                = var.subnet_id
    security_group_id        = var.security_group_id
    aws_iam_instance_profile = aws_iam_instance_profile.ami_builder.identifiers
    s3_bucket                = local.bucket_name
    secretsmanager_secret    = aws_secretsmanager_secret.ami_builder.name
    deprecate_ami_days       = var.deprecate_ami_days
    ami_regions              = var.copy_ami_regions
    ami_users                = var.share_ami_accounts
    ami_org_arns             = var.share_ami_organizations
    ami_ou_arns              = var.share_ami_organizations_units
  }
}