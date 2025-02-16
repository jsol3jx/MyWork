data "aws_caller_identity" "current" {}

data "aws_iam_roles" "admin_role_name" {
  name_regex = "AWSReservedSSO_AdministratorAccess.*"
}

data "aws_iam_roles" "platform_eng_role_name" {
  name_regex = "AWSReservedSSO_PlatformEngineerAccess.*"
}

data "aws_iam_roles" "poweruser_role_name" {
  name_regex = "AWSReservedSSO_PowerUserAccess.*"
}