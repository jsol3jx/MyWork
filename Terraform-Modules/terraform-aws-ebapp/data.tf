/*
data "aws_iam_role" "beanstalk" {
  name       = "AWSServiceRoleForElasticBeanstalk"
  depends_on = [aws_iam_service_linked_role.eb]
  count      = var.ebrolecreate == 0 ? 1 : 0
}
*/
data "archive_file" "appversionzip" {
  count       = var.create_custom_appversion == true ? 1 : 0
  type        = "zip"
  source_file = local_file.appversionfile[0].filename
  output_path = "${path.module}/files/ebdefault.zip"
}

data "aws_caller_identity" "current" {}