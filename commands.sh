# VM Navigation
function www() {
  cd /var/www/magento
}
export -f www

# CLI
function own() {
  printf "\nUpdating permissions...\n"
  www
  sudo chown -R vagrant:vagrant var/cache/ var/page_cache/
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
  bash ~/scripts/modules.sh install
}
export -f install-modules

function uninstall-modules() {
  bash ~/scripts/modules.sh uninstall
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
function enable-varnish() {
  printf "\nEnabling Varnish..."
  stop-web
  switch-ports "varnish"
  start-web
  sudo systemctl enable varnish
}
export -f enable-varnish

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

function disable-varnish() {
  stop-varnish
  stop-web
  switch-ports "web"
  start-web
}
export -f disable-varnish

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

# Elasticsearch
function start-es() {
  printf "\nRestarting Elasticsearch...\n"
  systemctl restart elasticsearch
}
export -f start-es

function stop-es() {
  printf "\nStopping Elasticsearch...\n"
  sudo systemctl stop elasticsearch
}
export -f stop-es

function status-es() {
  sudo systemctl status elasticsearch
}
export -f status-es

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
  systemctl restart rabbitmq-server
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
  bash ~/scripts/cache-warmer.sh
}
export -f warm-cache

function list-procs() {
  clear
  bash ~/scripts/list-processes.sh
}
export -f list-procs

function switch-ports() {
  if [[ ${1} == "varnish" ]]; then
    printf "\nUpdating web server ports (With Varnish)...\n"
    sudo -i sed -i '0,s/listen 80/listen 8080/p' /etc/nginx/sites-available/magento;
  elif [[ ${1} == "web" ]]; then
    printf "\nUpdating web server ports (Without Varnish)...\n"
    sudo -i sed -i '0,s/listen 8080/listen 80/p' /etc/nginx/sites-available/magento;
  fi
    printf "done.\n"
}

function update-cli() {
  printf "\nUpdating the VM CLI...\n"
  add-key
  cd ~/cli/
  git pull
  printf "\nCopying bashrc... "
  cp ~/cli/.bashrc ~/.bashrc
  source ~/.bashrc
  printf "done.\n\n"
  www
}
export -f update-cli

function vm-info() {
  clear
  bash ~/cli/info.sh
}
export -f vm-info

function vm-help() {
  clear
  cat ~/cli/help.txt
}
export -f vm-help
