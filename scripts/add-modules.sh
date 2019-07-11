#!/bin/bash
export TERM=xterm-256color
GROUP=vagrant
USER=vagrant
MAGENTO_DIRECTORY=/var/www/magento
source ~/.bashrc

clear

printf "\n\nBeginning the upgrade process...\n"

cd ${MAGENTO_DIRECTORY}
sleep 2

own	
sleep 2

configure-proxy
sleep 2

disable-cron
sleep 1

clear-cron-schedule
sleep 1

update-composer

own
sleep 2

db-upgrade

own
sleep 2

di-compile

deploy-content

deploy-content-de

enable-cache

reindex
sleep 2

flush-cache
sleep 2

enable-cron
sleep 2

printf "\nUpgrade finished!\n"

exit