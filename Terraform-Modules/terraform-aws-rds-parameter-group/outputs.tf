#output "db_parameter_group_id" {
#  description = "The db parameter group id"
#  value       = element(concat(aws_db_parameter_group.default.*.id, [""]), 0)
#}
#
#output "db_parameter_group_arn" {
#  description = "The ARN of the db parameter group"
#  value       = element(concat(aws_db_parameter_group.default.*.arn, [""]), 0)
#}