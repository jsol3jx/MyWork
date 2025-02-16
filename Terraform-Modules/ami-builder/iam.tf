# IAM Codepipeline ROle
resource "aws_iam_role" "codepipeline_ami_builder" {
  name               = "Codepipeline${local.full_name}"
  assume_role_policy = data.aws_iam_policy_document.codepipeline_assume_role_policy.json
  path               = "/service-role"
}

resource "aws_iam_role_policy" "codepipeline_ami_builder" {
  name   = "Codepipeline${local.full_name}"
  role   = aws_iam_role.codepipeline_ami_buider.name
  policy = data.aws_iam_policy_document.codepipeline_policy.json
}

# IAM EC2 Role
resource "aws_iam_role" "ec2_ami_builder" {
  name               = "ec2${local.full_name}"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role_policy.json
}

resource "aws_iam_role_policy" "ec2_ami_builder" {
  name   = "ec2${local.full_name}"
  role   = aws_iam_role.ec2_ami_builder.name
  policy = data.aws_iam_policy_document.ec2_policy.json
}

resource "aws_iam_instance_profile" "ami_builder" {
  name = "ec2${local.full_name}"
  role = aws_iam_role.ec2_ami_builder.name
}

# IAM Eventbridge Role
resource "aws_iam_role" "eventbridge_ami_builder" {
  count              = length(var.schedules) > 0 ? 1 : 0
  name               = "Eventbridge${local.full_name}"
  assume_role_policy = data.aws_iam_policy_document.eventbridge_assume_role_policy.json
  path               = "/service-role/"
}

resource "aws_iam_role_policy" "ec2_ami_builder" {
  count  = length(var.schedules) > 0 ? 1 : 0
  name   = "Eventbridge${local.full_name}"
  role   = aws_iam_role.eventbridge_ami_builder[0].name
  policy = data.aws_iam_policy_document.eventbridge_policy.json
}