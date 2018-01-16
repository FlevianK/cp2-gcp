#!/bin/bash
set -e
set -o pipefail
create_cp_user() {
  if ! id -u cp; then
    useradd -m -s /bin/bash cp
  fi
}

install_system_dependencies() {
  sudo apt-get update -y
  sudo apt-get install -y --no-install-recommends git-core curl zlib1g-dev \
    build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev \
    sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev wget    \
    python-software-properties libffi-dev sudo libpq-dev npm supervisor
}

start_supervisor_service() {
  sudo service supervisor start
}

install_node() {
  curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
  sudo apt-get install -y nodejs
}

setup_cp_code() {
  sudo chgrp -R cp  /usr/local
  sudo chmod -R g+rw /usr/local
  rm -rf /home/cp/app
  mkdir -p /home/cp/app
  cd /home/cp/app && git clone https://user:pass@github.com/FlevianK/cp2-document-management-system.git
  sudo chown -R cp:cp /home/cp/app/cp2-document-management-system
  
  sudo su - cp -c 'cd /home/cp/app/cp2-document-management-system && npm install'
}

main() {
  create_cp_user
  install_system_dependencies
  install_node
  setup_cp_code
  start_supervisor_service
}
main "$@"