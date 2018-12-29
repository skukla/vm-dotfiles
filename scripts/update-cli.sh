#!bin/bash
MAGENTO_DIRECTORY=/var/www/magento
CLI_DIRECTORY=~/cli
SCRIPTS_DIRECTORY=scripts
clear
printf "\nUpdating the VM CLI...\n"

# Add SSH Key
printf "\nAdding SSH Key...\n"
eval $(ssh-agent)
ssh-add ~/.ssh/Magento-Cloud

# Update CLI
cd ${CLI_DIRECTORY}

# Stash existing changes
git stash

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
git stash drop

# Move to web root
cd ${MAGENTO_DIRECTORY}