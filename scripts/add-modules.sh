#!/bin/bash
export TERM=xterm-256color
GROUP=vagrant
USER=vagrant
MAGENTO_DIRECTORY=/var/www/magento

clear

printf "\n\nBeginning the upgrade process...\n"

cd ${MAGENTO_DIRECTORY}
sleep 2

printf "\nUpdating permissions..."
chown -R ${GROUP}:${USER} var/cache/ var/page_cache/
chmod -R 777 var/ pub/ app/etc/ generated/
printf "done.\n"
sleep 2

printf "\nProxying through gitlab firewall...\n"
  export GIT_SSH_COMMAND='ssh -o ProxyCommand="nc -x 127.0.0.1:8889 %h %p"' HTTP_PROXY=http://127.0.0.1:8888
  curl -sS https://raw.githubusercontent.com/PMET-public/magento-cloud-extension/0.0.23/sh-scripts/lib.sh \
    https://raw.githubusercontent.com/PMET-public/magento-cloud-extension/0.0.23/sh-scripts/configure-proxies.sh | env ext_ver=0.0.23 tab_url=https://github.com bash
  sleep 1
  printf "\nAdding SSH keys...\n"
  eval $(ssh-agent)
  ssh-add ~/.ssh/id_rsa.skukla.gitlab
  ssh-add ~/.ssh/id_rsa.skukla.github
sleep 2

printf "\nDownloading code...\n"
composer update

printf "\nUpdating permissions..."
chown -R ${GROUP}:${USER} var/cache/ var/page_cache/
chmod -R 777 var/ pub/ app/etc/ generated/
printf "done.\n"
sleep 2

printf "\nUpdating the database...\n"
./bin/magento setup:upgrade

printf "\nUpdating permissions..."
chown -R ${GROUP}:${USER} var/cache/ var/page_cache/
chmod -R 777 var/ pub/ app/etc/ generated/
printf "done.\n"
sleep 2

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