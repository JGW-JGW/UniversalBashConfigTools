#!/bin/bash
function change_hostname() {
  std_prtmsg FS

  local hostname_new="$1"

  if [[ -z ${hostname_new} ]]; then
    std_prtmsg FERR "new hostname is empty, please input a new hostname"
    std_prtmsg FEND "ERROR"
    return 1
  fi

  local hostname_old
  hostname_old=$(hostname)

  case ${OS_FULL_NAME} in
  centos-7)
    local file="/etc/hostname"

    if ! std_backup_file ${file}; then
      std_prtmsg FERR "backup failed, please check info above..."
      std_prtmsg FEND "ERROR"
      return 1
    fi

    std_fix_file_eof ${file}

    echo "${hostname_new}" >${file}

    std_prtmsg FINFO "\"${hostname_new}\" is added to \"${file}\""

    file="/etc/hosts"

    if ! std_backup_file ${file}; then
      std_prtmsg FERR "backup failed, please check info above..."
      std_prtmsg FEND "ERROR"
      return 1
    fi

    std_fix_file_eof ${file}

    if std_amid "^${IP_ADDR}[[:space:]]+${hostname_old}" ${file}; then
      sed -ri "/^${IP_ADDR}[[:space:]]+${hostname_old}/ s/\<${hostname_old}\>/${hostname_new}/" ${file}
    else
      echo -e "${IP_ADDR}\t\t${hostname_new}" >>${file}
    fi

    std_prtmsg FINFO "\"${hostname_old}\" is replaced with \"${hostname_new}\" of \"${file}\""

    file="/etc/rc.d/rc.local"

    chmod u+x "${file}"

    ${file} restart 1>/dev/null

    std_prtmsg FINFO "\"${file}\" is restarted"

    hostname "${hostname_new}"

    sysctl -w kernel.hostname="${hostname_new}"

    std_prtmsg FINFO "kernel.hostname and current hostname is set to \"${hostname_new}\""
    ;;
  *)
    std_prtmsg FERR "unsupported os: \"${OS_FULL_NAME}\""
    ;;
  esac

  std_prtmsg FEND "DONE"
}
