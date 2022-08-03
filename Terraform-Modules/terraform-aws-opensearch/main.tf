#provider "aws" {
##  region = var.region
#}

resource "aws_iam_service_linked_role" "es" {
  count            = var.create_service_role ? 1 : 0
  aws_service_name = "es.amazonaws.com"
}


resource "aws_elasticsearch_domain" "aos" {
  domain_name           = "${var.eb_name}-${var.eb_env}"
  elasticsearch_version = var.opensearch_version


  cluster_config {
    instance_count           = var.aos_data_instance_count
    instance_type            = var.aos_data_instance_type
    dedicated_master_enabled = var.aos_master_instance_count > 0
    dedicated_master_count   = var.aos_master_instance_count
    dedicated_master_type    = var.aos_master_instance_type
    zone_awareness_enabled   = var.aos_zone_awareness_enabled
  }

  ebs_options {
    ebs_enabled = var.aos_ebs_enabled
    volume_size = var.aos_data_instance_storage
  }

  vpc_options {
    subnet_ids         = data.aws_subnet_ids.private_subnets.ids
    security_group_ids = [aws_security_group.opensearch.id]
  }

  encrypt_at_rest {
    enabled    = var.aos_encrypt_at_rest
    kms_key_id = var.kms_arn
  }

  node_to_node_encryption {
    enabled = var.aos_node_to_node_encryption
  }

  domain_endpoint_options {
    enforce_https                   = var.aos_enforce_https
    tls_security_policy             = "Policy-Min-TLS-1-2-2019-07"
    custom_endpoint_certificate_arn = var.loadbalancer_certificate_arn
  }

  cognito_options {
    enabled          = var.aos_cognito_enabled
    identity_pool_id = var.identity_pool_id #aws_cognito_identity_pool.aos_identity_pool.id
    role_arn         = data.aws_iam_role.cognito_for_aos.arn
    user_pool_id     = var.user_pool_id #aws_cognito_user_pool.aos_pool.id
  }

  access_policies = data.aws_iam_policy_document.aos_access_policies.json

  log_publishing_options {
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.opensearch_logs.arn
    log_type                 = "INDEX_SLOW_LOGS"
  }

  log_publishing_options {
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.opensearch_logs.arn
    log_type                 = "SEARCH_SLOW_LOGS"
  }

  log_publishing_options {
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.opensearch_logs.arn
    log_type                 = "ES_APPLICATION_LOGS"
  }

  tags = {
    ManagedBy : "Terraform"
    Service : var.eb_name
    Environment : var.eb_env
  }

  depends_on = [data.aws_iam_role.aos_service_linked_role]
}

#######################
#VPC & Security Groups
#######################

resource "aws_security_group" "opensearch" {
  name        = "${var.eb_name}-${var.eb_env}-opensearch-domain"
  description = "OpenSearch Domain"
  vpc_id      = element(tolist(data.aws_vpcs.vpcs.ids), 0)

  egress {
    description      = "Allow all outbound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name      = "${var.eb_name}-${var.eb_env}-opensearch-domain"
    ManagedBy = "Terraform"
  }
}

resource "aws_security_group_rule" "opensearch" {
  count = length(local.private_cidrs) #data.aws_subnet_ids.private_subnets.ids

  description       = "${var.eb_name}-${var.eb_env} OpenSearch Cluster Subnets"
  security_group_id = aws_security_group.opensearch.id

  type             = "ingress"
  from_port        = 443
  to_port          = 443
  protocol         = "tcp"
  cidr_blocks      = local.private_cidrs
  #ipv6_cidr_blocks = local.private_ipv6_cidrs #data.aws_subnet.private[count.index].ipv6_cidr_block == null ? [] : [data.aws_subnet.private[count.index].ipv6_cidr_block]
}

####################################################################################################
# Logs
####################################################################################################

resource "aws_cloudwatch_log_group" "opensearch_logs" {
  name = "opensearch/${var.eb_name}-${var.eb_env}"
}

resource "aws_cloudwatch_log_resource_policy" "opensearch_logs" {
  policy_name     = "opensearch-${var.eb_name}-${var.eb_env}"
  policy_document = data.aws_iam_policy_document.opensearch_logs.json
}

