provider "aws" {
  region = var.region
}

module "elastic-beanstalk-environment" {
  count                                = var.env_num
  region                               = var.region
  source                               = "cloudposse/elastic-beanstalk-environment/aws"
  version                              = "0.51.2"
  ami_id                               = local.instanceami
  application_subnets                  = data.aws_subnets.private_subnets.ids
  autoscale_lower_bound                = var.autoscale_lower_bound
  autoscale_max                        = var.autoscale_max
  autoscale_measure_name               = var.autoscale_measure_name
  autoscale_min                        = var.autoscale_min
  autoscale_statistic                  = var.autoscale_statistic
  autoscale_unit                       = var.autoscale_unit
  autoscale_upper_bound                = var.autoscale_upper_bound
  autoscale_upper_increment            = var.autoscale_upper_increment
  availability_zone_selector           = "Any"
  delimiter                            = "-"
  deployment_batch_size                = 50
  deployment_batch_size_type           = "Percentage"
  elastic_beanstalk_application_name   = var.app_name
  elb_scheme                           = var.elb_scheme
  enabled                              = true
  enhanced_reporting_enabled           = true
  env_vars                             = var.env_vars == {} ? local.env_vars : var.env_vars
  environment                          = var.app_env
  environment_type                     = var.tier == "Worker" ? "SingleInstance" : "LoadBalanced"
  extended_ec2_policy_document         = var.extended_ec2_policy_document
  force_destroy                        = true
  healthcheck_url                      = var.healthcheck_url
  healthcheck_httpcodes_to_match       = var.healthcheck_httpcodes_to_match
  health_streaming_enabled             = true
  http_listener_enabled                = var.http_listener_enabled
  id_length_limit                      = 0
  instance_refresh_enabled             = false
  instance_type                        = var.instance_type
  keypair                              = var.key_name
  label_key_case                       = "title"
  label_order                          = ["name", "stage", "attributes"]
  label_value_case                     = "lower"
  loadbalancer_certificate_arn         = var.loadbalancer_certificate_arn
  loadbalancer_ssl_policy              = "ELBSecurityPolicy-2016-08"
  loadbalancer_subnets                 = var.go_private == true ? data.aws_subnets.private_subnets.ids : data.aws_subnets.public_subnets.ids
  loadbalancer_type                    = "application"
  name                                 = var.eb_envname_override == null ? "${var.app_name}-${var.app_env}-${count.index + 1}" : var.eb_envname_override
  preferred_start_time                 = "Thu:22:00"
  rolling_update_enabled               = var.autoscale_max == 1 ? false : true
  root_volume_size                     = var.root_volume_size
  solution_stack_name                  = var.solution_stack_name
  ssh_listener_enabled                 = false
  update_level                         = "minor"
  vpc_id                               = data.aws_vpc.vpc.id
  version_label                        = var.version_label
  tier                                 = var.tier
  stage                                = var.stage
  enable_stream_logs                   = true
  s3_bucket_access_log_bucket_name     = var.s3_bucket_access_log_bucket_name
  managed_actions_enabled              = var.managed_actions_enabled
  security_group_name                  = var.security_group_name
  security_group_create_before_destroy = var.security_group_create_before_destroy
  additional_settings                  = var.additional_settings
  tags = {
    ManagedBy = "Terraform"
  }
}

