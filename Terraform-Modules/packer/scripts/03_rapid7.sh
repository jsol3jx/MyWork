#General installation steps and specific instructions for Amazon Linux
#Link: https://docs.rapid7.com/insight-agent/certificate-package-installation-method#install-on-mac-and-linux
#Link: https://docs.rapid7.com/insight-agent/virtualization/

echo "Installing Rapid7 Agent..."

#Create directory for rapid7 artifacts with execute permissions
mkdir ~/rapid7/
chmod 700 ~/rapid7/

#Download the agent from S3 and unzip contents to local directory
aws s3 cp s3://$S3_BUCKET/agents/rapid7/linux__Insight_Agent.zip /tmp/linux__Insight_Agent.zip
unzip /tmp/linux__Insight_Agent.zip -d ~/rapid7/

#Removal of tput from the installer script to prevent errors in CodeBuild:
# The installer script makes use of tput to format messages, and this causes errors when run in CodeBuild
# Error message: "tput: terminal attributes: No such device or address"
# A potential approach is to adjust the installer script after unzipping the package using sed, so that tput is not used. 
# Bear in mind that doing this replacement risks breaking the installer agent if the vendor introduces new changes.
# Both executions of sed (change #1 & #2 need to be used, since they address different appearances of tput in the script)
#Change #1 (remove -col completely, since then a default value is assigned)
# Before
# ${CURRENT_FP}/connectivity_test -filepath ${CURRENT_FP} -col $(tput cols) -proxyAddress ${PROXY_SETTINGS}
# After:
# ${CURRENT_FP}/connectivity_test -filepath ${CURRENT_FP} -proxyAddress ${PROXY_SETTINGS}
#sed -i 's/-col $(tput cols)//g' ~/rapid7/agent_installer.sh

#Change #2 (run tput only if there if there is a tty, ref: https://github.com/edeliver/edeliver/issues/188)
# Before
# cols=$((`tput cols` - $strlen))
# After
# cols=$((`[[ -t 0 ]] && tput cols` - $strlen))
#sed -i '/ou/!  s/tput/[[ -t 0 ]] \&\& tput/g' ~/rapid7/agent_installer.sh

#Grant execute permissions for the agent installer
chmod u+x ~/rapid7/agent_installer-x86_64.sh

#Run the installer and exit on error.
#Warning: the original source documentation suggests using install_start, but installing on Amazon Linux
#requires that the service is not started automatically (using "install" instead of "install_start")
sudo ~/rapid7/agent_installer-x86_64.sh install
install_status=$?
if [ $install_status -ne 0 ]; then
    echo "Error: agent installation failed"
    exit 1
fi

#Delete the configuration file, as instructed by the documentation for Amazon Linux
sudo rm -f /opt/rapid7/ir_agent/components/bootstrap/common/bootstrap.cfg

#The vendor instructs to avoid starting the service, so checking the service status will be skipped
echo "Rapid7 Insight Agent Installed."