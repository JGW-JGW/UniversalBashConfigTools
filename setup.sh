#!/bin/bash
function setup_cmd_exists() {
  local cmd=$1
  type "${cmd}" 1>/dev/null 2>/dev/null && return 0 || return 1
}

function setup_prtmsg() {
  local type="$1"
  local msg="$2"

  case "${type}" in
  DONE)
    echo -e "\e[40;31;1m${type}\e[0m\c"
    ;;
  ERROR)
    echo -e "\e[47;30;5m${type}\e[0m\c"
    ;;
  *)
    echo -e "ERROR: unknown type: \"${type}\""
    return 1
    ;;
  esac

  [[ -n "${msg}" ]] && echo -e ": ${msg}" || echo

  return 0
}

while true; do
  cat <<'EOF'

===========================================
        Universal Bash Config Tools
===========================================
    1. Download from GitHub and Install
    2. Install from Local Disk
    0. Cancel and Exit
===========================================
EOF

  read -rp "Please input your choice: " choice

  echo "==========================================="

  case ${choice} in
  1) # 从 GitHub 上下载 zip 包并安装
    # 检查命令是否存在
    for command in curl unzip; do
      if ! setup_cmd_exists ${command}; then
        setup_prtmsg ERROR "command not found: \"${command}\""
        exit 255
      fi
    done

    # 输入安装路径
    read -rp "Please input the absolute path of installation directory (by default is $(pwd)): " install_dir

    if [[ -n "${install_dir}" ]]; then
      if [[ -e "${install_dir}" && ! -d "${install_dir}" ]]; then
        setup_prtmsg ERROR "not a directory: \"${install_dir}\""
        exit 255
      fi
      [[ ! -e "${install_dir}" ]] && mkdir -p "${install_dir}"
    else
      install_dir="$(pwd)"
    fi

    destiny_url="https://github.com/JGW-JGW/UniversalBashConfigTools/archive/refs/heads/master.zip"

    zip_name="$(basename ${destiny_url})"

    curl -L -o "${install_dir}/${zip_name}" ${destiny_url}

    unzip -o "${install_dir}/${zip_name}" -d "${install_dir}" || exit 255

    rm -f "${install_dir}/${zip_name}"

    dir_name="UniversalBashConfigTools-master"

    cp -rpf "${install_dir}"/${dir_name}/* "${install_dir}"

    rm -rf "${install_dir:?}/${dir_name}"

    ubct_cmd="/usr/bin/ubct"
    ubct_completion="/etc/bash_completion.d/ubct-completion.sh"
    ubct_conf="/etc/ubct.conf"

    for link in ${ubct_cmd} ${ubct_completion} ${ubct_conf}; do
      [[ -L ${link} ]] && rm -f ${link}
      ln -s "${install_dir}/$(basename ${link})" ${link}
    done

    . ${ubct_completion}

    chmod a+x ${ubct_cmd}

    setup_prtmsg DONE "UBCT installed successfully"
    ;;
  2) # 指定本地磁盘中的 zip 包并安装
    # 检查命令是否存在
    if ! setup_cmd_exists unzip; then
      setup_prtmsg ERROR "command not found: \"unzip\""
      exit 255
    fi

    # 输入 zip 包的绝对路径
    read -rp "Please input the absolute path of installation zip package (by default is $(pwd)/master.zip): " zip_file
    [[ -z "${zip_file}" ]] && zip_file="$(pwd)/master.zip"
    if [[ ! -f "${zip_file}" ]]; then
      setup_prtmsg ERROR "file not found: \"${zip_file}\""
      exit 255
    fi

    # 输入安装路径
    read -rp "Please input the absolute path of installation directory (by default is $(pwd)): " install_dir

    if [[ -n "${install_dir}" ]]; then
      if [[ -e "${install_dir}" && ! -d "${install_dir}" ]]; then
        setup_prtmsg ERROR "is not a directory: \"${install_dir}\""
        exit 255
      fi
      [[ ! -e "${install_dir}" ]] && mkdir -p "${install_dir}"
    else
      install_dir="$(pwd)"
    fi

    unzip -o "${zip_file}" -d "${install_dir}" || exit 255

    dir_name="UniversalBashConfigTools-master"

    cp -rpf "${install_dir}"/${dir_name}/* "${install_dir}"

    rm -rf "${install_dir:?}/${dir_name}"

    ubct_cmd="/usr/bin/ubct"
    ubct_completion="/etc/bash_completion.d/ubct-completion.sh"
    ubct_conf="/etc/ubct.conf"

    for link in ${ubct_cmd} ${ubct_completion} ${ubct_conf}; do
  [[ -L ${link} ]] && rm -f ${link}
  ln -s "${install_dir}/$(basename ${link})" ${link}
done

    . ${ubct_completion}

    chmod a+x ${ubct_cmd}

    setup_prtmsg DONE "UBCT installed successfully"
    ;;
  0) # 退出
    exit
    ;;
  *)
    setup_prtmsg ERROR "invalid input: \"${choice}\""
    ;;
  esac
done
