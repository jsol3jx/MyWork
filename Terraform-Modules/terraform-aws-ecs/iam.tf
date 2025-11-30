resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "${var.ecs_name}-${var.env}-ecsTaskExecutionRole"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.ecs_execution_role_policy.json
}

resource "aws_iam_policy" "ecs_ssm_parameter_access" {
  name = "ECSParameterStoreAccess"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath",
          "ssm:GetParameterHistory"
        ],
        Resource = "arn:aws:ssm:*:*:parameter/*"
      },
      {
        Effect = "Allow",
        Action = [
          "ssm:DescribeParameters"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "ecs_ecr_access" {
  name        = "ECSECRAccess"
  description = "Allows ECS tasks to pull images from ECR"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "ecr:GetAuthorizationToken"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "ecs_secrets_manager_access" {
  name        = "ECSSecretsManagerAccess"
  description = "Allows ECS tasks to retrieve secrets from AWS Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ],
        Resource = "arn:aws:secretsmanager:*:*:secret:*"
      }
    ]
  })
}

resource "aws_iam_policy" "ecs_kms_access" {
  name        = "ECSKMSAccess"
  description = "Allows ECS tasks to decrypt KMS-encrypted secrets"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey"
        ],
        Resource = "*"
      }
    ]
  })
}

######### Policy Attachments #########

resource "aws_iam_role_policy_attachment" "ecs_ssm_parameter_access_attach" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecs_ssm_parameter_access.arn
}

resource "aws_iam_role_policy_attachment" "ecs_logging_attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecs_logging_policy.arn
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionPolicy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = data.aws_iam_policy.ecs_task_execution_role_policy.arn
}

resource "aws_iam_role_policy_attachment" "ecs_ecr_access_attach" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecs_ecr_access.arn
}

resource "aws_iam_role_policy_attachment" "ecs_secrets_manager_access_attach" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecs_secrets_manager_access.arn
}

resource "aws_iam_role_policy_attachment" "ecs_kms_access_attach" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecs_kms_access.arn
}


resource "aws_iam_role_policy_attachment" "ecs_instance_policy" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = data.aws_iam_policy.ecs_instance_role_policy.arn
}


######### Instance Role #########
resource "aws_iam_role" "ecs_instance_role" {
  name               = "${var.ecs_name}-${var.env}-ecsInstanceRole"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.ecs_instance_role_policy.json
}

resource "aws_iam_instance_profile" "ecs_instance_role_profile" {
  name = aws_iam_role.ecs_instance_role.name
  role = aws_iam_role.ecs_instance_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonSSMManagedInstanceCore" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = data.aws_iam_policy.AmazonSSMManagedInstanceCore.arn
}

resource "aws_iam_role_policy_attachment" "AmazonSSMPatchAssociation" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = data.aws_iam_policy.AmazonSSMPatchAssociation.arn
}

resource "aws_iam_role_policy_attachment" "ECSParameterStoreAccess" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = aws_iam_policy.ecs_ssm_parameter_access.arn
}