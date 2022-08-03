data "aws_caller_identity" "current" {}

####################################################################################################
# Authenticated Role
####################################################################################################

data "aws_iam_policy_document" "aos_cognito_authenticated_policy_document" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = ["cognito-identity.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "cognito-identity.amazonaws.com:aud"
      values   = [aws_cognito_identity_pool.aos_identity_pool.id]
    }
    condition {
      test     = "ForAnyValue:StringLike"
      variable = "cognito-identity.amazonaws.com:amr"
      values   = ["authenticated"]
    }
  }
}

data "aws_iam_policy_document" "aos_cognito_authenticated" {
  statement {
    effect = "Allow"
    actions = [
      "*"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "cognito-sync:*"
    ]
    resources = [
      "arn:aws:cognito-sync:${var.aws_region}:${local.aws_account_id}:identitypool/${aws_cognito_identity_pool.aos_identity_pool.id}"
    ]
  }
}

####################################################################################################
# Unauthenticated Role
####################################################################################################

data "aws_iam_policy_document" "aos_cognito_unauthenticated_policy_document" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type = "Federated"
      identifiers = ["cognito-identity.amazonaws.com"]
    }
    condition {
      test = "StringEquals"
      variable = "cognito-identity.amazonaws.com:aud"
      values = [aws_cognito_identity_pool.aos_identity_pool.id]
    }
    condition {
      test = "ForAnyValue:StringLike"
      variable = "cognito-identity.amazonaws.com:amr"
      values = ["unauthenticated"]
    }
  }
}

data "aws_iam_policy_document" "aos_cognito_unauthenticated" {
  statement {
    effect = "Allow"
    actions = [
      "mobileanalytics:PutEvents"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "cognito-sync:*"
    ]
    resources = [
      "arn:aws:cognito-sync:${var.aws_region}:${local.aws_account_id}:identitypool/${aws_cognito_identity_pool.aos_identity_pool.id}"
    ]
  }
}
####################################################################################################
# Role enabling OpenSearch to access Cognito
####################################################################################################

data "aws_iam_policy_document" "cognito_for_aos_policy_document" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = ["es.amazonaws.com"]
    }
  }
}