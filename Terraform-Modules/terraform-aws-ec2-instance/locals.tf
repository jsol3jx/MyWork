locals {
  subnet_ids_private_list = tolist(data.aws_subnets.private_subnets.ids)

  subnet_ids_private_random_index = random_id.private_index.dec % length(data.aws_subnets.private_subnets.ids)

  instance_private_subnet_id = local.subnet_ids_private_list[local.subnet_ids_private_random_index]
}

locals {
  subnet_ids_public_list = tolist(data.aws_subnets.public_subnets.ids)

  subnet_ids_public_random_index = random_id.public_index.dec % length(data.aws_subnets.public_subnets.ids)

  instance_public_subnet_id = local.subnet_ids_public_list[local.subnet_ids_public_random_index]
}

locals {
  ami_amazon  = var.ownedami == true ? null : data.aws_ami.non-owned[0].image_id
  ami_owned  = var.ami 
  instanceami = var.ownedami == true ? local.ami_owned : local.ami_amazon
}