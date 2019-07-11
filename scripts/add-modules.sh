#!/bin/bash
export TERM=xterm-256color
MAGENTO_DIRECTORY=/var/www/magentos

# Clear the screen
clear

printf "\nBeginning the upgrade process...\n"

# Change into the Magento directory
cd ${MAGENTO_DIRECTORY}
sleep 2

# Update permissions
own	
sleep 2

# Proxy into gitlab via Cloud firewall
configure-proxy
sleep 2

# Disable all cron stuff
disable-cron
sleep 1

# Clear the cron_schedule table so cron jobs don't pile up
clear-cron-schedule
sleep 1

# Update the codebase
update-composer

# Update permissions
own
sleep 2

# Upgrade the database schema
db-upgrade

# Update permissions to allow for di-compile
own
sleep 2

# Compile dependencies
di-compile

# Deploy static content
deploy-content

# Deploy German static content
deploy-content-de

# Sometimes installing modules disables caches -- make sure they're enabled
enable-cache

# Reindex
reindex
sleep 2

# Flush the cache
flush-cache
sleep 2

# Re-enable cron
enable-cron
sleep 2

printf "\nUpgrade finished!\n"

exit