data "aws_secretsmanager_secret" "secretmasterDB" {
  for_each = var.secret_name
  arn      = aws_secretsmanager_secret.secretmasterDB[each.key].arn
}

data "aws_secretsmanager_secret_version" "creds" {
  for_each  = var.secret_name
  secret_id = data.aws_secretsmanager_secret.secretmasterDB[each.key].arn
}
