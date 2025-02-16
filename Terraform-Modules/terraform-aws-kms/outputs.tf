output "kms_arn" {
  value       = aws_kms_key.key.arn
  description = "KMS key ARN"
}

output "kms_alias_arn" {
  value       = aws_kms_alias.alias.arn
  description = "KMS key alias ARN"
}

output "kms_key_spec" {
  value       = aws_kms_key.key.customer_master_key_spec == "SYMMETRIC_DEFAULT" ? "AES_256" : aws_kms_key.key.customer_master_key_spec
  description = "KMS key ARN"
}

output "kms_key_id" {
  value       = aws_kms_key.key.key_id
  description = "KMS key ID"
}

output "admin_role_name" {
  value = data.aws_iam_roles.admin_role_name.names
}

output "platform_eng_role_name" {
  value = data.aws_iam_roles.platform_eng_role_name.names
}

output "poweruser_role_name" {
  value = data.aws_iam_roles.poweruser_role_name.names
}