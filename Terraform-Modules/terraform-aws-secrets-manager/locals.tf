#locals {
#  #for_each = var.secret_name
#  db_creds = jsondecode(
#    data.aws_secretsmanager_secret_version.creds[each.key].secret_string
#  )
#}