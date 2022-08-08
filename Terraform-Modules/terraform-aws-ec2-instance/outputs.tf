output "instance_profile" {
  description = "Name of the instance's profile (either built or supplied)"
  value       = module.ec2-instance.instance_profile
}