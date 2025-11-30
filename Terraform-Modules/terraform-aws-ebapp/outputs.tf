#output "ebservicerole" {
#  value = var.ebrolecreate == 1 ? aws_iam_service_linked_role.eb[0].arn : ""
#}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}