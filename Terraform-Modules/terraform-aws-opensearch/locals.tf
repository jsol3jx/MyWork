locals {
  #aws_region         = data.aws_region.current.name
  aws_account_id     = data.aws_caller_identity.current.account_id
  private_cidrs      = var.aos_private_subnet_ids #[for s in var.aos_private_subnet_ids : s.cidr_block]
  #private_ipv6_cidrs = [for s in data.aws_subnet.private : s.ipv6_cidr_block]
}