#!bin/bash
MAGENTO_DIRECTORY=/var/www/magento
CLI_DIRECTORY=/home/vagrant/cli
SCRIPTS_DIRECTORY=scripts
clear
printf "Updating the VM CLI...\n"

# Add SSH Key
printf "\nAdding SSH Key..."
eval $(ssh-agent) > /dev/null 2>&1
ssh-add ~/.ssh/Magento-Cloud > /dev/null 2>&1
printf "done.\n\n"

# Update CLI
cd ${CLI_DIRECTORY}

# Stash existing changes
git stash > /dev/null 2>&1

# Pull new changes and set permissions
git pull
printf "\nInstalling commands... "
source ${CLI_DIRECTORY}/commands.sh
sleep 1
printf "done. \n\nMaking scripts executable... "
sudo chmod +x ${CLI_DIRECTORY}/${SCRIPTS_DIRECTORY}/*.sh
sleep 1
printf "done.\n\n"

# Drop stash
git stash drop > /dev/null 2>&1

# Move to web root
cd ${MAGENTO_DIRECTORY}