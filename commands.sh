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
  
  printf "\nUpdating permissions...\n"
  www
  sudo chown -R ${GROUP}:${USER} var/cache/ var/page_cache/
  sudo chmod -R 777 var/ pub/ app/etc/ generated/
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
  printf "\nReindexing...\n"
  ./bin/magento indexer:reindex
}
export -f reindex

function clean() {
  reindex
  cache
}
export -f clean

function cron() {
  www
  printf "\nRunning cron jobs...\n"
  ./bin/magento cron:run
}
export -f cron

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
  ./bin/magento setup:static-content:deploy de_DE -f
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

# Extensions and Upgrades
function add-key() {
  printf "\nAdding SSH Key...\n"
  eval $(ssh-agent)
  ssh-add ~/.ssh/Magento-Cloud
}
export -f add-key

function update-composer() {
  www
  add-key
  composer update
}
export -f update-composer

function add-modules() {
  www
  db-upgrade
  di-compile
  deploy-content
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
  www
  update-composer
  add-modules
}
export -f upgrade

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
  CLI_DIRECTORY=~/cli
  SCRIPTS_DIRECTORY=scripts
  bash ${CLI_DIRECTORY}/${SCRIPTS_DIRECTORY}/update-cli.sh
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
  CLI_DIRECTORY=~/cli
  SCRIPTS_DIRECTORY=scripts
  bash ${CLI_DIRECTORY}/${SCRIPTS_DIRECTORY}/url-check.sh
}
export -f get-url

function set-url() {
  CLI_DIRECTORY=~/cli
  SCRIPTS_DIRECTORY=scripts
  bash ${CLI_DIRECTORY}/${SCRIPTS_DIRECTORY}/url-check.sh foobar
}
export -f set-url