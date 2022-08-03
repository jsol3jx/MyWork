#data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

data "aws_iam_role" "aos_service_linked_role" {
  name = "AWSServiceRoleForAmazonElasticsearchService"

  depends_on = [
    aws_iam_service_linked_role.es
  ]
}

data "aws_iam_role" "aos_cognito_unauthenticated" {
  name = "${var.eb_name}-${var.eb_env}-aos-cognito-unauthenticated"
}

data "aws_iam_role" "aos_cognito_authenticated" {
  name = "${var.eb_name}-${var.eb_env}-aos-cognito-authenticated"
}

data "aws_iam_policy_document" "aos_access_policies" {
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [data.aws_iam_role.aos_cognito_authenticated.arn]
    }
    actions = [
      "es:*"
    ]
    resources = [
      "arn:aws:es:${data.aws_vpcs.vpcs.id}:${local.aws_account_id}:domain/${var.eb_name}/*"
    ]
  }
}

##############
#vpc data
##############

data "aws_vpcs" "vpcs" {
  tags = {
    Name = "shared-${var.eb_env}"
  }
  #ids = var.vpc_id
}

data "aws_subnet_ids" "private_subnets" {
  vpc_id = element(tolist(data.aws_vpcs.vpcs.ids), 0)
  tags = {
    Name = "*private*"
  }
}

#data "aws_subnet" "private" {
#  for_each = data.aws_subnet_ids.private_subnets[0].ids
#  id       = each.value
#}

#######################
#Cognito
#######################

data "aws_cognito_user_pools" "aos_pool" {
  name = "${var.eb_name}-${var.eb_env}-opensearch"
}

#data "aws_cognito_identity_pool" "aos_pool" {
#  name = "${var.eb_name}-${var.eb_env}-identity-pool"
#}

data "aws_iam_role" "cognito_for_aos" {
  name = "${var.eb_name}-${var.eb_env}-cognito-for-aos"
}

####################################################################################################
# Logs
####################################################################################################

data "aws_iam_policy_document" "opensearch_logs" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["es.amazonaws.com"]
    }
    actions = [
      "logs:PutLogEvents",
      "logs:PutLogEventsBatch",
      "logs:CreateLogStream",
    ]
    resources = [
      "arn:aws:logs:*"
    ]
  }
}