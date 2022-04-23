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

  std_prtmsg FUNCINFO "kernel.shmall is set to ${kernel_shmall}"

  if std_amid "^kernel\.shmmax[[:space:]]*=.*$" ${file}; then
    sed -ri "s/^kernel\.shmmax[[:space:]]*=.*$/kernel.shmmax=${kernel_shmmax}/g" ${file}
  else
    echo -e "kernel.shmmax=${kernel_shmmax}" >>${file}
  fi

  std_prtmsg FUNCINFO "kernel.shmmax is set to ${kernel_shmmax}"

  if std_amid "^kernel\.shmmni[[:space:]]*=.*$" ${file}; then
    sed -ri "s/^kernel\.shmmni[[:space:]]*=.*$/kernel.shmmni=${kernel_shmmni}/g" ${file}
  else
    echo -e "kernel.shmmni=${kernel_shmmni}" >>${file}
  fi

  std_prtmsg FUNCINFO "kernel.shmmni is set to ${kernel_shmmni}"

  if std_amid "^fs\.file-max[[:space:]]*=.*$" ${file}; then
    sed -ri "s/^fs\.file-max[[:space:]]*=.*$/fs.file-max=6815744/g" ${file}
  else
    echo -e "fs.file-max=6815744" >>${file}
  fi

  std_prtmsg FUNCINFO "fs.file-max is set to 6815744"

  if std_amid "^kernel\.sem[[:space:]]*=.*$" ${file}; then
    sed -ri "s/^kernel\.sem[[:space:]]*=.*$/kernel.sem=2048 256000 512 8192/g" ${file}
  else
    echo -e "kernel.sem=2048 256000 512 8192" >>${file}
  fi

  std_prtmsg FUNCINFO "kernel.sem is set to \"2048 256000 512 8192\""

  if std_amid "^vm\.swappiness[[:space:]]*=.*$" ${file}; then
    sed -ri "s/^vm\.swappiness[[:space:]]*=.*$/vm.swappiness=10/g" ${file}
  else
    echo -e "vm.swappiness=10" >>${file}
  fi

  std_prtmsg FUNCINFO "vm.swappiness is set to 10"

  if std_amid "^net\.ipv6\.conf\.all\.disable_ipv6[[:space:]]*=.*$" ${file}; then
    sed -ri "s/^net\.ipv6\.conf\.all\.disable_ipv6[[:space:]]*=.*$/net.ipv6.conf.all.disable_ipv6=0/g" >>${file}
  else
    echo -e "net.ipv6.conf.all.disable_ipv6=0" >>${file}
  fi

  std_prtmsg FUNCINFO "net.ipv6.conf.all.disable_ipv6 is set to 0"

  if std_amid "^net\.core\.somaxconn[[:space:]]*=.*$" ${file}; then
    sed -ri "s/^net\.core\.somaxconn[[:space:]]*=.*$/net.core.somaxconn=65535/g" ${file}
  else
    echo -e "net.core.somaxconn=65535" >>${file}
  fi

  std_prtmsg FUNCINFO "net.core.somaxconn is set to 65535"

  if std_amid "^net\.ipv4\.tcp_max_syn_backlog[[:space:]]*=.*$" ${file}; then
    sed -ri "s/^net\.ipv4\.tcp_max_syn_backlog[[:space:]]*=.*$/net.ipv4.tcp_max_syn_backlog=4096/g" ${file}
  else
    echo -e "net.ipv4.tcp_max_syn_backlog=4096" >>${file}
  fi

  std_prtmsg FUNCINFO "net.ipv4.tcp_max_syn_backlog is set to 4096"

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

  std_prtmsg FINFO "LOGIN_RETRIES is set to 6"

  if std_amid "^FAIL_DELAY[[:space:]]+.*$" ${file}; then
    sed -ri "s/^FAIL_DELAY[[:space:]]+.*$/FAIL_DELAY\t3/g" ${file}
  else
    echo -e "FAIL_DELAY\t3" >>${file}
  fi

  std_prtmsg FINFO "FAIL_DELAY is set to 3"

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

    std_prtmsg FINFO "Ciphers is set to \"aes128-cbc,aes192-cbc,aes256-cbc,aes128-ctr,aes192-ctr,aes256-ctr,3des-cbc\""
    ;;
  *)
    if std_amid "^Ciphers[[:space:]]+.*$" ${file}; then
      sed -ri "s/^Ciphers[[:space:]]+.*$/aes128-gcm,aes256-gcm,aes128-cbc,aes192-cbc,aes256-cbc,aes128-ctr,aes192-ctr,aes256-ctr,3des-cbc/g" ${file}
    else
      echo -e "aes128-gcm,aes256-gcm,aes128-cbc,aes192-cbc,aes256-cbc,aes128-ctr,aes192-ctr,aes256-ctr,3des-cbc" >>${file}
    fi

    std_prtmsg FINFO "Ciphers is set to \"aes128-gcm,aes256-gcm,aes128-cbc,aes192-cbc,aes256-cbc,aes128-ctr,aes192-ctr,aes256-ctr,3des-cbc\""
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

  std_prtmsg FINFO "PermitRootLogin is set to \"yes\""

  if std_amid "^Banner[[:space:]]+.*$" ${file}; then
    sed -ri "s|^Banner[[:space:]]+.*$|Banner\t/etc/issue|g" ${file}
  else
    echo -e "Banner\t/etc/issue" >>${file}
  fi

  std_prtmsg FINFO "Banner is set to \"${file}\""

  case ${OS_FULL_NAME} in
  sles11.4)
    if std_amid "^Ciphers[[:space:]]+.*$" ${file}; then
      sed -ri "s/^Ciphers[[:space:]]+.*$/Ciphers aes128-cbc,aes192-cbc,aes256-cbc,aes128-ctr,aes192-ctr,aes256-ctr,3des-cbc/g" ${file}
    else
      echo -e "Ciphers aes128-cbc,aes192-cbc,aes256-cbc,aes128-ctr,aes192-ctr,aes256-ctr,3des-cbc" >>${file}
    fi

    std_prtmsg FINFO "Ciphers is set to \"aes128-cbc,aes192-cbc,aes256-cbc,aes128-ctr,aes192-ctr,aes256-ctr,3des-cbc\""
    ;;
  *)
    if std_amid "^Ciphers[[:space:]]+.*$" ${file}; then
      sed -ri "s/^Ciphers[[:space:]]+.*$/aes128-gcm,aes256-gcm,aes128-cbc,aes192-cbc,aes256-cbc,aes128-ctr,aes192-ctr,aes256-ctr,3des-cbc/g" ${file}
    else
      echo -e "aes128-gcm,aes256-gcm,aes128-cbc,aes192-cbc,aes256-cbc,aes128-ctr,aes192-ctr,aes256-ctr,3des-cbc" >>${file}
    fi

    std_prtmsg FINFO "Ciphers is set to \"aes128-gcm,aes256-gcm,aes128-cbc,aes192-cbc,aes256-cbc,aes128-ctr,aes192-ctr,aes256-ctr,3des-cbc\""
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

[警告]

只有经过本系统所有者授权的人员和程序才能登录或访问本系统。

禁止任何其它形式的非法访问。

如果您非授权用户，请不要进行任何操作并退出登录。

任何非授权的访问和操作将被记录并作为呈堂证供。


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

[警告]

只有经过本系统所有者授权的人员和程序才能登录或访问本系统。

禁止任何其它形式的非法访问。

如果您非授权用户，请不要进行任何操作并退出登录。

任何非授权的访问和操作将被记录并作为呈堂证供。


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

function uni_enable_services() {
  std_prtmsg FS

  for service in sshd vsftpd xinetd nscd; do
    std_systemctl enable ${service}
    std_systemctl restart ${service}
    std_prtmsg FINFO "${service} is enabled and restarted"
  done

  std_prtmsg FEND "DONE"
}

function uni_ensure_hostname() {
  std_prtmsg FS

  ubct hostname "$(hostname)"

  std_prtmsg FEND "DONE"
}
