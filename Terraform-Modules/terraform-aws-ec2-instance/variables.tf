variable "region" {
  default = "us-west-1"
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC that the instance security group belongs to"
  default     = "null"
}

variable "burstable_mode" {
  type        = string
  description = "Enable burstable mode for the instance. Can be standard or unlimited. Applicable only for T2/T3/T4g instance types."
  default     = "standard"
}

variable "ec2_name" {
  description = "Name for the Elastic Beanstalk application"
}

variable "ec2_env" {
  description = "Name for the Elastic Beanstalk environment (prod, sandbox, dev, qa, or staging)"
}

variable "instance_initiated_shutdown_behavior" {
  type        = string
  description = "Specifies whether an instance stops or terminates when you initiate shutdown from the instance. Can be one of 'stop' or 'terminate'."
  default     = "stop"
}

variable "kms_key_id" {
  type        = string
  default     = null
  description = "KMS key ID used to encrypt EBS volume. When specifying kms_key_id, ebs_volume_encrypted needs to be set to true"
}

variable "private_ip" {
  type        = string
  description = "Private IP address to associate with the instance in the VPC"
  default     = null
}

variable "key_name" {
  description = "Key name for the key-pair"
}

variable "ssm_patch_manager_iam_policy_arn" {
  type        = string
  default     = null
  description = "IAM policy ARN to allow Patch Manager to manage the instance. If not provided, `arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore` will be used"
}

variable "ami" {
  type        = string
  description = "The AMI to use for the instance. By default it is the AMI provided by Amazon with Ubuntu 16.04"
  default     = ""
}

variable "ami_owner" {
  type        = string
  description = "Owner of the given AMI (ignored if `ami` unset, required if set)"
  default     = ""
}

variable "root_volume_size" {
  default     = 50
  description = "The size of the EBS root volume"
}

variable "instance_type" {
  default     = "t3.medium"
  description = "Instance type/size"
}

variable "ebs_volume_count" {
  type        = number
  description = "Count of EBS volumes that will be attached to the instance"
  default     = 0
}

variable "ebs_volume_size" {
  type        = number
  description = "Size of the additional EBS volumes in gigabytes"
  default     = 10
}

variable "ebs_volume_encrypted" {
  type        = bool
  description = "Whether to encrypt the additional EBS volumes"
  default     = true
}

variable "delete_on_termination" {
  type        = bool
  description = "Whether the volume should be destroyed on instance termination"
  default     = true
}

variable "instance_profile" {
  description = "ec2 instance profile name."
}

variable "ipv6_address_count" {
  description = "Variable to attach an ipv6 address to the instance"
  default     = 0
}

variable "ipv6_required" {
  description = "This variable is used when an ipv6 address is required."
  default = false
}

variable "security_group_rules" {
  description = "inbound/outbound rules for the ec2"
  default = [ 
    {
      "cidr_blocks": [ "0.0.0.0/0" ], 
      "description": "Allow all outbound traffic", 
      "from_port": 0, 
      "protocol": "-1", 
      "to_port": 65535, 
      "type": "egress" 
    } 
  ]
}

variable "ami-os" {
  description = "Variable to specify what OS to search for an ami"

}

variable "ownedami" {
  description = "Variable that sets whether to use the Owned AMI"
  default = true
}

variable "windows_ssm" {
  description = "Conditional variable to install ssm agent on windows ec2 instances for session manager."
  default = false
}