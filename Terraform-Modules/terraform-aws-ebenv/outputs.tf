output "eb_fqdn" {
  description = "Fully qualified DNS name for the environment"
  value       = module.elastic-beanstalk-environment[*].endpoint
}

output "load_balancers" {
  description = "Load balancers used in the Elastic Beanstalk environment"
  value       = module.elastic-beanstalk-environment[*].load_balancers
}

output "instances" {
  description = "Instances used in the Elastic Beanstalk environment"
  value       = module.elastic-beanstalk-environment[*].instances
}

output "vpc" {
  value       = data.aws_vpcs.vpcs.ids
  description = "Environment VPC"
}

output "public_subnets" {
  value       = data.aws_subnets.public_subnets.ids
  description = "Public Subnets"
}

output "private_subnets" {
  value       = data.aws_subnets.private_subnets.ids
  description = "Private Subnets"
}

output "ec2_instance_profile_role_name" {
  value       = module.elastic-beanstalk-environment[*].ec2_instance_profile_role_name
  description = "ec2_instance_profile_role_name"
}

output "security_group_id" {
  description = "security group used in the Elastic Beanstalk environment"
  value       = module.elastic-beanstalk-environment[*].security_group_id
}
