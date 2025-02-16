#General installation steps for NewRelic on Linux operating systems
#Link: https://www.crowdstrike.com/blog/tech-center/install-falcon-sensor-for-linux/

echo "Installing CrowdStrike Agent..."

#Download the agent from S3
aws s3 cp s3://$S3_BUCKET/agents/crowdstrike/falcon-sensor.amzn2.x86_64.rpm /tmp/falcon-sensor.amzn2.x86_64.rpm

#Validating the signature for the package cannot be performed, since the vendor does not provide a key for this purpose
#If this changes, then the package can be validated like this
#sudo rpm --import https://path/to/repository/key.gpg
#rpm -K /tmp/newrelic-infra.amazonlinux-2.x86_64.rpm
#signature_status=$?
#if [ $signature_status -ne 0 ]; then
#    echo "Error: package signature could not be validated"
#    exit 1
#fi

#Install the package and exit on error
sudo yum -y install /tmp/falcon-sensor.amzn2.x86_64.rpm
install_status=$?
if [ $install_status -ne 0 ]; then
    echo "Error: agent installation failed"
    exit 1
fi
#Configure the agent with the CID and restart the service
sudo /opt/CrowdStrike/falconctl -s --cid=$CROWDSTRIKE_CID
sudo systemctl restart falcon-sensor.service

#Check service status and exit on error
systemctl is-active --quiet falcon-sensor.service
service_status=$?
if [ $service_status -ne 0 ]; then
    echo "Error: service could not be started"
    exit 1
fi

echo "Crowdstrike Falcon Agent Installed"