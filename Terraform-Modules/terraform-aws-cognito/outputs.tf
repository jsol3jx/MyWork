output "aws_cognito_identity_pool" {
    value = aws_cognito_identity_pool.aos_identity_pool.id
}

output "aws_cognito_user_pool" {
    value = aws_cognito_user_pool.aos_pool.id
}