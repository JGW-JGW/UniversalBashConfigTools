#!/bin/bash
function uni_set_timezone() {
  std_prtmsg FS

  if [[ $(date | awk '{print $5}') != "CST" ]]; then
    if ! timedatectl set-timezone Asia/Beijing; then
      std_prtmsg FERR "check info above..."
      std_prtmsg FEND "ERROR"
      return 1
    else
      std_prtmsg FINFO "timezone is set to Asia/Beijing"
      std_prtmsg FEND "DONE"
      return 0
    fi
  else
    std_prtmsg FEND "CORRECT"
    return 0
  fi
}

function uni_set_default_target() {
  std_prtmsg FS

  if [[ $(systemctl get-default) != "graphical.target" ]]; then
    if ! systemctl set-default graphical.target; then
      std_prtmsg FERR "check info above..."
      std_prtmsg FEND "ERROR"
      return 1
    else
      std_prtmsg FINFO "default target is set to \"graphical.target\""
      std_prtmsg FEND "DONE"
      return 0
    fi
  else
    std_prtmsg FEND "CORRECT"
    return 0
  fi

  std_prtmsg FEND "DONE"
}

function uni_rm_ssl_privatekeys() {
  std_prtmsg FS

  local file="/etc/ssl/privatekeys"

  if ! std_backup_file ${file}; then
    std_prtmsg FERR "backup failed, please check info above..."
    std_prtmsg FEND "ERROR"
    return 1
  fi

  std_fix_file_eof ${file}

  [[ -f ${file} ]] && rm -f ${file}

  std_prtmsg FEND "DONE"
}

function uni_set_limits_conf() {
  std_prtmsg FS

  local file="/etc/security/limits.conf"

  if ! std_backup_file ${file}; then
    std_prtmsg FERR "backup failed, please check info above..."
    std_prtmsg FEND "ERROR"
    return 1
  fi

  std_fix_file_eof ${file}

  if std_amid "^\*[[:space:]]+soft[[:space:]]+nofile[[:space:]]+.*$" ${file}; then
    sed -ri "s/^\*[[:space:]]+soft[[:space:]]+nofile[[:space:]]+.*$/*\tsoft\tnofile\t65536" ${file}
  else
    echo -e "*\tsoft\tnofile\t65536" >>${file}
  fi

  std_prtmsg FINFO "soft nofile set to 65536"

  if std_amid "^\*[[:space:]]+hard[[:space:]]+nofile[[:space:]]+.*$" ${file}; then
    sed -ri "s/^\*[[:space:]]+hard[[:space:]]+nofile[[:space:]]+.*$/*\thard\tnofile\t65536" ${file}
  else
    echo -e "*\thard\tnofile\t65536" >>${file}
  fi

  std_prtmsg FINFO "hard nofile set to 65536"

  if std_amid "^\*[[:space:]]+soft[[:space:]]+nproc[[:space:]]+.*$" ${file}; then
    sed -ri "s/^\*[[:space:]]+soft[[:space:]]+nproc[[:space:]]+.*$/*\tsoft\tnproc\t16384" ${file}
  else
    echo -e "*\tsoft\tnproc\t16384" >>${file}
  fi

  std_prtmsg FINFO "soft nproc set to 16384"

  if std_amid "^\*[[:space:]]+hard[[:space:]]+nproc[[:space:]]+.*$" ${file}; then
    sed -ri "s/^\*[[:space:]]+hard[[:space:]]+nproc[[:space:]]+.*$/*\thard\tnproc\t65536" ${file}
  else
    echo -e "*\thard\tnproc\t65536" >>${file}
  fi

  std_prtmsg FINFO "hard nproc set to 65536"

  if std_amid "^\*[[:space:]]+soft[[:space:]]+stack[[:space:]]+.*$" ${file}; then
    sed -ri "s/^\*[[:space:]]+soft[[:space:]]+stack[[:space:]]+.*$/*\tsoft\tstack\t2048" ${file}
  else
    echo -e "*\tsoft\tstack\t2048" >>${file}
  fi

  std_prtmsg FINFO "soft stack set to 2048"

  if std_amid "^\*[[:space:]]+soft[[:space:]]+core[[:space:]]+.*$" ${file}; then
    sed -ri "s/^\*[[:space:]]+soft[[:space:]]+core[[:space:]]+.*$/*\tsoft\tcore\t4294967296" ${file}
  else
    echo -e "*\tsoft\tcore\t4294967296" >>${file}
  fi

  std_prtmsg FINFO "soft core set to 4294967296"

  if std_amid "^\*[[:space:]]+hard[[:space:]]+core[[:space:]]+.*$" ${file}; then
    sed -ri "s/^\*[[:space:]]+hard[[:space:]]+core[[:space:]]+.*$/*\thard\tcore\t4294967296" ${file}
  else
    echo -e "*\thard\tcore\t4294967296" >>${file}
  fi

  std_prtmsg FINFO "hard core set to 4294967296"

  if std_amid "^was[[:space:]]+soft[[:space:]]+core[[:space:]]+.*$" ${file}; then
    sed -ri "s/^was[[:space:]]+soft[[:space:]]+core[[:space:]]+.*$/was\tsoft\tcore\t-1" ${file}
  else
    echo -e "was\tsoft\tcore\t-1" >>${file}
  fi

  std_prtmsg FINFO "was soft core set to -1"

  if std_amid "^was[[:space:]]+hard[[:space:]]+core[[:space:]]+.*$" ${file}; then
    sed -ri "s/^was[[:space:]]+hard[[:space:]]+core[[:space:]]+.*$/was\thard\tcore\t-1" ${file}
  else
    echo -e "was\thard\tcore\t-1" >>${file}
  fi

  std_prtmsg FINFO "was hard core set to -1"

  if std_amid "^was[[:space:]]+soft[[:space:]]+fsize[[:space:]]+.*$" ${file}; then
    sed -ri "s/^was[[:space:]]+soft[[:space:]]+fsize[[:space:]]+.*$/was\tsoft\tfsize\t-1" ${file}
  else
    echo -e "was\tsoft\tfsize\t-1" >>${file}
  fi

  std_prtmsg FINFO "was soft fsize set to -1"

  if std_amid "^was[[:space:]]+hard[[:space:]]+fsize[[:space:]]+.*$" ${file}; then
    sed -ri "s/^was[[:space:]]+hard[[:space:]]+fsize[[:space:]]+.*$/was\thard\tfsize\t-1" ${file}
  else
    echo -e "was\thard\tfsize\t-1" >>${file}
  fi

  std_prtmsg FINFO "was hard fsize set to -1"

  std_prtmsg FEND "DONE"
}

function uni_set_system_conf() {
  std_prtmsg FS

  local file="/etc/systemd/system.conf"

  if ! std_backup_file ${file}; then
    std_prtmsg FERR "backup failed, please check info above..."
    std_prtmsg FEND "ERROR"
    return 1
  fi

  std_fix_file_eof ${file}

  if std_amid "^DefaultTasksMax[[:space:]]*=.*$" ${file}; then
    sed -ri "s/^DefaultTasksMax[[:space:]]*=.*$/DefaultTasksMax=12288/g" ${file}
  else
    echo -e "DefaultTasksMax=12288" >>${file}
  fi

  systemctl daemon-reload

  for file in /sys/fs/cgroup/pids/system.slice/*.service/pids.max; do
    [[ -f ${file} ]] || break
    echo 12288 >"${file}"
  done

  std_prtmsg FINFO "DefaultTasksMax set to 12288"

  std_prtmsg FEND "DONE"
}

function uni_set_sysctl_conf() {
  std_prtmsg FS

  local file="/etc/sysctl.conf"

  if ! std_backup_file ${file}; then
    std_prtmsg FERR "backup failed, please check info above..."
    std_prtmsg FEND "ERROR"
    return 1
  fi

  std_fix_file_eof ${file}

  local proportion=0.5
  local kernel_shmall kernel_shmmax kernel_shmmni
  kernel_shmall=$(std_ceil "$(echo "${PAGE_NUM} ${proportion}" | awk '{printf("%.1f\n", $1 * $2)}')")
  kernel_shmmax=$(std_ceil "$(echo "${MEM_SIZE_B} ${proportion}" | awk '{printf("%.1f\n", $1 * $2)}')")
  kernel_shmmni=${PAGE_SIZE_B}

  if std_amid "^kernel\.shmall[[:space:]]*=.*$" ${file}; then
    sed -ri "s/^kernel\.shmall[[:space:]]*=.*$/kernel.shmall=${kernel_shmall}/g" ${file}
  else
    echo -e "kernel.shmall=${kernel_shmall}" >>${file}
  fi

  std_prtmsg FUNCINFO "\"kernel.shmall\" is set to ${kernel_shmall}"

  if std_amid "^kernel\.shmmax[[:space:]]*=.*$" ${file}; then
    sed -ri "s/^kernel\.shmmax[[:space:]]*=.*$/kernel.shmmax=${kernel_shmmax}/g" ${file}
  else
    echo -e "kernel.shmmax=${kernel_shmmax}" >>${file}
  fi

  std_prtmsg FUNCINFO "\"kernel.shmmax\" is set to ${kernel_shmmax}"

  if std_amid "^kernel\.shmmni[[:space:]]*=.*$" ${file}; then
    sed -ri "s/^kernel\.shmmni[[:space:]]*=.*$/kernel.shmmni=${kernel_shmmni}/g" ${file}
  else
    echo -e "kernel.shmmni=${kernel_shmmni}" >>${file}
  fi

  std_prtmsg FUNCINFO "\"kernel.shmmni\" is set to ${kernel_shmmni}"

  if std_amid "^fs\.file-max[[:space:]]*=.*$" ${file}; then
    sed -ri "s/^fs\.file-max[[:space:]]*=.*$/fs.file-max=6815744/g" ${file}
  else
    echo -e "fs.file-max=6815744" >>${file}
  fi

  std_prtmsg FUNCINFO "\"fs.file-max\" is set to 6815744"

  if std_amid "^kernel\.sem[[:space:]]*=.*$" ${file}; then
    sed -ri "s/^kernel\.sem[[:space:]]*=.*$/kernel.sem=2048 256000 512 8192/g" ${file}
  else
    echo -e "kernel.sem=2048 256000 512 8192" >>${file}
  fi

  std_prtmsg FUNCINFO "\"kernel.sem\" is set to \"2048 256000 512 8192\""

  if std_amid "^vm\.swappiness[[:space:]]*=.*$" ${file}; then
    sed -ri "s/^vm\.swappiness[[:space:]]*=.*$/vm.swappiness=10/g" ${file}
  else
    echo -e "vm.swappiness=10" >>${file}
  fi

  std_prtmsg FUNCINFO "\"vm.swappiness\" is set to 10"

  if std_amid "^net\.ipv6\.conf\.all\.disable_ipv6[[:space:]]*=.*$" ${file}; then
    sed -ri "s/^net\.ipv6\.conf\.all\.disable_ipv6[[:space:]]*=.*$/net.ipv6.conf.all.disable_ipv6=0/g" >>${file}
  else
    echo -e "net.ipv6.conf.all.disable_ipv6=0" >>${file}
  fi

  std_prtmsg FUNCINFO "\"net.ipv6.conf.all.disable_ipv6\" is set to 0"

  if std_amid "^net\.core\.somaxconn[[:space:]]*=.*$" ${file}; then
    sed -ri "s/^net\.core\.somaxconn[[:space:]]*=.*$/net.core.somaxconn=65535/g" ${file}
  else
    echo -e "net.core.somaxconn=65535" >>${file}
  fi

  std_prtmsg FUNCINFO "\"net.core.somaxconn\" is set to 65535"

  if std_amid "^net\.ipv4\.tcp_max_syn_backlog[[:space:]]*=.*$" ${file}; then
    sed -ri "s/^net\.ipv4\.tcp_max_syn_backlog[[:space:]]*=.*$/net.ipv4.tcp_max_syn_backlog=4096/g" ${file}
  else
    echo -e "net.ipv4.tcp_max_syn_backlog=4096" >>${file}
  fi

  std_prtmsg FUNCINFO "\"net.ipv4.tcp_max_syn_backlog\" is set to 4096"

  std_prtmsg FEND "DONE"
}

function uni_set_login_defs() {
  std_prtmsg FS

  local file="/etc/login.defs"

  if ! std_backup_file ${file}; then
    std_prtmsg FERR "backup failed, please check info above..."
    std_prtmsg FEND "ERROR"
    return 1
  fi

  std_fix_file_eof ${file}

  if std_amid "^LOGIN_RETRIES[[:space:]]+.*$" ${file}; then
    sed -ri "s/^LOGIN_RETRIES[[:space:]]+.*$/LOGIN_RETRIES\t6/g" ${file}
  else
    echo -e "LOGIN_RETRIES\t6" >>${file}
  fi

  std_prtmsg FINFO "\"LOGIN_RETRIES\" is set to 6"

  if std_amid "^FAIL_DELAY[[:space:]]+.*$" ${file}; then
    sed -ri "s/^FAIL_DELAY[[:space:]]+.*$/FAIL_DELAY\t3/g" ${file}
  else
    echo -e "FAIL_DELAY\t3" >>${file}
  fi

  std_prtmsg FINFO "\"FAIL_DELAY\" is set to 3"

  std_prtmsg FEND "DONE"
}

function uni_set_ssh_config() {
  std_prtmsg FS

  local file="/etc/ssh/ssh_config"

  if ! std_backup_file ${file}; then
    std_prtmsg FERR "backup failed, please check info above..."
    std_prtmsg FEND "ERROR"
    return 1
  fi

  std_fix_file_eof ${file}

  case ${OS_FULL_NAME} in
  sles11.4)
    if std_amid "^Ciphers[[:space:]]+.*$" ${file}; then
      sed -ri "s/^Ciphers[[:space:]]+.*$/Ciphers aes128-cbc,aes192-cbc,aes256-cbc,aes128-ctr,aes192-ctr,aes256-ctr,3des-cbc/g" ${file}
    else
      echo -e "Ciphers aes128-cbc,aes192-cbc,aes256-cbc,aes128-ctr,aes192-ctr,aes256-ctr,3des-cbc" >>${file}
    fi

    std_prtmsg FINFO "\"Ciphers\" is set to \"aes128-cbc,aes192-cbc,aes256-cbc,aes128-ctr,aes192-ctr,aes256-ctr,3des-cbc\""
    ;;
  *)
    if std_amid "^Ciphers[[:space:]]+.*$" ${file}; then
      sed -ri "s/^Ciphers[[:space:]]+.*$/aes128-gcm,aes256-gcm,aes128-cbc,aes192-cbc,aes256-cbc,aes128-ctr,aes192-ctr,aes256-ctr,3des-cbc/g" ${file}
    else
      echo -e "aes128-gcm,aes256-gcm,aes128-cbc,aes192-cbc,aes256-cbc,aes128-ctr,aes192-ctr,aes256-ctr,3des-cbc" >>${file}
    fi

    std_prtmsg FINFO "\"Ciphers\" is set to \"aes128-gcm,aes256-gcm,aes128-cbc,aes192-cbc,aes256-cbc,aes128-ctr,aes192-ctr,aes256-ctr,3des-cbc\""
    ;;
  esac

  std_prtmsg FEND "DONE"
}

function uni_set_sshd_config() {
  std_prtmsg FS

  local file="/etc/ssh/sshd_config"

  if ! std_backup_file ${file}; then
    std_prtmsg FERR "backup failed, please check info above..."
    std_prtmsg FEND "ERROR"
    return 1
  fi

  std_fix_file_eof ${file}

  if std_amid "^PermitRootLogin[[:space:]]+.*$" ${file}; then
    sed -ri "s/^PermitRootLogin[[:space:]]+.*$/PermitRootLogin\tyes/g" ${file}
  else
    echo -e "PermitRootLogin\tyes" >>${file}
  fi

  std_prtmsg FINFO "\"PermitRootLogin\" is set to \"yes\""

  if std_amid "^Banner[[:space:]]+.*$" ${file}; then
    sed -ri "s|^Banner[[:space:]]+.*$|Banner\t/etc/issue|g" ${file}
  else
    echo -e "Banner\t/etc/issue" >>${file}
  fi

  std_prtmsg FINFO "\"Banner\" is set to \"${file}\""

  case ${OS_FULL_NAME} in
  sles11.4)
    if std_amid "^Ciphers[[:space:]]+.*$" ${file}; then
      sed -ri "s/^Ciphers[[:space:]]+.*$/Ciphers aes128-cbc,aes192-cbc,aes256-cbc,aes128-ctr,aes192-ctr,aes256-ctr,3des-cbc/g" ${file}
    else
      echo -e "\"Ciphers\" aes128-cbc,aes192-cbc,aes256-cbc,aes128-ctr,aes192-ctr,aes256-ctr,3des-cbc" >>${file}
    fi

    std_prtmsg FINFO "\"Ciphers\" is set to \"aes128-cbc,aes192-cbc,aes256-cbc,aes128-ctr,aes192-ctr,aes256-ctr,3des-cbc\""
    ;;
  *)
    if std_amid "^Ciphers[[:space:]]+.*$" ${file}; then
      sed -ri "s/^Ciphers[[:space:]]+.*$/aes128-gcm,aes256-gcm,aes128-cbc,aes192-cbc,aes256-cbc,aes128-ctr,aes192-ctr,aes256-ctr,3des-cbc/g" ${file}
    else
      echo -e "aes128-gcm,aes256-gcm,aes128-cbc,aes192-cbc,aes256-cbc,aes128-ctr,aes192-ctr,aes256-ctr,3des-cbc" >>${file}
    fi

    std_prtmsg FINFO "\"Ciphers\" is set to \"aes128-gcm,aes256-gcm,aes128-cbc,aes192-cbc,aes256-cbc,aes128-ctr,aes192-ctr,aes256-ctr,3des-cbc\""
    ;;
  esac

  std_prtmsg FEND "DONE"
}

function uni_set_issue() {
  std_prtmsg FS

  local file="/etc/issue"

  if ! std_backup_file ${file}; then
    std_prtmsg FERR "backup failed, please check info above..."
    std_prtmsg FEND "ERROR"
    return 1
  fi

  std_fix_file_eof ${file}

  cat >${file} <<'EOF'

[??????]

???????????????????????????????????????????????????????????????????????????????????????

??????????????????????????????????????????

????????????????????????????????????????????????????????????????????????

?????????????????????????????????????????????????????????????????????


[ATTENTION]

Only personnel and programs authorized by the owner of this system can log in or access this system.

Any other form of illegal access is prohibited.

If you are not an authorized user, please do nothing but quit immediately.

Any unauthorized access and operation will be recorded and presented as evidence in court.

EOF

  chmod 444 ${file}

  std_prtmsg FEND "DONE"
}

function uni_set_issue_net() {
  std_prtmsg FS

  local file="/etc/issue.net"

  if ! std_backup_file ${file}; then
    std_prtmsg FERR "backup failed, please check info above..."
    std_prtmsg FEND "ERROR"
    return 1
  fi

  std_fix_file_eof ${file}

  cat >${file} <<'EOF'

[??????]

???????????????????????????????????????????????????????????????????????????????????????

??????????????????????????????????????????

????????????????????????????????????????????????????????????????????????

?????????????????????????????????????????????????????????????????????


[ATTENTION]

Only personnel and programs authorized by the owner of this system can log in or access this system.

Any other form of illegal access is prohibited.

If you are not an authorized user, please do nothing but quit immediately.

Any unauthorized access and operation will be recorded and presented as evidence in court.

EOF

  std_prtmsg FEND "DONE"
}

function uni_set_cron_allow() {
  std_prtmsg FS

  local file="/etc/cron.allow"

  if ! std_backup_file ${file}; then
    std_prtmsg FERR "backup failed, please check info above..."
    std_prtmsg FEND "ERROR"
    return 1
  fi

  std_fix_file_eof ${file}

  if std_amid "^root[[:space:]]*$" ${file}; then
    echo -e "root" >>${file}
  fi

  std_prtmsg FEND "DONE"
}

function uni_set_at_allow() {
  std_prtmsg FS

  local file="/etc/at.allow"

  if ! std_backup_file ${file}; then
    std_prtmsg FERR "backup failed, please check info above..."
    std_prtmsg FEND "ERROR"
    return 1
  fi

  std_fix_file_eof ${file}

  if std_amid "^root[[:space:]]*$" ${file}; then
    echo -e "root" >>${file}
  fi

  std_prtmsg FEND "DONE"
}

function uni_set_fstab() {
  std_prtmsg FS

  local file="/etc/fstab"

  if ! std_backup_file ${file}; then
    std_prtmsg FERR "backup failed, please check info above..."
    std_prtmsg FEND "ERROR"
    return 1
  fi

  std_fix_file_eof ${file}

  cp -fp ${file} ${file}.tmp

  awk -v OFS='\t' '{
    if ($0~/^[[:space:]]*#) {
      print;
    }
    else if (NF == 6 && $5~/[0-2]/ && $6~/[0-2]/ {
      if ($5 != 0) {$5 = 0};
      if ($6 != 0) {$6 = 0};
      print;
    }
    else {
      print;
    }
  }' ${file} >${file}.tmp

  cp -fp ${file}.tmp ${file}

  rm -f ${file}.tmp

  std_prtmsg FEND "DONE"
}

function uni_config_file_permission() {
  std_prtmsg FS

  chmod 444 /etc/issue
  chmod 444 /etc/issue.net
  [[ -d /var/spool/cron/tabs ]] && chmod 600 /var/spool/cron/tabs/*

  std_prtmsg FEND "DONE"
}

function uni_config_dns() {
  std_prtmsg FS

  for file in /etc/resolv.conf /etc/ssh/sshd_config /etc/nscd.conf; do
    if ! std_backup_file ${file}; then
      std_prtmsg FERR "backup failed, please check info above..."
      std_prtmsg FEND "ERROR"
      return 1
    fi

    std_fix_file_eof ${file}
  done

  local primary_dns

  local file="/etc/resolv.conf"

  if [[ ${MACHINE_LOCATION} == "HOME" ]]; then
    primary_dns="192.168.5.254"
  else
    primary_dns="8.8.8.8"
  fi

  echo -e "nameserver\t${primary_dns}" >>${file}
  echo -e "options\ttimeout:1\t\tattempts:1" >>${file}

  std_prtmsg FINFO "\"${file}\" is configured"

  file="/etc/ssh/sshd_config"

  if std_amid "^UseDNS[[:space:]]+.*$" ${file}; then
    sed -ri "s/^UseDNS[[:space:]]+.*$/UseDNS\tno/g" ${file}
  else
    echo -e "UseDNS\tno" >>${file}
  fi

  std_prtmsg FINFO "\"${file}\" is configured"

  file="/etc/nscd.conf"

  if std_amid "persistent[[:space:]]+hosts[[:space:]]+.*$" ${file}; then
    sed -ri "s|persistent[[:space:]]+hosts[[:space:]]+.*$|persistent\t\thosts\tyes|g" ${file}
  else
    echo -e "\tpersistent\t\thosts\tyes" >>${file}
  fi

  nscd -i hosts

  std_prtmsg FINFO "\"${file}\" is configured"

  std_prtmsg FEND "DONE"
}

function uni_activate_sysctl_conf() {
  std_prtmsg FS

  sysctl -p 1>/dev/null

  std_prtmsg FINFO "all parameters of \"/etc/sysctl.conf\" are activated"

  std_prtmsg FEND "DONE"
}

function uni_permit_services() {
  std_prtmsg FS

  for service in sshd vsftpd xinetd nscd ntpd; do
    if std_systemctl is-installed "${service}" | grep -xq "uninstalled"; then
      std_prtmsg FI "\"${service}\" is not found"
    else
      std_systemctl enable ${service}
      std_systemctl restart ${service}
      std_prtmsg FI "${service} is enabled and restarted"
    fi
  done

  std_prtmsg FEND "DONE"
}

function uni_ban_services() {
  std_prtmsg FS

  if chkconfig telnet off 2>&1 | grep -q "No such file or directory"; then
    std_prtmsg FI "\"telnet\" not found"
  else
    chkconfig telnet off
    std_prtmsg FI "\"telnet\" is disabled"
  fi

  for service in firewalld rpcbind.socket rpcbind nfs-server nfs-lock nfs-idmap postfix tftp ypbind exec fingerd pop2 pop3 pop3s printer suucp pure-ftpd uucp apache2 rsh.socket rlogin.socket; do
    if std_systemctl is-installed "${service}" | grep -xq "uninstalled"; then
      std_prtmsg FI "\"${service}\" not found"
    else
      std_systemctl stop ${service}
      std_systemctl disable ${service}
      std_prtmsg FI "${service} is stopped and disabled"
    fi
  done

  std_prtmsg FEND "DONE"
}

function uni_ensure_hostname() {
  std_prtmsg FS

  if ! ubct config hostname "$(hostname)"; then
    std_prtmsg FEND "ERROR"
    return 1
  else
    std_prtmsg FEND "DONE"
    return 0
  fi
}

function uni_config_yum_repo() {
  std_prtmsg FS

  local yum_dir="/etc/yum.repos.d"

  if [[ ! -d ${yum_dir} ]]; then
    std_prtmsg FERR "\"${yum_dir}\" is not a directory"
    std_prtmsg FEND "ERROR"
    return 1
  fi

  if ! std_backup_directory ${yum_dir}; then
    std_prtmsg FERR "backup failed, please check info above..."
    std_prtmsg FEND "ERROR"
    return 3
  fi

  rm -rf ${yum_dir:?}/*

  local filename="${yum_dir}/${OS_FULL_NAME}_${CPU_TYPE}.repo"

  cat >"${filename}" <<EOF
[${OS_FULL_NAME} - Base]
name = ${OS_FULL_NAME} - Base
baseurl = http://mirrors.bupt.edu.cn/centos/7.9.2009/os/x86_64/
gpgcheck = 1
enabled = 1

[${OS_FULL_NAME} - Extras]
name = ${OS_FULL_NAME} - Extras
baseurl = http://mirrors.bupt.edu.cn/centos/7.9.2009/extras/x86_64/
gpgcheck = 1
enabled = 1

[${OS_FULL_NAME} - Updates]
name = ${OS_FULL_NAME} - Updates
baseurl = http://mirrors.huaweicloud.com/centos/7.9.2009/updates/x86_64/
gpgcheck = 1
enabled = 1
EOF

  yum clean all && yum makecache

  std_prtmsg FI "please check \"${filename}\" for details"

  std_prtmsg FEND "DONE"
}

function uni_install_packages_by_yum() {
  std_prtmsg FS

  local package_names

  case ${OS_FULL_NAME} in
  centos-7)
    package_names="vsftpd sysstat nscd ksh expect ntp telnet lftp ftp"
    ;;
  *)
    std_prtmsg FERR "unsupported os: \"${OS_FULL_NAME}\""
    std_prtmsg FEND "ERROR"
    return 2
    ;;
  esac

  for item in ${package_names}; do
    yum -y install "${item}"
    std_prtmsg FI "\"${item}\" installed"
  done

  # ?????????????????????????????????????????????
  yum -y repository-packages "${OS_FULL_NAME} - Updates" install

  std_prtmsg FI "packages in repository \"${OS_FULL_NAME} - Updates\" are installed"

  std_prtmsg FEND "DONE"
}

function uni_set_primary_language() {
  std_prtmsg FS

  LANG="en_US.UTF-8"

  localectl set-locale LANG=en_US.UTF-8

  std_prtmsg FEND "DONE"
}

function uni_set_vsftpd_conf() {
  std_prtmsg FS

  local file="/etc/vsftpd/vsftpd.conf"

  if ! std_backup_file ${file}; then
    std_prtmsg FERR "backup failed, please check info above..."
    std_prtmsg FEND "ERROR"
    return 1
  fi

  std_fix_file_eof ${file}

  if std_amid "^listen[[:space:]]*=.*$" ${file}; then
    sed -ri "s/^listen[[:space:]]*=.*$/listen=YES/g" ${file}
  else
    echo -e "listen=YES" >>${file}
  fi

  std_prtmsg FI "\"listen\" is set to \"YES\""

  if std_amid "^listen_ipv6[[:space:]]*=.*$" ${file}; then
    sed -ri "s/^listen_ipv6[[:space:]]*=.*$/listen_ipv6=NO/g" ${file}
  else
    echo -e "listen_ipv6=NO" >>${file}
  fi

  std_prtmsg FI "\"listen_ipv6\" is set to \"NO\""

  if std_amid "^use_localtime[[:space:]]*=.*$" ${file}; then
    sed -ri "s/^use_localtime[[:space:]]*=.*$/use_localtime=YES/g" ${file}
  else
    echo -e "use_localtime=YES" >>${file}
  fi

  std_prtmsg FI "\"use_localtime\" is set to \"YES\""

  if std_amid "^write_enable[[:space:]]*=.*$" ${file}; then
    sed -ri "s/^write_enable[[:space:]]*=.*$/write_enable=YES/g" ${file}
  else
    echo -e "write_enable=YES" >>${file}
  fi

  std_prtmsg FI "\"write_enable\" is set to \"YES\""

  if std_amid "^local_enable[[:space:]]*=.*$" ${file}; then
    sed -ri "s/^local_enable[[:space:]]*=.*$/local_enable=YES/g" ${file}
  else
    echo -e "local_enable=YES" >>${file}
  fi

  std_prtmsg FI "\"local_enable\" is set to \"YES\""

  if std_amid "^local_umask[[:space:]]*=.*$" ${file}; then
    sed -ri "s/^local_umask[[:space:]]*=.*$/local_umask=022/g" ${file}
  else
    echo -e "local_umask=022" >>${file}
  fi

  std_prtmsg FI "\"local_umask\" is set to \"022\""

  if std_amid "^anonymous_enable[[:space:]]*=.*$" ${file}; then
    sed -ri "s/^anonymous_enable[[:space:]]*=.*$/anonymous_enable=NO/g" ${file}
  else
    echo -e "anonymous_enable=NO" >>${file}
  fi

  std_prtmsg FI "\"anonymous_enable\" is set to \"NO\""

  if std_amid "^xferlog_enable[[:space:]]*=.*$" ${file}; then
    sed -ri "s/^xferlog_enable[[:space:]]*=.*$/xferlog_enable=YES/g" ${file}
  else
    echo -e "xferlog_enable=YES" >>${file}
  fi

  std_prtmsg FI "\"xferlog_enable\" is set to \"YES\""

  if std_amid "^vsftpd_log_file[[:space:]]*=.*$" ${file}; then
    sed -ri "s|^vsftpd_log_file[[:space:]]*=.*$|vsftpd_log_file=/var/log/vsftpd.log|g" ${file}
  else
    echo -e "vsftpd_log_file=/var/log/vsftpd.log" >>${file}
  fi

  std_prtmsg FI "\"vsftpd_log_file\" is set to \"/var/log/vsftpd.log\""

  if std_amid "^ascii_upload_enable[[:space:]]*=.*$" ${file}; then
    sed -ri "s/^ascii_upload_enable[[:space:]]*=.*$/ascii_upload_enable=YES/g" ${file}
  else
    echo -e "ascii_upload_enable=YES" >>${file}
  fi

  std_prtmsg FI "\"ascii_upload_enable\" is set to \"YES\""

  if std_amid "^ascii_download_enable[[:space:]]*=.*$" ${file}; then
    sed -ri "s/^ascii_download_enable[[:space:]]*=.*$/ascii_download_enable=YES/g" ${file}
  else
    echo -e "ascii_download_enable=YES" >>${file}
  fi

  std_prtmsg FI "\"ascii_download_enable\" is set to \"YES\""

  if std_amid "^banner_file[[:space:]]*=.*$" ${file}; then
    sed -ri "s|^banner_file[[:space:]]*=.*$|banner_file=/etc/issue|g" ${file}
  else
    echo -e "banner_file=/etc/issue" >>${file}
  fi

  std_prtmsg FI "\"banner_file\" is set to \"/etc/issue\""

  std_prtmsg FEND "DONE"
}

function uni_ban_ftp_users() {
  std_prtmsg FS

  local file1="/etc/vsftpd/ftpusers"
  local file2="/etc/vsftpd/user_list"

  for file in ${file1} ${file2}; do
    if ! std_backup_file ${file}; then
      std_prtmsg FERR "backup failed, please check info above..."
      std_prtmsg FEND "ERROR"
      return 1
    fi

    std_fix_file_eof ${file}
  done

  local users="root"

  for file in ${file1} ${file2}; do
    for user in ${users}; do
      if ! std_amid "^[[:space:]]*${user}[[:space:]]*$" ${file}; then
        echo -e "${user}" >>${file}
      fi
    done
  done

  std_prtmsg FEND "DONE"
}

function uni_set_profile() {
  std_prtmsg FS

  local file="/etc/profile"

  if ! std_backup_file ${file}; then
    std_prtmsg FERR "backup failed, please check info above..."
    std_prtmsg FEND "ERROR"
    return 1
  fi

  std_fix_file_eof ${file}

  if std_amid "^export[[:space:]]+TMOUT[[:space:]]*=.*$" ${file}; then
    sed -ri "s/^export[[:space:]]+TMOUT[[:space:]]*=.*$/export TMOUT=600/g" ${file}
  else
    echo -e "export TMOUT=600" >>${file}
  fi

  std_prtmsg FI "\"TMOUT\" is set to \"600\""

  if std_amid "^umask[[:space:]]+.*$" ${file}; then
    sed -ri "s/^umask[[:space:]]+.*$/umask 022/g" ${file}
  else
    echo -e "umask 022" >>${file}
  fi

  std_prtmsg FI "\"umask\" is set to \"022\""

  std_prtmsg FEND "DONE"
}

function uni_set_bashrc() {
  std_prtmsg FS

  local file="/etc/bashrc"

  if ! std_backup_file ${file}; then
    std_prtmsg FERR "backup failed, please check info above..."
    std_prtmsg FEND "ERROR"
    return 1
  fi

  std_fix_file_eof ${file}

  if std_amid "^umask[[:space:]]+.*$" ${file}; then
    sed -ri "s/^umask[[:space:]]+.*$/umask 022/g" ${file}
  else
    echo -e "umask 022" >>${file}
  fi

  std_prtmsg FI "\"umask\" is set to \"022\""

  std_prtmsg FEND "DONE"
}

function uni_set_pwquality_conf() {
  std_prtmsg FS

  local file="/etc/security/pwquality.conf"

  if ! std_backup_file ${file}; then
    std_prtmsg FERR "backup failed, please check info above..."
    std_prtmsg FEND "ERROR"
    return 1
  fi

  std_fix_file_eof ${file}

  if std_amid "^minlen[[:space:]]*=.*$" ${file}; then
    sed -ri "s/^minlen[[:space:]]*=.*$/minlen = 8/g" ${file}
  else
    echo -e "minlen = 8" >>${file}
  fi

  std_prtmsg FI "\"minlen\" is set to 8"

  if std_amid "^maxrepeat[[:space:]]*=.*$" ${file}; then
    sed -ri "s/^maxrepeat[[:space:]]*=.*$/maxrepeat = 3/g" ${file}
  else
    echo -e "maxrepeat = 3" >>${file}
  fi

  std_prtmsg FI "\"minlen\" is set to 8"

  if std_amid "^dcredit[[:space:]]*=.*$" ${file}; then
    sed -ri "s/^dcredit[[:space:]]*=.*$/dcredit = -1/g" ${file}
  else
    echo -e "dcredit = -1" >>${file}
  fi

  std_prtmsg FI "\"dcredit\" is set to -1"

  if std_amid "^ucredit[[:space:]]*=.*$" ${file}; then
    sed -ri "s/^ucredit[[:space:]]*=.*$/ucredit = 0/g" ${file}
  else
    echo -e "ucredit = 0" >>${file}
  fi

  std_prtmsg FI "\"ucredit\" is set to 0"

  if std_amid "^lcredit[[:space:]]*=.*$" ${file}; then
    sed -ri "s/^lcredit[[:space:]]*=.*$/lcredit = -1/g" ${file}
  else
    echo -e "lcredit = -1" >>${file}
  fi

  std_prtmsg FI "\"lcredit\" is set to -1"

  if std_amid "^ocredit[[:space:]]*=.*$" ${file}; then
    sed -ri "s/^ocredit[[:space:]]*=.*$/ocredit = -1/g" ${file}
  else
    echo -e "ocredit = -1" >>${file}
  fi

  std_prtmsg FI "\"ocredit\" is set to -1"

  if std_amid "^minclass[[:space:]]*=.*$" ${file}; then
    sed -ri "s/^minclass[[:space:]]*=.*$/minclass = 3/g" ${file}
  else
    echo -e "minclass = 3" >>${file}
  fi

  std_prtmsg FI "\"minclass\" is set to 3"

  std_prtmsg FEND "DONE"
}

function uni_set_system_auth() {
  std_prtmsg FS

  local file="/etc/pam.d/system-auth"

  if ! std_backup_file ${file}; then
    std_prtmsg FERR "backup failed, please check info above..."
    std_prtmsg FEND "ERROR"
    return 1
  fi

  std_fix_file_eof ${file}

  if std_amid "^password[[:space:]]+sufficient[[:space:]]+pam_unix.so[[:space:]]+.*$" ${file}; then
    sed -ri "s/^password[[:space:]]+sufficient[[:space:]]+pam_unix.so[[:space:]]+.*$/password    sufficient    pam_unix.so sha512 shadow nullok try_first_pass use_authtok/g" ${file}
  else
    echo -e "password    sufficient    pam_unix.so sha512 shadow nullok try_first_pass use_authtok" >>${file}
  fi

  std_prtmsg FI "\"password sufficient\" is set to \"pam_unix.so sha512 shadow nullok try_first_pass use_authtok\""

  cp -fp ${file} ${file}.tmp

  if ! std_amid "^auth[[:space:]]+required[[:space:]]+pam_tally2\.so[[:space:]]+onerr=fail[[:space:]]+deny=6[[:space:]]+unlock_time=1800[[:space:]]*$" ${file}; then
    awk '/^auth[[:space:]]+required[[:space:]]+pam_env\.so[[:space:]]*$/ {
      print;
      print "auth        required      pam_tally2.so onerr=fail deny=6 unlock_time=1800";
      next
    }; {
      print
    }' ${file} >${file}.tmp
    cp -fp ${file}.tmp ${file}
  fi

  std_prtmsg FI "\"auth        required      pam_tally2.so onerr=fail deny=6 unlock_time=1800\" is added to \"${file}\""

  if ! std_amid "^account[[:space:]]+required[[:space:]]+pam_tally2\.so[[:space:]]*$" ${file}; then
    awk '/^auth[[:space:]]+required[[:space:]]+pam_deny\.so[[:space:]]*$/ {
      print;
      print "account     required      pam_tally2.so";
      next
    }; {
      print
    }' ${file} >${file}.tmp
    cp -fp ${file}.tmp ${file}
  fi

  std_prtmsg FI "\"account     required      pam_tally2.so\" is added to \"${file}\""

  rm -f ${file}.tmp

  std_prtmsg FEND "DONE"
}

function uni_set_password_auth() {
  std_prtmsg FS

  local file="/etc/pam.d/password-auth"

  if ! std_backup_file ${file}; then
    std_prtmsg FERR "backup failed, please check info above..."
    std_prtmsg FEND "ERROR"
    return 1
  fi

  std_fix_file_eof ${file}

  cp -fp ${file} ${file}.tmp

  if ! std_amid "^auth[[:space:]]+required[[:space:]]+pam_tally2\.so[[:space:]]+onerr=fail[[:space:]]+deny=6[[:space:]]+unlock_time=1800[[:space:]]*$" ${file}; then
    awk '/^auth[[:space:]]+required[[:space:]]+pam_env\.so[[:space:]]*$/ {
      print;
      print "auth        required      pam_tally2.so onerr=fail deny=6 unlock_time=1800";
      next
    }; {
      print
    }' ${file} >${file}.tmp
    cp -fp ${file}.tmp ${file}
  fi

  std_prtmsg FI "\"auth        required      pam_tally2.so onerr=fail deny=6 unlock_time=1800\" is added to \"${file}\""

  if ! std_amid "^account[[:space:]]+required[[:space:]]+pam_tally2\.so[[:space:]]*$" ${file}; then
    awk '/^auth[[:space:]]+required[[:space:]]+pam_deny\.so[[:space:]]*$/ {
      print;
      print "account     required      pam_tally2.so";
      next
    }; {
      print
    }' ${file} >${file}.tmp
    cp -fp ${file}.tmp ${file}
  fi

  std_prtmsg FI "\"account     required      pam_tally2.so\" is added to \"${file}\""

  rm -f ${file}.tmp

  std_prtmsg FEND "DONE"
}

function uni_set_ntp_conf() {
  std_prtmsg FS

  local file="/etc/ntp.conf"

  if ! std_backup_file ${file}; then
    std_prtmsg FERR "backup failed, please check info above..."
    std_prtmsg FEND "ERROR"
    return 1
  fi

  std_fix_file_eof ${file}

  if std_amid "^server[[:space:]]+${REGEX_IP}.*$" ${file}; then
    sed -ri "/^server[[:space:]]+${REGEX_IP}[[:space:]]+iburst$/d" ${file}
  fi

  echo -e "# server 1.1.1.1 iburst" >>${file}

  std_prtmsg FI "ntp server 1.1.1.1 is added to \"${file}\""

  std_prtmsg FEND "DONE"
}

function uni_config_rsyslog() {
  std_prtmsg FS

  local file="/etc/rsyslog.conf"

  if ! std_backup_file ${file}; then
    std_prtmsg FERR "backup failed, please check info above..."
    std_prtmsg FEND "ERROR"
    return 1
  fi

  std_fix_file_eof ${file}

  std_prtmsg FI "do nothing..."

  std_prtmsg FEND "DONE"
}

function uni_config_io_scheduler() {
  std_prtmsg FS

  local file="/etc/udev/rules.d/99-scheduler.rules"

  if ! std_backup_file ${file}; then
    std_prtmsg FERR "backup failed, please check info above..."
    std_prtmsg FEND "ERROR"
    return 1
  fi

  std_fix_file_eof ${file}

  case ${OS_FULL_NAME} in
  kylinV10)
    sed -ri "/^ACTION==.*KERNEL==.*SUBSYSTEM==.*ATTR\{queue\/scheduler\}=.*$/d" ${file}
    cat >>${file} <<'EOF'
ACTION=="add|change", KERNEL=="sda", SUBSYSTEM=="block", ATTR{queue/scheduler}="bfq"
ACTION=="add|change", KERNEL=="sd[b-z]", SUBSYSTEM=="block", ATTR{queue/scheduler}="none"
EOF
    for dev in $(lsblk -S | awk '/^sd/ {print $1}'); do
      local scheduler="/sys/block/${dev}/queue/scheduler"
      if [[ ${dev} == "sda" ]]; then
        [[ $(std_get_dev_scheduler "${dev}") != "bfq" ]] && echo bfq >"${scheduler}"
      else
        [[ $(std_get_dev_scheduler "${dev}") != "none" ]] && echo none >"${scheduler}"
      fi
      std_prtmsg FI "io scheduler of \"${dev}\" is set to \"$(std_get_dev_scheduler "${dev}")\""
    done
    ;;
  *)
    std_prtmsg FERR "unsupported os: \"${OS_FULL_NAME}\""
    std_prtmsg FEND "ERROR"
    return 1
    ;;
  esac

  std_prtmsg FEND "DONE"
}
