set -ex
set -o pipefail

create_log_files() {
  mkdir -p /var/log/cp
  touch /var/log/cp/cp.out.log /var/log/cp/cp.err.log
  sudo chown -R cp:cp /var/log/cp/cp.out.log /var/log/cp/cp.err.log
}

create_cp_supervisord_conf() {
  sudo cat <<EOF > /etc/supervisor/conf.d/cp.conf
[program:cp]
command= npm start
directory=/home/cp/app/cp2-document-management-system
autostart=true
autorestart=true
startretries=3
stderr_logfile=/var/log/cp/cp.err.log
stdout_logfile=/var/log/cp/cp.out.log
user=cp
EOF
}

start_app() {
  local app_root="/home/cp/app/cp2-document-management-system"

  sudo -u cp bash -c "mkdir -p /home/cp/app/cp2-document-management-system/log"
  supervisorctl update && supervisorctl reload
}

main() {
  echo "startup script invoked at $(date)" >> /tmp/script.log

  create_log_files
  create_cp_supervisord_conf
}

main "$@"
