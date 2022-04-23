#!/bin/bash
function check_os() {
  std_prtmsg FS

  if [[ ${OS_FULL_NAME} != "centos-7" ]]; then
    std_prtmsg FERR "current os is \"${OS_FULL_NAME}\", should be \"centos-7\""
    std_prtmsg FEND
    exit 255
  fi

  std_prtmsg FEND "CORRECT"
}

function fix_bug() {
  std_prtmsg FS

  std_prtmsg FINFO "do nothing..."

  std_prtmsg FEND "DONE"
}

function install_java() {
  std_prtmsg FS

  std_prtmsg FINFO "do nothing..."

  # 先下载并安装到指定位置

  # /etc/profile 需要向其中添加环境变量
  # sed -ri "/^export[[:space:]]+JAVA_HOME[[:space:]]*=.*$/d" /etc/profile
  # sed -ri "/^export[[:space:]]+PATH[[:space:]]*=.*$/d" /etc/profile
  # echo -e "export JAVA_HOME=${java_home}" >>${file}
  # echo 'export PATH=${JAVA_HOME}/bin:${JAVA_HOME}/jre/bin:${PATH}' >>${file}

  std_prtmsg FEND "DONE"
}

function add_users() {
  std_prtmsg FS

  local file="/etc/passwd"

  for f in ${file} /etc/shadow; do
    if ! std_backup_file ${f}; then
      std_prtmsg FERR "backup failed, please check info above..."
      std_prtmsg FEND "ERROR"
      return 1
    fi

    std_fix_file_eof ${f}
  done

  # add sysop
  if std_amid "^sysop:" ${file}; then
    std_prtmsg FINFO "\"sysop\" exists and activated"
  elif std_amid "^[[:space:]]*#[[:space:]]*sysop:" ${file}; then
    std_prtmsg FINFO "\"sysop\" exists but not activated"
  else
    useradd -md /home/sysop -o -g 0 -u 0 sysop
    chown -R sysop:0 /home/sysop
    echo "sysop:qwert789" | chpasswd
    std_prtmsg FINFO "\"sysop\" added"
  fi

  # add jgw
  if std_amid "^jgw:" ${file}; then
    std_prtmsg FINFO "\"jgw\" exists and activated"
  elif std_amid "^[[:space:]]*#[[:space:]]*jgw:" ${file}; then
    std_prtmsg FINFO "\"jgw\" exists but not activated"
  else
    useradd -md /home/jgw -g 0 -u 666 jgw
    chown -R jgw:0 /home/jgw
    echo "jgw:qwert789" | chpasswd
    std_prtmsg FINFO "\"jgw\" added"
  fi

  std_prtmsg FEND "DONE"
}

function lock_users() {
  std_prtmsg FS

  for user in at bin daemon ftp games gdm haldaemon lp mail messagebus nobody ntp postfix sshd suse-ncc wwwrun man news uucp ftpsecure polkituser pulse puppet rtkit polkitd uuidd; do
    if std_amid "^${user}:" /etc/passwd; then
      passwd -l ${user} 1>/dev/null
      std_prtmsg FINFO "\"${user}\" is locked"
    fi
  done

  std_prtmsg FEND "DONE"
}

function config_centos_7() {
  std_prtmsg FS

  check_os

  local parameters

  if ! parameters=$(getopt -o an: --long all,name: -n "$0" -- "$@"); then
    return 1
  fi

  eval set -- "${parameters}"

  while true; do
    case "$1" in
    -a | --all)
      # fix bugs for the specific version of os
      fix_bug

      # timezone
      uni_set_timezone

      # rm /etc/ssl/privatekeys
      uni_rm_ssl_privatekeys

      # users
      add_users
      lock_users

      # hostname
      uni_ensure_hostname

      # filesystem config
      # TODO

      ;;
    -n | --name)
      local valid_functions funcname
      valid_functions=$(cat <<EOF
      # fix bugs for the specific version of os
      fix_bug

      # timezone
      uni_set_timezone

      # rm /etc/ssl/privatekeys
      uni_rm_ssl_privatekeys

      # users
      add_users
      lock_users

      # hostname
      uni_ensure_hostname

      # filesystem config
      # TODO
EOF
)
      funcname="$2"
      if ! echo "${valid_functions}" | grep -v "^[[:space:]]*$" | grep -v "^[[:space:]]*#" | grep -wq "${funcname}"; then
        std_prtmsg FERR "unsupported baseline config argument: \"${funcname}\", for ${OS_FULL_NAME}"
        return 1
      else
        eval "${funcname}"
      fi
      ;;
    --)
      break
      ;;
    *)
      std_prtmsg STDERR "invalid option: \"$1\""
      return 1
      ;;
    esac
  done
}