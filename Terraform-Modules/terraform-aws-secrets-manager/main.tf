resource "random_password" "password" {
  for_each         = var.secret_name
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "aws_secretsmanager_secret" "secretmasterDB" {
  for_each                = var.secret_name
  name                    = "${var.secret_tag}-${each.key}"
  recovery_window_in_days = 0
  tags = {
    ManagedBy : "Terraform"
    UseCase : var.secret_tag
  }
}

resource "aws_secretsmanager_secret_version" "sversion" {
  for_each      = aws_secretsmanager_secret.secretmasterDB
  secret_id     = aws_secretsmanager_secret.secretmasterDB[each.key].id
  secret_string = <<EOF
   {
    "username": "${var.username}",
    "password": "${random_password.password[each.key].result}"
   }
EOF
}