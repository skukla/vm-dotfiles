#!/bin/bash
export TERM=xterm-256color
GROUP=vagrant
USER=vagrant
MAGENTO_DIRECTORY=/var/www/magento

clear

printf "\n\nBeginning the update process...\n"

cd ${MAGENTO_DIRECTORY}
sleep 2

printf "\nUpdating permissions..."
chown -R ${GROUP}:${USER} var/cache/ var/page_cache/
chmod -R 777 var/ pub/ app/etc/ generated/
printf "done.\n"
sleep 2

printf "\nAdding SSH keys...\n"
eval $(ssh-agent)
ssh-add ~/.ssh/id_rsa.skukla.gitlab
ssh-add ~/.ssh/id_rsa.skukla.github.magento-cloud
sleep 2

printf "\nDownloading code...\n"
composer update

printf "\nUpdating the database...\n"
./bin/magento setup:upgrade

printf "\nCompiling dependencies...\n"
./bin/magento setup:di:compile

printf "\nDeploying static content..."
./bin/magento set:static-content:deploy -f

printf "\nDeploying German static content..."
./bin/magento setup:static-content:deploy -f de_DE

printf "\nEnabling cache...\n"
./bin/magento cache:enable

printf "\nReindexing...\n"
./bin/magento indexer:reindex
sleep 2

printf "\nClearing cache...\n"
./bin/magento cache:clean
rm -rf var/cache/* var/page_cache/*
sleep 2

printf "\nUpgrade finished!\n"

exit