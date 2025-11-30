provider "aws" {
  region = var.region
}

resource "aws_iam_service_linked_role" "eb" {
  aws_service_name = "elasticbeanstalk.amazonaws.com"
  count = var.ebrolecreate == 1 ? 1 : 0
}

resource "aws_elastic_beanstalk_application" "eb" {
  name = var.app_name
  tags = {
    ManagedBy = "Terraform"
  }

  appversion_lifecycle {
    service_role          = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/elasticbeanstalk.amazonaws.com/AWSServiceRoleForElasticBeanstalk" #var.ebrolecreate == 1 ? aws_iam_service_linked_role.eb[0].arn : data.aws_iam_role.beanstalk[0].arn
    max_count             = 150
    delete_source_from_s3 = true
  }
}

resource "aws_s3_bucket" "AppVersionBucket" {
  count  = var.create_custom_appversion == true ? 1 : 0
  bucket = "${var.app_name}-${var.app_env}-applicationversion"
  tags = {
    ManagedBy = "Terraform"
  }
}

resource "aws_s3_object" "AppVersionObject" {
  count  = var.create_custom_appversion == true ? 1 : 0
  bucket = aws_s3_bucket.AppVersionBucket[0].id
  key    = "${var.app_name}-${var.app_env}/ebdefault.zip"
  source = data.archive_file.appversionzip[0].output_path #"${path.module}/files/ebdefault.zip"
  etag   = data.archive_file.appversionzip[0].output_md5
}

resource "aws_elastic_beanstalk_application_version" "eb-version" {
  count       = var.create_custom_appversion == true ? 1 : 0
  name        = "ebdefault-1"
  application = aws_elastic_beanstalk_application.eb.name
  description = "application version created by terraform"
  bucket      = aws_s3_bucket.AppVersionBucket[0].id
  key         = aws_s3_object.AppVersionObject[0].id
  tags = {
    ManagedBy = "Terraform"
  }
}

resource "local_file" "appversionfile" {
  count    = var.create_custom_appversion == true ? 1 : 0
  content  = var.docker_json
  filename = "${path.module}/files/Dockerrun.aws.json"
}

