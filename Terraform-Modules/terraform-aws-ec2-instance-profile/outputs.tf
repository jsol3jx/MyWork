output "instance_profile_name" {
  description = "ID of Instance Profile used to reference the created objects in aws_instance resources"
  value       = aws_iam_instance_profile.ec2_instance_profile.name
}