####################################################################################################
# Cognito User Pool
####################################################################################################

locals {
  cognito_user_pool_domain = "${aws_cognito_user_pool_domain.aos_user_pool_domain.domain}.auth.${var.aws_region}.amazoncognito.com"
}

####################################################################################################
# Cognito Identity Pool
####################################################################################################
#locals {
#  identity_pool_name = replace("${var.eb_name}-${var.eb_env}-opensearch", "-", "_")
#}

locals {
  aws_account_id = data.aws_caller_identity.current.account_id  
}
