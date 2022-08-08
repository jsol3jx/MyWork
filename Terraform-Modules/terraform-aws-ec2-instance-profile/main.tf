provider "aws" {
  region = var.region
}

#instance role
resource "aws_iam_role" "ec2_role" {
  name               = "${var.instance_profile_name}-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
      "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

#instance profile
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name  = var.instance_profile_name
  role = "${aws_iam_role.ec2_role.id}"
}

#Attach Policies to Instance Role
resource "aws_iam_policy_attachment" "ssm_policy" {
  name       = "${var.instance_profile_name}-ssm-policy-attachment"
  roles      = [aws_iam_role.ec2_role.id]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_policy_attachment" "ec2ssm_policy" {
  name       = "${var.instance_profile_name}-ec2ssm-policy-attachment"
  roles      = [aws_iam_role.ec2_role.id]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}
