resource "aws_secretsmanager_secret" "secret" {
  for_each                = var.secret_name
  name                    = var.dbtype == "app" ? "/${var.eb_env}/${var.eb_name}/master/dbSecret" : "/${var.eb_env}/${var.eb_name}-${var.dbtype}/master/dbSecret"
  recovery_window_in_days = var.recovery_window
  kms_key_id              = var.kms_key_id
  tags = {
    ManagedBy : "Terraform"
    Service : var.eb_name
    Environment : var.eb_env
  }
}

resource "aws_secretsmanager_secret_version" "secretversion" {
  for_each      = aws_secretsmanager_secret.secret
  secret_id     = aws_secretsmanager_secret.secret[each.key].id
  secret_string = <<EOF
{
    "username": "${var.username}",
    "password": "${var.password}" 
}
EOF
}