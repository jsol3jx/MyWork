locals {
  env_vars = {
    "AWS_REGION"         = "`{\"Ref\" : \"AWS::Region\"}`"
    "ENVIRONMENT_NAME"   = "`{ \"Ref\" : \"AWSEBEnvironmentName\" }`"
  }
}

locals {
  ami_amazon  = var.pcicompliant == true ? null : data.aws_ami.non-pci[0].image_id
  ami_custom  = var.ami_id
  instanceami = var.pcicompliant == true ? local.ami_custom : local.ami_amazon
}