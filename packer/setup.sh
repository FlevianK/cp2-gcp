#!/bin/bash
set -e
set -o pipefail
create_cp_user() {
  if ! id -u cp; then
    sudo useradd -m -s /bin/bash cp
  fi
}

install_system_dependencies() {
  sudo apt-get update -y
  sudo apt-get install -y --no-install-recommends git-core curl zlib1g-dev \
    build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev \
    sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev wget nodejs     \
    python-software-properties libffi-dev sudo libpq-dev npm
}

start_supervisor_service() {
  sudo service supervisor start
}

setup_cp_code() {
  rm -rf /home/cp/app
  sudo mkdir -p /home/cp/app
  cd /home/cp/app && git clone https://username:pass@github.com/FlevianK/cp2-document-management-system.git
  sudo chown -R cp:cp /home/cp/app/cp2-document-management-system
  
  sudo su - cp -c 'cd /home/cp/app/cp2-document-management-system && npm install'
}

main() {
  create_cp_user

  install_system_dependencies
  setup_cp_code
  start_supervisor_service
}
main "$@"