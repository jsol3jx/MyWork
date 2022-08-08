data "aws_vpcs" "vpcs" {
  tags = {
    Name = "example-${var.ec2_env}"
  }
}

data "aws_vpc" "vpc" {
  id = tolist(data.aws_vpcs.vpcs.ids)[0]
}

data "aws_availability_zones" "name" {}

data "aws_subnets" "private_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }

  tags = {
    Name = "*private*"
  }
}

data "aws_subnets" "public_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }

  tags = {
    Name = "*public*"
  }
}

data "aws_ami" "non-owned" {
  count = var.ownedami == true ? 0 : 1
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "name"
    values = ["*${var.ami-os}*"]
  }

}


data "template_file" "userdata_winssm" {
  #file("${path.module}/scripts/win-ssmagent.ps1")
  template = <<EOF
<powershell>
$progressPreference = 'silentlyContinue'
$progressPreference = 'silentlyContinue'
Invoke-WebRequest `
    https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/windows_amd64/AmazonSSMAgentSetup.exe `
    -OutFile $env:USERPROFILE\Desktop\SSMAgent_latest.exe

Start-Process `
    -FilePath $env:USERPROFILE\Desktop\SSMAgent_latest.exe `
    -ArgumentList "/S"

rm -Force $env:USERPROFILE\Desktop\SSMAgent_latest.exe
Restart-Service AmazonSSMAgent
</powershell>
EOF
}
