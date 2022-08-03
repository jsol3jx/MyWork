data "archive_file" "zip" {
  #count       = var.usehandler == true ? 1 : 0
  type        = "zip"
  source_file = "${path.module}/handlers/handler.py"
  output_path = "${path.module}/handlers/handler.zip"
}

data "aws_iam_policy_document" "lambda_iam_role_base_policy" {
  statement {
    sid    = ""
    effect = "Allow"

    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }

    actions = ["sts:AssumeRole"]
  }
}
/*
data "aws_iam_policy" "lambda_iam_role_policy" {
  statement {
    sid = ""
    effect = "Allow"
  }
}
*/