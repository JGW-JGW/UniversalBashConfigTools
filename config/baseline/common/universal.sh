#!/bin/bash
function uni_set_timezone() {
  std_prtmsg FS

  if [[ $(date | awk '{print $5}') != "CST" ]]; then
    if ! timedatectl set-timezone Asia/Beijing; then
      std_prtmsg FERR "check info above..."
      std_prtmsg FEND "ERROR"
      return 1
    fi
  fi

  std_prtmsg FEND "DONE"
}

function uni_set_default_target() {
  std_prtmsg FS

  if [[ $(systemctl get-default) != "graphical.target" ]]; then
    if ! systemctl set-default graphical.target; then
      std_prtmsg FERR "check info above..."
      std_prtmsg FEND "ERROR"
      return 1
    fi
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
  
  if std_amid "^\*[[:space:]]+soft[[:space:]]+nofile[[:space:]]+.*$" ${file}; then
    sed -ri "s/^\*[[:space:]]+soft[[:space:]]+nofile[[:space:]]+.*$/*\tsoft\tnofile\t65536" ${file}
  else
    echo -e "\n*\tsoft\tnofile\t65536" >>${file}
  fi

  std_prtmsg FINFO "soft nofile set to 65536"

  if std_amid "^\*[[:space:]]+hard[[:space:]]+nofile[[:space:]]+.*$" ${file}; then
    sed -ri "s/^\*[[:space:]]+hard[[:space:]]+nofile[[:space:]]+.*$/*\thard\tnofile\t65536" ${file}
  else
    echo -e "\n*\thard\tnofile\t65536" >>${file}
  fi

  std_prtmsg FINFO "hard nofile set to 65536"

  if std_amid "^\*[[:space:]]+soft[[:space:]]+nproc[[:space:]]+.*$" ${file}; then
    sed -ri "s/^\*[[:space:]]+soft[[:space:]]+nproc[[:space:]]+.*$/*\tsoft\tnproc\t16384" ${file}
  else
    echo -e "\n*\tsoft\tnproc\t16384" >>${file}
  fi

  std_prtmsg FINFO "soft nproc set to 16384"

  if std_amid "^\*[[:space:]]+hard[[:space:]]+nproc[[:space:]]+.*$" ${file}; then
    sed -ri "s/^\*[[:space:]]+hard[[:space:]]+nproc[[:space:]]+.*$/*\thard\tnproc\t65536" ${file}
  else
    echo -e "\n*\thard\tnproc\t65536" >>${file}
  fi

  std_prtmsg FINFO "hard nproc set to 65536"

  if std_amid "^\*[[:space:]]+soft[[:space:]]+stack[[:space:]]+.*$" ${file}; then
    sed -ri "s/^\*[[:space:]]+soft[[:space:]]+stack[[:space:]]+.*$/*\tsoft\tstack\t2048" ${file}
  else
    echo -e "\n*\tsoft\tstack\t2048" >>${file}
  fi

  std_prtmsg FINFO "soft stack set to 2048"
  
  if std_amid "^\*[[:space:]]+soft[[:space:]]+core[[:space:]]+.*$" ${file}; then
    sed -ri "s/^\*[[:space:]]+soft[[:space:]]+core[[:space:]]+.*$/*\tsoft\tcore\t4294967296" ${file}
  else
    echo -e "\n*\tsoft\tcore\t4294967296" >>${file}
  fi

  std_prtmsg FINFO "soft core set to 4294967296"

  if std_amid "^\*[[:space:]]+hard[[:space:]]+core[[:space:]]+.*$" ${file}; then
    sed -ri "s/^\*[[:space:]]+hard[[:space:]]+core[[:space:]]+.*$/*\thard\tcore\t4294967296" ${file}
  else
    echo -e "\n*\thard\tcore\t4294967296" >>${file}
  fi

  std_prtmsg FINFO "hard core set to 4294967296"

  if std_amid "^was[[:space:]]+soft[[:space:]]+core[[:space:]]+.*$" ${file}; then
    sed -ri "s/^was[[:space:]]+soft[[:space:]]+core[[:space:]]+.*$/was\tsoft\tcore\t-1" ${file}
  else
    echo -e "\nwas\tsoft\tcore\t-1" >>${file}
  fi

  std_prtmsg FINFO "was soft core set to -1"

  if std_amid "^was[[:space:]]+hard[[:space:]]+core[[:space:]]+.*$" ${file}; then
    sed -ri "s/^was[[:space:]]+hard[[:space:]]+core[[:space:]]+.*$/was\thard\tcore\t-1" ${file}
  else
    echo -e "\nwas\thard\tcore\t-1" >>${file}
  fi

  std_prtmsg FINFO "was hard core set to -1"

  if std_amid "^was[[:space:]]+soft[[:space:]]+fsize[[:space:]]+.*$" ${file}; then
    sed -ri "s/^was[[:space:]]+soft[[:space:]]+fsize[[:space:]]+.*$/was\tsoft\tfsize\t-1" ${file}
  else
    echo -e "\nwas\tsoft\tfsize\t-1" >>${file}
  fi

  std_prtmsg FINFO "was soft fsize set to -1"

  if std_amid "^was[[:space:]]+hard[[:space:]]+fsize[[:space:]]+.*$" ${file}; then
    sed -ri "s/^was[[:space:]]+hard[[:space:]]+fsize[[:space:]]+.*$/was\thard\tfsize\t-1" ${file}
  else
    echo -e "\nwas\thard\tfsize\t-1" >>${file}
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

  if std_amid "^DefaultTasksMax[[:space:]]*=.*$" ${file}; then
    sed -ri "s/^DefaultTasksMax[[:space:]]*=.*$/DefaultTasksMax=12288/g" ${file}
  else
    echo -e "\nDefaultTasksMax=12288" >>${file}
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

  if std_amid "^kernel\.shmall[[:space:]]*=.*$" ${file}; then
    sed -ri "s/^kernel\.shmall[[:space:]]*=.*$/kernel.shmall=$((MEM_SIZE_B * ))/g" ${file}
  else
    echo -e "\nkernel.shmall=274877906944" >>${file}
  fi

  std_prtmsg FEND "DONE"
}