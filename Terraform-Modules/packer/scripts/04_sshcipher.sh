#!/bin/bash

#copy the file from S3 to the system.
aws s3 cp s3://$S3_BUCKET/files/sshd_config /tmp/

#copy the new sshd_config and overwrite the current one
sudo cp /tmp/sshd_config /etc/ssh/sshd_config

#Set the correct permissions on the new sshd_config
sudo chown root:root /etc/ssh/sshd_config
sudo chmod 600 /etc/ssh/sshd_config

#restart the service to apply the changes.
sudo systemctl restart sshd