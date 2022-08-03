####################################################################################################
# Cognito User Pool
####################################################################################################
resource "aws_cognito_user_pool" "aos_pool" {
  name = "${var.eb_name}-${var.eb_env}-opensearch"

  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]

  username_configuration {
    case_sensitive = false
  }

  admin_create_user_config {
    allow_admin_create_user_only = true
  }

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  tags = {
    ManagedBy : "Terraform"
    Service : var.eb_name
    Environment : var.eb_env
  }
}

resource "aws_cognito_user_pool_domain" "aos_user_pool_domain" {
  domain       = "${var.eb_name}-${var.eb_env}-opensearch-${local.aws_account_id}-${var.aws_region}"
  user_pool_id = aws_cognito_user_pool.aos_pool.id
}

resource "aws_cognito_user_pool_client" "aos_user_pool_client" {
  name         = "${var.eb_name}-${var.eb_env}-opensearch"
  user_pool_id = aws_cognito_user_pool.aos_pool.id

  generate_secret = true

  }


####################################################################################################
# Cognito Identity Pool
####################################################################################################

resource "aws_cognito_identity_pool" "aos_identity_pool" {
  identity_pool_name               = "${var.eb_name}-${var.eb_env}-identity-pool"
  allow_unauthenticated_identities = false

  cognito_identity_providers {
    client_id     = aws_cognito_user_pool_client.aos_user_pool_client.id
    provider_name = aws_cognito_user_pool.aos_pool.endpoint
  }

  tags = {
    ManagedBy : "Terraform"
    Service : var.eb_name
    Environment : var.eb_env
  }
}

resource "aws_cognito_identity_pool_roles_attachment" "aos_pool_roles" {
  identity_pool_id = aws_cognito_identity_pool.aos_identity_pool.id
  roles = {
    "authenticated"   = aws_iam_role.aos_cognito_authenticated.arn
    "unauthenticated" = aws_iam_role.aos_cognito_unauthenticated.arn
  }
}

####################################################################################################
# Authenticated Role
####################################################################################################
resource "aws_iam_role" "aos_cognito_authenticated" {
  name               = "${var.eb_name}-${var.eb_env}-aos-cognito-authenticated"
  assume_role_policy = data.aws_iam_policy_document.aos_cognito_authenticated_policy_document.json

  tags = {
    ManagedBy : "Terraform"
    Service : var.eb_name
    Environment : var.eb_env
  }
}

resource "aws_iam_role_policy" "aos_cognito_authenticated" {
  name = "${var.eb_name}-${var.eb_env}-aos-cognito-authenticated"
  role = aws_iam_role.aos_cognito_authenticated.id

  policy = data.aws_iam_policy_document.aos_cognito_authenticated.json
}

####################################################################################################
# Unauthenticated Role
####################################################################################################
resource "aws_iam_role" "aos_cognito_unauthenticated" {
  name = "${var.eb_name}-${var.eb_env}-aos-cognito-unauthenticated"
  assume_role_policy = data.aws_iam_policy_document.aos_cognito_unauthenticated_policy_document.json

  tags = {
    ManagedBy : "Terraform"
    Service : var.eb_name
    Environment : var.eb_env
  }
}

resource "aws_iam_role_policy" "aos_cognito_unauthenticated" {
  name = "${var.eb_name}-${var.eb_env}-aos-cognito-unauthenticated"
  role = aws_iam_role.aos_cognito_unauthenticated.id
  policy = data.aws_iam_policy_document.aos_cognito_unauthenticated.json
}






####################################################################################################
# Role enabling OpenSearch to access Cognito
####################################################################################################
resource "aws_iam_role" "cognito_for_aos" {
  name = "${var.eb_name}-${var.eb_env}-cognito-for-aos"
  assume_role_policy = data.aws_iam_policy_document.cognito_for_aos_policy_document.json

  tags = {
    ManagedBy : "Terraform"
    Service : var.eb_name
    Environment : var.eb_env
  }
}

resource "aws_iam_role_policy_attachment" "cognito_for_aos" {
  role = aws_iam_role.cognito_for_aos.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonESCognitoAccess"
}