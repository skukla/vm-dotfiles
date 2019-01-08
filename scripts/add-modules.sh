#!/bin/bash
GROUP=vagrant
USER=vagrant
MAGENTO_DIRECTORY=/var/www/magento

cd ${MAGENTO_DIRECTORY} 

printf "Updating permissions..."
chown -R ${GROUP}:${USER} var/cache/ var/page_cache/
chmod -R 777 var/ pub/ app/etc/ generated/
printf "done.\n"

printf "\nAdding SSH keys...\n"
eval $(ssh-agent)
ssh-add ~/.ssh/id_rsa.skukla.gitlab
ssh-add ~/.ssh/id_rsa.skukla.github.magento-cloud

printf "\nRemoving cron...\n"
./bin/magento cron:remove
crontab -r

printf "\nDownloading code...\n"
composer update

printf "\nUpdating the database...\n"
./bin/magento setup:upgrade

printf "\nCompiling dependencies...\n"
./bin/magento setup:di:compile

printf "\nDeploying static content..."
./bin/magento set:static-content:deploy -f

printf "\nReindexing...\n"
./bin/magento indexer:reindex

exit