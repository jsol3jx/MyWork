#This script will install all available OS updates for Amazon Linux 2 w/ Docker.

sudo amazon-linux-extras install kernel-5.15 -y
sudo yum remove kernel.x86_64           5.10.118-111.515.amzn2           @amzn2extra-kernel-5.10 -y
sudo /opt/elasticbeanstalk/bin/pkg-repo unlock
sudo cp /etc/yum.repos.d/amzn2-core.repo /etc/yum.repos.d/amzn2-core.repo.org
sudo sed 's/-$guid//g' /etc/yum.repos.d/amzn2-core.repo -i
sudo rm -fr /var/cache/yum/*
sudo yum clean all
sudo yum update --security -y
sudo yum update -y
sudo yum update kernel -y