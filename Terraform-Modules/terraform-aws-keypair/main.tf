provider "aws" {
  region = var.region
}

resource "tls_private_key" "key" {
  algorithm = "RSA"
}

module "key-pair" {
  source             = "terraform-aws-modules/key-pair/aws"
  version            = "2.0.0"
  key_name           = "${var.app_name}-${var.app_env}-${var.region}"
  public_key         = tls_private_key.key.public_key_openssh
  create_private_key = true
  tags = {
    ManagedBy = "Terraform"
  }
}