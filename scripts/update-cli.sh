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
git pull
printf "\nCopying .bashrc... "
cp ${CLI_DIRECTORY}/.bashrc ~/.bashrc
source ~/.bashrc
sleep 1
printf "done. \n\nMaking scripts executable... "
chmod +x -R ${CLI_DIRECTORY}/${SCRIPTS_DIRECTORY}/*
sleep 1
printf "done.\n\n"

# Unstage the copied script files
git checkout -- *

# Move to web root
cd ${MAGENTO_DIRECTORY}

foo