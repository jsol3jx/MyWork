output "key_name" {
  value       = module.key-pair.key_pair_name
  description = "Generated ssh key-pair name"
}

output "private_key_pem" {
  value       = tls_private_key.key.private_key_pem
  description = "EC2 private ssh key pem"
}