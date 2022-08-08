module "ec2-instance" {
  source                               = "cloudposse/ec2-instance/aws"
  version                              = "0.42.0"
  ami                                  = local.instanceami
  ami_owner                            = var.ownedami == true ? var.ami_owner : data.aws_ami.non-owned[0].owner_id
  burstable_mode                       = var.burstable_mode
  delimiter                            = "-"
  delete_on_termination                = var.delete_on_termination
  ebs_volume_count                     = var.ebs_volume_count
  ebs_volume_size                      = var.ebs_volume_size
  ebs_volume_encrypted                 = var.ebs_volume_encrypted
  enabled                              = true
  environment                          = var.ec2_env
  id_length_limit                      = 0
  instance_initiated_shutdown_behavior = var.instance_initiated_shutdown_behavior
  instance_profile                     = var.instance_profile #"${var.ec2_name}-${var.ec2_env}-1-ec2-instance-profile"
  instance_type                        = var.instance_type
  ipv6_address_count                   = var.ipv6_address_count
  kms_key_id                           = var.kms_key_id
  label_key_case                       = "title"
  label_order                          = ["name", "stage", "attributes"]
  label_value_case                     = "lower"
  name                                 = "${var.ec2_name}-${var.ec2_env}-1"
  private_ip                           = var.private_ip
  regex_replace_chars                  = "/[^-a-zA-Z0-9]/"
  root_volume_size                     = var.root_volume_size
  region                               = var.region
  security_group_description           = "${var.ec2_name}-${var.ec2_env}-ec2-sg"
  security_group_rules                 = var.security_group_rules
  ssh_key_pair                         = var.key_name
  ssm_patch_manager_iam_policy_arn     = var.ssm_patch_manager_iam_policy_arn
  subnet                               = var.ipv6_required == true ? local.instance_public_subnet_id : local.instance_private_subnet_id
  user_data                            = var.windows_ssm == true ? data.template_file.userdata_winssm.rendered : null
  vpc_id                               = data.aws_vpc.vpc.id
  tags = {
    ManagedBy = "Terraform"
  }
}

resource "random_id" "private_index" {
  byte_length = 2
}

resource "random_id" "public_index" {
  byte_length = 2
}