aos_master_instance_count = 2
aos_master_instance_type  = "m3.large.elasticsearch"
aos_data_instance_count   = 2
aos_data_instance_type    = "m4.4xlarge.elasticsearch"
aos_data_instance_storage = 50
aos_encrypt_at_rest       = false
eb_name           = "example"
eb_env                   = "env"
#vpc_id                    = "vpc-id"
#aos_domain_subnet_ids     = ["subnet-1", "subnet-2"]
create_service_role       = false
aos_cognito_enabled       = true

