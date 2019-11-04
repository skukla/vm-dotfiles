# VM Navigation
function www() {
  MAGENTO_DIRECTORY=/var/www/magento
  cd ${MAGENTO_DIRECTORY}
}
export -f www

# CLI
function own() {
  GROUP=vagrant
  USER=vagrant
  
  printf "\nUpdating permissions..."
  www
  sudo chown -R ${GROUP}:${USER} var/cache/ var/page_cache/
  sudo chmod -R 777 var/ pub/ app/etc/ generated/
  sleep 1
  printf "done.\n"
}
export -f own

function cache() {
  www
  printf "\nClearing cache...\n"
  ./bin/magento cache:clean
  rm -rf var/cache/* var/page_cache/*
}
export -f cache

function flush-cache() {
  www
  printf "\nFlushing cache...\n"
  ./bin/magento cache:flush
  rm -rf var/cache/* var/page_cache/*
}
export -f flush-cache

function enable-cache() {
  printf "\nEnabling cache...\n"
  www
  ./bin/magento cache:enable
}
export -f enable-cache

function disable-cache() {
  printf "\nDisabling cache...\n"
  www
  ./bin/magento cache:disable
}
export -f disable-cache

function disable-cms-cache() {
  printf "\nDisabling Layout, Block, and Full Page cache...\n"
  www
  ./bin/magento cache:disable layout block_html full_page
}
export -f disable-cms-cache

function reindex() {
  www
  printf "\nInvalidating indexes...\n"
  ./bin/magento indexer:reset
  printf "\nReindexing...\n"
  ./bin/magento indexer:reindex
}
export -f reindex

function clean() {
  reindex
  cache
}
export -f clean

function enable-cron() {
  printf "\nEnabling cron...\n"
  www
  ./bin/magento cron:install
  printf "done.\n"
}
export -f enable-cron

function cron() {
  printf "\nRunning cron jobs...\n"
  www
  ./bin/magento cron:run
}
export -f cron

function disable-cron() {
  printf "\nDisabling cron...\n"
  www
  ./bin/magento cron:remove
  crontab -r
  printf "done.\n" 
}
export -f disable-cron

function staging() {
  printf "\nUpdating Staging Dashboard...\n"
  reindex
  cron
  cron
  cache
}
export -f staging

function list-modules() {
  www
  ./bin/magento module:status
}
export -f list-modules

function install-modules() {
  CLI_DIRECTORY=~/cli
  SCRIPTS_DIRECTORY=scripts
  bash ${CLI_DIRECTORY}/${SCRIPTS_DIRECTORY}/modules.sh install
}
export -f install-modules

function uninstall-modules() {
  CLI_DIRECTORY=~/cli
  bash ${CLI_DIRECTORY}/${SCRIPTS_DIRECTORY}/modules.sh uninstall
}
export -f uninstall-modules

function enable-all-modules() {
  printf "\nEnabling all modules...\n"
  www
  ./bin/magento module:enable --all
}
export -f enable-all-modules

function process-catalogs() {
  printf "\nProcessing shared catalog(s)...\n"
  www
  reindex
  cache
  cron
}
export -f process-catalogs

function db-upgrade() {
  printf "\nUpgrading database schema...\n"
  www
  ./bin/magento setup:upgrade
}
export -f db-upgrade

function di-compile() {
  printf "\nCompiling dependency injections...\n"
  www && ./bin/magento setup:di:compile
}
export -f di-compile

function deploy-content() {
  printf "\nDeploying static content...\n"
  www
  ./bin/magento setup:static-content:deploy -f
}
export -f deploy-content

function deploy-content-de() {
  printf "\nDeploying German theme static content...\n"
  www
  ./bin/magento setup:static-content:deploy -f de_DE
}
export -f deploy-content-de

function dev-mode() {
  printf "\nSwitching to Developer mode...\n"
  www
  ./bin/magento deploy:mode:set developer
  cache
}
export -f dev-mode

function prod-mode() {
  printf "\nSwitching to Production mode...\n"
  www
  ./bin/magento deploy:mode:set production
  cache
}
export -f prod-mode

function configure-proxy() {
  printf "\nProxying through gitlab firewall...\n"
  export GIT_SSH_COMMAND='ssh -o ProxyCommand="nc -x 127.0.0.1:8889 %h %p"' HTTP_PROXY=http://127.0.0.1:8888
  curl -sS https://raw.githubusercontent.com/PMET-public/magento-cloud-extension/0.0.25/sh-scripts/lib.sh \
    https://raw.githubusercontent.com/PMET-public/magento-cloud-extension/0.0.25/sh-scripts/configure-proxies.sh | env ext_ver=0.0.23 tab_url=https://github.com bash
  sleep 1
  printf "\nAdding SSH keys...\n"
  eval $(ssh-agent)
  ssh-add ~/.ssh/id_rsa.skukla.gitlab
  ssh-add ~/.ssh/id_rsa.skukla.github
}
export -f configure-proxy

function add-keys() {
  printf "\nAdding SSH keys...\n"
  eval $(ssh-agent)
  ssh-add ~/.ssh/id_rsa.skukla.gitlab
  ssh-add ~/.ssh/id_rsa.skukla.github
}
export -f add-keys

function update-composer() {
  printf "\nDownloading code...\n"
  www
  composer update
}
export -f update-composer

function add-modules() {
  www
  apply-patches
  own
  db-upgrade
  di-compile
  deploy-content
  deploy-content-de
  enable-cache
  clean
}
export -f add-modules

function refresh-theme() {
  www
  rm -rf var/view_preprocessed
  deploy-content
  cache
}
export -f refresh-theme

function upgrade() {
  clear
  printf "Beginning the upgrade process...\n"
  www
  own 
  configure-proxy
  disable-cron
  clear-cron-schedule
  update-composer
  add-modules
  enable-cron
  printf "\nUpgrade finished!\n"
}

export -f upgrade

# PHP-FPM
function start-fpm73() {
  printf "\nRestarting PHP-FPM 7.3...\n"
  sudo systemctl restart php7.3-fpm
}
export -f start-fpm73

function stop-fpm73() {
  printf "\nStopping PHP-FPM 7.3...\n"
  sudo systemctl stop php7.3-fpm
}
export -f stop-fpm73

function status-fpm73() {
  sudo systemctl status php7.2-fpm
}
export -f status-fpm73

function start-fpm72() {
  printf "\nRestarting PHP-FPM 7.2...\n"
  sudo systemctl restart php7.2-fpm
}
export -f start-fpm72

function stop-fpm72() {
  printf "\nStopping PHP-FPM 7.2...\n"
  sudo systemctl stop php7.2-fpm
}
export -f stop-fpm72

function status-fpm72() {
  sudo systemctl status php7.2-fpm
}
export -f status-fpm72

function start-fpm71() {
  printf "\nRestarting PHP-FPM 7.1...\n"
  sudo systemctl restart php7.1-fpm
}
export -f start-fpm71

function stop-fpm71() {
  printf "\nStopping PHP-FPM 7.1...\n"
  sudo systemctl stop php7.1-fpm
}
export -f stop-fpm71

function status-fpm71() {
  sudo systemctl status php7.1-fpm
}
export -f status-fpm71

function start-fpm70() {
  printf "\nRestarting PHP-FPM 7.0...\n"
  sudo systemctl restart php7.0-fpm
}
export -f start-fpm70

function stop-fpm70() {
  printf "\nStopping PHP-FPM 7.0...\n"
  sudo systemctl stop php7.0-fpm
}
export -f stop-fpm70

function status-fpm70() {
  sudo systemctl status php7.0-fpm
}
export -f status-fpm70

# PHP Installation and Removal
function list-php() {
  ls -la /etc/php
}
export -f list-php

function install-php() {
  printf "\nSo, you wanna install PHP, eh?...\n"
  sleep 1
  printf "\nGot it. Which PHP version would you like to install?\n\n"
  read $VERSION
  printf "\n10-4!\n"
  printf "\nAttempting to install PHP ${VERSION}..."
  sleep 1
  sudo apt update -y && sudo add-apt-repository ppa:ondrej/php && sudo apt update -y && sudo apt install -y php${VERSION} libapache2-mod-php${VERSION} php${VERSION}-common php${VERSION}-gd php${VERSION}-mysql php${VERSION}-mcrypt php${VERSION}-curl php${VERSION}-intl php${VERSION}-xsl php${VERSION}-mbstring php${VERSION}-zip php${VERSION}-bcmath php${VERSION}-iconv php${VERSION}-soap php${VERSION}-fpm 
  printf "\ndone.\n"
}
export -f install-php

function remove-php() {
  printf "\nSo, you wanna remove PHP, eh?...\n"
  sleep 1
  printf "\nGot it. Which PHP version would you like to remove?\n\n"
  read $VERSION
  printf "\n10-4!\n\nAttempting to remove PHP ${VERSION}...\n"
  sleep 1
  exit
  sudo apt-get purge php${VERSION}-common -y
  printf "\ndone.\n"
}
export -f remove-php

# Web
function start-web() {
  printf "\nRestarting the web server...\n"
  sudo systemctl restart nginx
}
export -f start-web

function stop-web() {
  printf "\nStopping the web server...\n"
  sudo systemctl stop nginx
}
export -f stop-web

function status-web() {
  sudo systemctl status nginx
}
export -f status-web

# Varnish
function start-varnish() {
  printf "\nRestarting Varnish...\n"
  sudo systemctl restart varnish
}
export -f start-varnish

function stop-varnish() {
  printf "\nStopping Varnish...\n"
  sudo systemctl stop varnish
}
export -f stop-varnish

function status-varnish() {
  sudo systemctl status varnish
}
export -f status-varnish

function varnishstat() {
  sudo varnishstat
}

function varnishhist() {
  sudo varnishhist
}
export -f varnishhist

# Database
function db() {
  mysql -u magento -ppassword
}
export -f db

function start-db() {
  printf "\nRestarting the database...\n"
  sudo systemctl restart mysql
}
export -f start-db

function stop-db() {
  printf "\nStopping the database...\n"
  sudo systemctl stop mysql
}
export -f stop-db

function status-db() {
  sudo systemctl status mysql
}
export -f status-db

# Redis
function enable-redis() {
  printf "\nEnabling Redis...\n"
  sudo systemctl enable redis
}
export -f enable-redis

function start-redis() {
  printf "\nRestarting the Redis server...\n"
  sudo systemctl restart redis-server
}
export -f start-redis

function stop-redis() {
  printf "\nStopping the Redis server...\n"
  sudo systemctl stop redis-server
}
export -f stop-redis

function status-redis() {
  sudo systemctl status redis-server
}
export -f status-redis

function monitor-redis() {
  printf "\nTurning on Redis Monitor..."
  sudo redis-cli
  monitor
}
export -f monitor-redis

# Elasticsearch
function enable-elasticsearch() {
  printf "\nEnabling Elasticsearch...\n"
  sudo systemctl enable elasticsearch
}
export -f enable-elasticsearch

function start-elasticsearch() {
  printf "\nRestarting Elasticsearch...\n"
  sudo systemctl restart elasticsearch
}
export -f start-elasticsearch

function stop-elasticsearch() {
  printf "\nStopping Elasticsearch...\n"
  sudo systemctl stop elasticsearch
}
export -f stop-elasticsearch

function status-elasticsearch() {
  sudo systemctl status elasticsearch
}
export -f status-elasticsearch

function disable-elasticsearch() {
  printf "\nDisabling Elasticsearch...\n"
  sudo systemctl disable elasticsearch
}
export -f disable-elasticsearch

# Kibana
function start-kibana() {
  printf "\nRestarting Kibana...\n"
  systemctl restart kibana
}
export -f start-kibana

function stop-kibana() {
  printf "\nStopping Kibana...\n"
  sudo systemctl stop kibana
}
export -f stop-kibana

function status-kibana() {
  sudo systemctl status kibana
}
export -f status-kibana

# RabbitMQ
function start-rabbitmq() {
  printf "\nRestarting RabbitMQ Server...\n"
  sudo systemctl restart rabbitmq-server
}
export -f start-rabbitmq

function stop-rabbitmq() {
  printf "\nStopping RabbitMQ Server...\n"
  sudo systemctl stop rabbitmq-server
}
export -f stop-rabbitmq

function status-rabbitmq() {
  sudo systemctl status rabbitmq-server
}
export -f status-rabbitmq

# Tools
function warm-cache() {
  CLI_DIRECTORY=~/cli
  SCRIPTS_DIRECTORY=scripts
  bash ${CLI_DIRECTORY}/${SCRIPTS_DIRECTORY}/cache-warmer.sh
}
export -f warm-cache

function update-cli() {
  MAGENTO_DIRECTORY=/var/www/magento
  HOME_DIRECTORY=~
  CLI_DIRECTORY=~/cli
  SCRIPTS_DIRECTORY=scripts
  clear
  printf "Updating the VM CLI...\n"

  # Add SSH Key
  add-keys

  # Update CLI
  cd ${CLI_DIRECTORY}

  # Stash existing changes
  git stash > /dev/null 2>&1

  # Pull new changes and set permissions
  git pull
  printf "\nInstalling commands... "
  # Install scripts and motd
  source ${HOME_DIRECTORY}/.bashrc
  sudo cp ${CLI_DIRECTORY}/${SCRIPTS_DIRECTORY}/motd.sh /etc/update-motd.d/01-custom
  sleep 1
  printf "done. \n\nMaking scripts executable... "
  sudo chmod +x ${CLI_DIRECTORY}/${SCRIPTS_DIRECTORY}/*.sh
  sudo chmod +x /etc/update-motd.d/01-custom
  sleep 1
  printf "done.\n\n"

  # Drop stash
  git stash drop > /dev/null 2>&1

  # Move to web root
  cd ${MAGENTO_DIRECTORY}
}
export -f update-cli

function vm-help() {
  CLI_DIRECTORY=~/cli
  clear
  cat ${CLI_DIRECTORY}/help.txt
}
export -f vm-help

function mount-share() {
  HOST_FOLDER_NAME=$(vmware-hgfsclient)
  BOLD=$(tput bold)
  NORMAL=$(tput sgr0)
  clear
  sleep 1
  printf "\nSo, you wanna mount a shared folder, eh?...\n"
  sleep 1
  printf "\nCool, let me grab the folder you've chosen to share on your system...\n"
  sleep 2
  printf "\nLooks like you want to share the following folder: ${BOLD}${HOST_FOLDER_NAME}\n"
  sleep 1
  printf "\n${NORMAL}What folder would you like to mount ${BOLD}${HOST_FOLDER_NAME} to inside the VM?: "
  read $GUEST_FOLDER_NAME
  printf "\nMounting ${HOST_FOLDER_NAME} to ${GUEST_FOLDER_NAME}..."
  sleep 1
  sudo vmhgfs-fuse -o nonempty -o allow_other .host:${HOST_FOLDER_NAME} /vagrant
  printf "done."
  sleep 1
  printf "\n\nHere are the contents of ${HOST_FOLDER_NAME}:\n\n"
  sleep 1
  cd ${GUEST_FOLDER_NAME}
  ll
}
export -f mount-share

function get-url() {
  MAGENTO_DIRECTORY=/var/www/magento
  IP=$(hostname -I)
  HOSTNAME=$(hostname)
  clear
  printf "Hold up, grabbing your machine's IP and the current hostname..."
  sleep 1
  printf "done.\n\n"
  sleep 1
  printf "Add the following entry to your machine's /etc/hosts file:\n\n${IP}\t${HOSTNAME}\n\n"
}
export -f get-url

function set-url() {
  CLI_DIRECTORY=~/cli
  SCRIPTS_DIRECTORY=scripts
  sudo bash ${CLI_DIRECTORY}/${SCRIPTS_DIRECTORY}/url-check.sh
}
export -f set-url

function motd() {
  cat /var/run/motd.dynamic
}
export -f motd

function cloud-login() {
  magento-cloud auth:password-login
}
export -f cloud-login

function cloud-logout() {
  magento-cloud logout
}
export -f cloud-logout

function clear-cron-schedule() {
  printf "\nClearing the cron schedule database table..."
  mysql --login-path=local -e "USE magento;DELETE FROM cron_schedule;"
  sleep 1
  printf "done.\n"
}
export -f clear-cron-schedule

function apply-patches() {
  MAGENTO_DIRECTORY=/var/www/magento
  VERSION=2.3.3
  printf "\nGetting patch list...\n"
  www
  cd ../cloud
  git checkout pmet-${VERSION}-demo
  git pull
  sleep 1
  printf "done.\n"
  sleep 1
  printf "\nCopying patches..."
  cp m2-hotfixes/* ${MAGENTO_DIRECTORY}/m2-hotfixes/
  sleep 1
  printf "done. \n"
  sleep 1
  printf "\nApplying patches...\n"
  sleep 1
  www
  php vendor/magentoese/ece-tools/bin/ece-tools patch
}
export -f apply-patches

function show-help() {
  bash ~/cli/scripts/show-help.sh 
}
export -f show-help
