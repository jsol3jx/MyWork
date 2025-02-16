# IAM Policy that grants CodePipeline Permssions to Assume role

data "aws_iam_policy_attachment" "assume_role_policy_codebuild" {
  statement {
    sid     = "1"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
  }
}

# IAM Policy to grant EC2 permission to assume role

data "aws_iam_policy_attachment" "ec2_assume_role_policy" {
  statement {
    sid     = "1"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# IAM Policy to grant EventBridge permission to assume role.data

data "aws_iam_policy_attachment" "ec2_assume_role_policy" {
  statement {
    sid     = "1"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

# IAM Policy for CodePipeline

data "aws_iam_policy_document" "codepipeline_policy" {
  statement {
    sid       = "1"
    actions   = ["codestar-connections:UseConnection"]
    resources = [aws_codestarconnections_connection.ami_builer.arn]
  }

  # Codebuild Project
  statement {
    sid = "2"

    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StarBuild"
    ]

    resources = [aws_codebuild_project.ami_builer.arn]
  }

  #S3 for Packer and Artifacts
  statement {
    sid = "3"

    actions = [
      "s3:list*",
      "s3:Object*",
      "s3:GetBucket*",
      "s3:PutObject*",
      "s3:DeleteObject*",
      "s3:Abort*"
    ]

    resources = [
      aws_s3_bucket.ami_builder.arn,
      "${aws_s3_bucket.ami_builder.arn}/*"
    ]
  }
}

# IAM Policy for Codebuild

data "aws_iam_policy_document" "codebuild_policy" {
  statement {
    sid = "1"

    actions = [
      "ec2:AttachVolume",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:CopyImage",
      "ec2:CreateImage",
      "ec2:CreateKeypair",
      "ec2:CreateSecurityGroup",
      "ec2:CreateSnapshot",
      "ec2:CreateTags",
      "ec2:CreateVolume",
      "ec2:DeleteKeypair",
      "ec2:DeleteSecurityGroup",
      "ec2:DeleteSnapshot",
      "ec2:DeleteVolume",
      "ec2:DeregisterImage",
      "ec2:DescribeImageAttribute",
      "ec2:DescribeImages",
      "ec2:DescribeInstances",
      "ec2:DescribeInstanceStatus",
      "ec2:DescibeRegions",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSnapshots",
      "ec2:DescribeSubnets",
      "ec2:DescribeTags",
      "ec2:DescribeVolumes",
      "ec2:DetachVolume",
      "ec2:GetPasswordData",
      "ec2:ModifyImageAttribute",
      "ec2:ModifyInstanceAttribute",
      "ec2:ModifySnapshotAttribute",
      "ec2:RegisterImage",
      "ec2:RunInstances",
      "ec2:StopInstances",
      "ec2:TerminateInstances",
      "ec2:EnableImageDeprecation",
      "ec2:CreateNetworkInterface",
      "ec2:DescribeDhcpOptions",
      "ec2:DeleteNetworkInterface",
      "ec2:DescribeVpcs"
    ]

    resources = ["*"]
  }

  #Cloudwatch Logs  
  statement {
    sid = "2"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      local.cloudwatch_log_group_arn,
      "${local.cloudwatch_log_group_arn}/*"
    ]
  }

  #S3 Packer & Artifacts
  statement {
    sid = "3"

    actions = [
      "S3:PutObjects",
      "S3:GetObject",
      "S3:GetObjectVersion",
      "S3:GetBucketAcl",
      "S3:GetBucketLocation"
    ]

    resources = [
      aws_s3_bucket.ami_builer.arn,
      "${aws_s3_bucket.ami_builer.arn}/*"
    ]
  }

  # VPC Info for Codebuild Project
  statement {
    sid       = "4"
    actions   = ["ec2.CreateNetworkInterfacePermissions"]
    resources = ["arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:network-interface/*"]

    condition {
      test     = "StringEquals"
      variable = "ec2:AuthorizeService"
      values   = ["codebuild.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "ec2:Subnet"
      values   = ["arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:subnet/${var.subnet_id}"]
    }
  }

  #Packer IAM instance profile support
  statement {
    sid       = "5"
    actions   = ["iam:GetInstanceProfile"]
    resources = [aws_iam_instance_profile.ami_builder.arn]
  }

  # Packer IAM instance profile support 2
  statement {
    sid = "6"
    actions = [
      "iam:GetRole",
      "iam:PassRole"
    ]
    resources = [aws.iam_role.ec2_ami_builder.arn]
  }

  # Packer secrets manager support
  statement {
    sid       = "7"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [aws_secretsmanager_secret.ami_builder.arn]
  }
}

# IAM POlicy for ec2
data "aws_iam_policy_document" "ec2_policy" {
  #For Temporary instance that is created for Packer to create image.
  statement {
    sid       = "1"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.ami_builder.arn}/agents/*"]
  }
}

#IAM Policy for EventBridge
data "aws_iam_policy_document" "eventbridge_policy" {
  #For Temporary instance that is created for Packer to create image.
  statement {
    sid       = "1"
    actions   = ["codepipeline:StartPipelineExecution"]
    resources = [aws_codepipeline.ami_builder.arn]
  }
}