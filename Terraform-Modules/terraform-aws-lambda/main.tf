provider "aws" {
  region = var.aws_region
}

provider "archive" {}

resource "aws_iam_role" "lambda_iam_role" {
  name               = "${var.function_name}_iam_role"
  assume_role_policy = data.aws_iam_policy_document.lambda_iam_role_base_policy.json
}

resource "aws_iam_policy" "lambda_iam_policy" {
  name        = "${var.function_name}_iam_policy"
  path        = "/"
  description = "AWS IAM Policy for managing the ${var.function_name} IAM Lambda Role"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "arn:aws:logs:*:*:*",
            "Effect": "Allow"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_iam_role_policy_attachment" {
  role       = aws_iam_role.lambda_iam_role.name
  policy_arn = aws_iam_policy.lambda_iam_policy.arn
}

resource "aws_lambda_function" "lambda" {
  function_name    = var.function_name
  description      = "Test Lambda"
  filename         = data.archive_file.zip.output_path
  source_code_hash = data.archive_file.zip.output_base64sha256
  role             = aws_iam_role.lambda_iam_role.arn
  handler          = "${var.handler_name}.lambda_handler"
  runtime          = var.runtime #"python3.6"
  depends_on       = [aws_iam_role_policy_attachment.lambda_iam_role_policy_attachment]
  tags = {
    ManagedBy = "Terraform"
  }
}

resource "aws_lambda_function_url" "lambda_url" {
  function_name      = aws_lambda_function.lambda.function_name
  authorization_type = var.authorization_type
}