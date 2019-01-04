#!/bin/bash
export TERM=xterm-256color
MAGENTO_DIRECTORY=/var/www/magento
CLI_DIRECTORY=/home/vagrant/cli
SCRIPTS_DIRECTORY=scripts
BASE_URL=$(cd ${MAGENTO_DIRECTORY} && ./bin/magento config:show web/unsecure/base_url)
NEW_URL=$1
IP=$(hostname -I)
HOSTNAME=$(hostname)
BOLD=$(tput bold)
REG=$(tput sgr0)

# Clear the screen
clear

# Get current Base URL
printf "So you wanna change the Base URL, eh?..\n\n"
sleep 1
printf "Cool, your current Base URL is: ${BASE_URL}\n"

# Ask for the new URL
printf "\nWhat's your new URL? (e.g. luma.com): "
sleep 1

# Read in user input if trigged from CLI, else the variable will be automatically passed
if [ -z ${NEW_URL} ]; then
  read NEW_URL
else
  printf ${NEW_URL}
fi

# Set the new base URL
printf "\nSetting the new Base URL...\n"
cd ${MAGENTO_DIRECTORY}
./bin/magento config:set web/unsecure/base_url "http://${NEW_URL}/"
sleep 1
BASE_URL=$(cd ${MAGENTO_DIRECTORY} && ./bin/magento config:show web/unsecure/base_url)
printf "\nBase URL set to: ${BASE_URL}\n"
sleep 1

# Set the new email domain
printf "\nSetting the new Sender Email domain...\n"
./bin/magento config:set customer/create_account/email_domain ${NEW_URL}
sleep 1

# Resetting store email addresses
printf "\nSetting the new Store Email Addresses...\n"
./bin/magento config:set trans_email/ident_general/email info@${NEW_URL}
./bin/magento config:set trans_email/ident_sales/email sales@${NEW_URL}
./bin/magento config:set trans_email/ident_support/email support@${NEW_URL}
./bin/magento config:set trans_email/ident_custom1/email custom1@${NEW_URL}
./bin/magento config:set trans_email/ident_custom2/email custom2@${NEW_URL} 
sleep 1

# Set the new hostname
printf "\nSetting hostname and Samba name to match new URL (This might take a little bit)..."
sleep 1
sudo hostnamectl set-hostname ${NEW_URL}
sudo sed -i "s|${HOSTNAME}|${NEW_URL}|g" /etc/hosts
sudo sed -i "s|${HOSTNAME}|${NEW_URL}|g" /etc/samba/smb.conf
sleep 3

# Get the new hostname
HOSTNAME=$(hostname)
printf "done.\n\nHostname set to: ${HOSTNAME}\n"
printf "\nRestarting Samba server..."
sudo service smbd restart
sleep 1
printf "done.\n\n"
sleep 1

# Update sitemap and cache warmer
if [ -e ${CLI_DIRECTORY}/${SCRIPTS_DIRECTORY}/cache-warmer.sh ]; then

  # Cache warmer
  printf "Updating sitemap and cache warmer...\n";
  sed -i -e "s|http://${BASE_URL}/|http://${NEW_URL}/|g" "${CLI_DIRECTORY}/${SCRIPTS_DIRECTORY}/cache-warmer.sh";
  sleep 1
  printf "Cache warmer url reset to: http://${NEW_URL}/\n";

  # Sitemap(s) (Luma)
  if [ -e ${MAGENTO_DIRECTORY}/pub/luma.xml ]; then
    sed -i -e "s|http://${BASE_URL}/|http://${NEW_URL}/|g" "${MAGENTO_DIRECTORY}/pub/luma.xml";
    sleep 1
    printf "Luma site map url reset to: http://${NEW_URL}/\n";
  else
    printf "You don't have a luma.xml sitemap file, so we'll skip it...\n";
  fi

  # Venia
  if [ -e ${MAGENTO_DIRECTORY}/pub/venia.xml ]; then
    sed -i -e "s|http://${BASE_URL}/|http://${NEW_URL}/|g" "${MAGENTO_DIRECTORY}/pub/venia.xml";
    sleep 1
    printf "Venia site map url reset to: http://${NEW_URL}/\n";
  else
    printf "You don't have a venia.xml sitemap file, so we'll skip it...\n";
  fi

  # Custom
  if [ -e ${MAGENTO_DIRECTORY}/pub/custom.xml ]; then
    sed -i -e "s|http://${BASE_URL}/|http://${NEW_URL}/|g" "${MAGENTO_DIRECTORY}/pub/custom.xml";
    sleep 1
    printf "Custom site map url reset to: http://${NEW_URL}/\n";
  else
    printf "You don't have a custom.xml sitemap file, so we'll skip it...\n";
  fi
else
  printf "Looks like you're missing the cache-warmer script, so we'll skip it...\n";
fi
sleep 1

# Clean config cache
printf "\nClearing config cache...\n"
./bin/magento cache:clean config
sleep 1

# Show Restart message and hosts entry
printf "\nDone. ${BOLD}Please restart the machine with the VMWare GUI to finish the process."
printf "\n\n${REG}Add the following entry to your machine's /etc/hosts file:\n\n${IP}\t${HOSTNAME}\n\n"
sleep 2
exit
