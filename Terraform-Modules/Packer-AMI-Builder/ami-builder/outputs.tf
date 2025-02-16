output "codepipeline_name" {
  description = "CodePipeline name"
  value       = aws_codepipeline.ami_builder.name
}

output "codepipeline_arn" {
  description = "codepipeline arn"
  value       = aws_codepipeline.ami_builder.arn
}

output "codebuild_arn" {
  description = "Codebuild name"
  value       = aws_codebuild_project.ami_builder.name
}

output "s3_bucket_arn" {
  description = "s3 bucket arn"
  value       = aws_s3_bucket.ami_builder.arn
}

output "secretsmanager_secret_arn" {
  description = "Secrets Manager's secrete arn"
  value       = aws_secretsmanager_secret.ami_builder.arn
}

output "CodePipeline_name" {
  description = "CodePipeline name"
  value       = aws_codepipeline.ami_builder.name
}

output "eventbridge_rules_arns" {
  description = "EvenBridge rules ARNs"
  value       = length(var.schedules) > 0 ? module.schedules[*].rule_arn : []
}

output "sns_topic_arn" {
  description = "SNS Topic arn for notifications"
  value       = var.enable_notifications ? module.notifications[*].sns_topic_arn : ""
}