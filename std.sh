#!/bin/bash
# shellcheck disable=SC2120
function std_strip() {
  echo "$*" | sed -r 's/^[[:space:]]+//' | sed -r 's/[[:space:]]+$//'
  return 0
}

function std_float_cmp() {
  local f1="${1##*+}"
  local operator="$2"
  local f2="${3##*+}"

  case ${operator} in
  -lt)
    operator='<'
    ;;
  -gt)
    operator='>'
    ;;
  -eq)
    operator='=='
    ;;
  -le)
    operator='<='
    ;;
  -ge)
    operator='>='
    ;;
  -ne)
    operator='!='
    ;;
  esac

  [[ $(echo "${f1} ${operator} ${f2}" | bc) -eq 1 ]] && return 0 || return 1
}

function std_ceil() {
  local float="${1##*+}"
  local cut=${float%%.*}

  if std_float_cmp "${float}" -eq "${cut}"; then
    std_float_cmp "${cut}" -eq 0 && echo 0 || echo "${cut}"
    return 0
  fi

  # 到这里说明截断后的数字和原数字不相等，即原数字不可能为0（0的各种形式都不可能）
  if std_float_cmp "${float}" -lt 0; then
    std_float_cmp "${cut}" -eq 0 && echo 0 || echo "${cut}"
  else # 原数字大于0
    echo $((cut + 1))
  fi
}

function std_floor() {
  local float="${1##*+}"
  local cut=${float%%.*}

  if std_float_cmp "${float}" -eq "${cut}"; then
    std_float_cmp "${cut}" -eq 0 && echo 0 || echo "${cut}"
    return 0
  fi

  # 到这里说明截断后的数字和原数字不相等，即原数字不可能为0（0的各种形式都不可能）
  if std_float_cmp "${float}" -lt 0; then
    echo $((cut - 1))
  else # 原数字大于0
    std_float_cmp "${cut}" -eq 0 && echo 0 || echo "${cut}"
  fi
}

function std_round() {
  local float="${1##*+}"

  if std_float_cmp "${float}" -eq 0; then
    echo 0
    return 0
  fi

  local x floor ceil
  floor=$(std_floor "${float}")
  ceil=$(std_ceil "${float}")
  x=$(echo "${floor} ${ceil}" | awk '{printf("%0.1f\n",($1+$2)/2)}')

  if std_float_cmp "${float}" -gt 0; then
    if std_float_cmp "${float}" -ge "${x}"; then
      echo "${ceil}"
    else
      echo "${floor}"
    fi
  else
    if std_float_cmp "${float}" -le "${x}"; then
      echo "${floor}"
    else
      echo "${ceil}"
    fi
  fi
}

function std_prtmsg() {
  local type="$1"
  local msg="$2"

  case "${type}" in
  DONE | CORRECT)
    echo -e "\e[40;31;1m${type}\e[0m\c"
    ;;
  SKIP)
    echo -e "\e[47;30m${type}\e[0m\c"
    ;;
  ERROR | CHECK)
    echo -e "\e[47;30;5m${type}\e[0m\c"
    ;;
  INFO)
    echo -e "${type}\c"
    ;;
  STDINFO)
    echo -e "---- INFO\c"
    ;;
  STDERROR | STDERR)
    echo -e "---- \e[47;30;5mERROR\e[0m\c"
    ;;
  FUNCBEGIN | FUNCSTART | FS)
    echo -e "======== \e[40;31;1m${FUNCNAME[1]} \e[47;30mSTART\e[0m\c"
    ;;
  FUNCEND | FEND)
    echo -e "======== \e[40;31;1m${FUNCNAME[1]} \e[47;30mEND\e[0m\c"
    ;;
  FUNCERROR | FUNCERR | FERR)
    echo -e "==== \e[40;31;1m${FUNCNAME[1]} \e[47;30;5mERROR\e[0m\c"
    ;;
  FUNCWARNING | FWAR | FW)
    echo -e "==== \e[40;31;1m${FUNCNAME[1]} \e[47;30mWARNING\e[0m\c"
    ;;
  FUNCINFO | FINFO | FI)
    echo -e "==== \e[40;31;1m${FUNCNAME[1]} \e[0mINFO\c"
    ;;
  *)
    echo -e "ERROR: unknown type: \"${type}\""
    return 1
    ;;
  esac

  [[ -n "${msg}" ]] && echo -e ": ${msg}" || echo

  return 0
}

function std_prtline() {
  local parameters char title len_total

  if ! parameters=$(getopt -o c:t:l: --long char:,title:,length: -n "$0" -- "$@"); then
    return 1
  fi

  char=" "
  title=""
  len_total=32

  eval set -- "${parameters}"

  while true; do
    case "$1" in
    -c | --char)
      char="$2"
      if [[ ${#char} -ne 1 ]]; then
        std_prtmsg STDERR "invalid argument for -c/--char: \"${char}\""
        return 1
      fi
      shift 2
      ;;
    -t | --title)
      title="$2"
      shift 2
      ;;
    -l | --length)
      len_total="$2"
      shift 2
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

  local len_title=${#title}

  if [[ $((len_total - len_title)) -lt 4 ]]; then
    std_prtmsg STDERR "invalid value: total length should be greater than length of title by at least 4, current len_total = ${len_total}, len_title = ${len_title}"
    return 1
  fi

  if [[ ${len_title} -eq 0 ]]; then
    for ((i = 0; i < len_total; i++)); do
      printf "%s" "${char}"
    done
    printf "\n"
    return 0
  fi

  # reaching here means len_title > 0
  local len_diff len_left len_right

  len_diff=$((len_total - len_title))
  if [[ $((len_diff % 2)) -eq 0 ]]; then
    len_left=$((len_diff / 2))
    len_right=${len_left}
  else
    len_left=$(((len_diff - 1) / 2))
    len_right=$((len_left + 1))
  fi

  for ((i = 0; i < len_left; i++)); do
    [[ ${i} -ne $((len_left - 1)) ]] && printf "%s" "${char}" || printf " "
  done

  printf "%s" "${title}"

  for ((i = 0; i < len_right; i++)); do
    [[ ${i} -ne 0 ]] && printf "%s" "${char}" || printf " "
  done

  printf "\n"

  return 0
}

# 判断一个文件的最后一行到底有没有换行符，应对 echo -e "XXX\c" >>file 的情况
# 如果有换行，则保持该文件不变；如果没有换行，则增加 1 个换行到该文件中
function std_fix_file_eof() {
  local file="$1"

  if [[ ! -f ${file} ]]; then
    std_prtmsg STDERR "file not found: \"${file}\""
    return 1
  fi

  if ! cat -A "${file}" | tail -1 | grep -q "\\\$"; then
    echo >>"${file}"
    std_prtmsg STDINFO "file eof fixed: \"${file}\""
  else
    std_prtmsg STDINFO "file eof OK, do nothing: \"${file}\""
  fi

  return 0
}

function std_get_conf() {
  local var="$1"
  local file="$2"
  local line

  line=$(grep -E "^[[:space:]]*${var}([[:space:]]+|[[:space:]]*=)" "${file}" | tail -1)

  if [[ ${line} =~ '=' ]]; then
    eval echo "$(std_strip "$(echo "${line}" | awk -F= '{print $2}')")"
  else
    eval echo "$(std_strip "$(echo "${line}" | awk '{print $2}')")"
  fi
}

function std_amid() {
  local judge=$1
  local location=$2
  [[ -z "${judge}" ]] && return 1
  [[ -z "${location}" ]] && return 2
  [[ ! -f "${location}" ]] && return 3
  grep -qE "${judge}" "${location}" && return 0 || return 4
}

function std_cmd_exists() {
  local cmd=$1
  type "${cmd}" 1>/dev/null 2>/dev/null && return 0 || return 1
}

function std_backup_file() {
  local current_time origin_file origin_dirname origin_filename backup_dirname backup_file
  current_time=$(date "+%Y-%m-%d_%H_%M_%S")
  origin_file=$*
  origin_dirname=$(dirname "$*")
  origin_filename=$(basename "$*")
  backup_dirname=/tmp/ubct_backup${origin_dirname}
  backup_file=${backup_dirname}/${origin_filename}.bak.${current_time}

  [[ ! -d ${backup_dirname} ]] && mkdir -p "${backup_dirname}"

  std_prtmsg STDINFO "try to backup a file: \"${origin_file}\""

  if [[ -f ${origin_file} ]]; then
    if [[ -f ${backup_file} ]]; then
      std_prtmsg STDINFO "\"${origin_file}\" ALREADY backup as \"${backup_file}\""
      return 0
    else
      cp -p "${origin_file}" "${backup_file}"
      std_prtmsg STDINFO "\"${origin_file}\" backup as \"${backup_file}\""
      return 0
    fi
  elif [[ -d ${origin_dirname} ]]; then
    echo "# Before backup, \"${origin_file}\" does NOT exist." >"${backup_file}"
    std_prtmsg STDINFO "backup an EMPTY file \"${backup_file}\" since \"${origin_file}\" does NOT exist"
    return 0
  else
    std_prtmsg STDERR "\"${origin_dirname}\" is NOT a directory"
    return 1
  fi
}

function std_backup_directory() {
  local current_time origin_dir
  current_time=$(date "+%Y-%m-%d_%H_%M_%S")
  origin_dir=$(dirname "$*")/$(basename "$*")
  if [[ ! -d ${origin_dir} ]]; then
    std_prtmsg STDERR "\"${origin_dir}\" is NOT a directory"
    return 1
  fi
  local backup_dir base_dir parent_dir
  backup_dir=/tmp/ubct_backup${origin_dir}.${current_time}
  base_dir=$(basename "${origin_dir}")
  parent_dir=$(dirname "${backup_dir}")

  std_prtmsg STDINFO "try to backup a directory: \"${origin_dir}\""

  if [[ ! -e ${backup_dir} ]]; then
    mkdir -p "${parent_dir}"
    cp -frp "${origin_dir}" "${parent_dir}"
    mv "${parent_dir}/${base_dir}" "${backup_dir}"
    std_prtmsg STDINFO "\"${origin_dir}\" backup as \"${backup_dir}\""
    return 0
  elif [[ -d ${backup_dir} ]]; then
    std_prtmsg STDINFO "\"${origin_dir}\" ALREADY backup as \"${backup_dir}\""
    return 0
  else
    std_prtmsg STDERR "\"${backup_dir}\" is NOT a directory"
    return 1
  fi
}

# get value of a specific section inside a config file
# ======================
# [section_A]
# key_1 = 1
# key_2 = 2
# # comment
#
# [section_B]
# var_a a
# var_b b
# [END]
# ======================
# usage: std_get_section_conf section_A filename.conf
# ======================
# omit comments and blank lines, returning:
# key_1 = 1
# key_2 = 2
function std_get_section_conf() {
  local section_name="$1"
  local conf_file="$2"

  sed -n "/^[[:space:]]*\[${section_name}\][[:space:]]*$/,/^[[:space:]]*\[/ {/^[[:space:]]*\[${section_name}\][[:space:]]*$\|^[[:space:]]*\[/!p;}" "${conf_file}" | grep -Ev "^[[:space:]]*$|^[[:space:]]*#.*$"
}

function std_translate_size() {
  local input_size="$1"

  if [[ "${input_size}" =~ [0-9]+([Mm]B?)?$ ]]; then
    input_size=${input_size%M*}
    input_size=${input_size%m*}
    echo "${input_size%.*}"
    return 0
  elif [[ "${input_size}" =~ [0-9]+[Gg]B?$ ]]; then
    input_size=${input_size%G*}
    input_size=${input_size%g*}
    echo $((${input_size%.*} * 1024))
    return 0
  elif [[ "${input_size}" =~ [0-9]+[Tt]B?$ ]]; then
    input_size=${input_size%T*}
    input_size=${input_size%t*}
    echo $((${input_size%.*} * 1048576))
    return 0
  elif [[ "${input_size}" =~ [0-9]+[Kk]B?$ ]]; then
    input_size=${input_size%K*}
    input_size=${input_size%k*}
    echo $((${input_size%.*} / 1024))
    return 0
  else
    std_prtmsg STDERR "invalid size: \"${input_size}\""
    return 1
  fi
}

function std_get_pv_free_space() {
  local pv_name="$1"
  std_translate_size "$(parted "${pv_name}" print free | grep "Free Space" | tail -1 | awk '{print $3}')"
}

function std_get_pv_part_num() {
  local pv_name="$1"
  parted "${pv_name}" print | grep -Ec "^[[:space:]]*[0-9]+"
}

function std_get_vg_free_space() {
  local vg_name="$1"
  std_translate_size "$(vgs --unit m | awk -v name="${vg_name}" '{if($1==name) {print $NF}}')"
}

function std_generate_fs_type() {
  case ${OS_FULL_NAME} in
  centos-7)
    echo xfs
    return 0
    ;;
  *)
    echo NULL
    return 1
    ;;
  esac
}

function std_get_dev_scheduler() {
  local dev_name="$1"
  local file="/sys/block/${dev_name}/queue/scheduler"
  if std_amid "\[.+\]" "${file}"; then
    cut -d[ -f2 "${file}" | cut -d] -f1
    return 0
  else
    echo "NULL"
    return 1
  fi
}

function std_check_fstab() {
  local n_fstab fs_list_fstab type_list_fstab fs type_df flag
  read -ra fs_list_fstab <<EOF
$(grep -Ev "^[[:space:]]*#|^[[:space:]]*$" /etc/fstab | awk '{print $2}' | xargs)
EOF
  read -ra type_list_fstab <<EOF
$(grep -Ev "^[[:space:]]*#|^[[:space:]]*$" /etc/fstab | awk '{print $3}' | xargs)
EOF
  n_fstab=${#fs_list_fstab[@]}

  flag=0

  for ((i = 0; i < n_fstab; i++)); do
    case ${fs_list_fstab[i]} in
    swap | none | /sys | /sys/* | /proc | /proc/* | /dev | /dev/*)
      continue
      ;;
    esac

    [[ "${fs_list_fstab[i]}" != "/" ]] && fs=${fs_list_fstab[i]%/} || fs=${fs_list_fstab[i]}

    type_df=$(df -Th | grep -E "[[:space:]]+${fs}$" | awk '{print $2}')

    if [[ -z "${type_df}" ]]; then # fs not found in df -Th
      flag=1
      std_prtmsg STDERR "mount point \"${fs}\" NOT found in df -Th"
    elif [[ "${type_list_fstab[i]}" != "${type_df}" ]]; then
      flag=1
      std_prtmsg STDERR "mount point \"${fs}\" has different types in fstab and df command: ${type_list_fstab[i]} VS ${type_df}"
    fi
  done

  return ${flag}
}

function std_check_disk_scheduler() {
  local scheduler
  case ${OS_FULL_NAME} in
  centos-7)
    for dev in $(lsblk -S | awk '/^sd/ {print $1}'); do
      scheduler=$(std_get_dev_scheduler "${dev}")
      if [[ ${dev} == sda && ${scheduler} != cfq ]]; then
        std_prtmsg STDERR "scheduler unfitted: device=\"${dev}\", required=\"cfq\", current=\"${scheduler}"
        return 1
      elif [[ ${dev} != sda && ${scheduler} != none ]]; then
        std_prtmsg STDERR "scheduler unfitted: device=\"${dev}\", required=\"none\", current=\"${scheduler}"
        return 2
      fi
    done
    return 0
    ;;
  *)
    std_prtmsg STDERR "unsupported os: \"${OS_FULL_NAME}\""
    return 3
    ;;
  esac
}

# verify a fs by its mount point, size and type
function std_check_filesystem() {
  local parameters
  if ! parameters=$(getopt -o m:s:t: --long mount_point:,size:,type: -n "$0" -- "$@"); then
    return 1
  fi

  eval set -- "${parameters}"

  local input_mp real_size real_type result input_size input_type

  while true; do
    case $1 in
    -m | --mount_point)
      input_mp="$2"
      result=$(df -Tm | grep "${input_mp}$")
      if [[ -z ${result} ]]; then # mp is not a fs
        if [[ -e ${input_mp} ]]; then
          std_prtmsg STDERR "mount point exists but is NOT a filesystem: \"${input_mp}\""
          return 1
        else
          std_prtmsg STDERR "mount point does NOT exist: \"${input_mp}\""
          return 2
        fi
      fi
      # reaching here means mp is a fs
      real_size=$(echo "${result}" | awk '{print $3}')
      real_type=$(echo "${result}" | awk '{print $2}')
      shift 2
      ;;
    -s | --size)
      input_size="$2"
      if ! std_translate_size "${input_size}" 1>/dev/null 2>/dev/null; then
        std_prtmsg STDERR "invalid size: \"${input_size}\""
        return 3
      fi
      # reaching here means input size is valid
      input_size=$(std_translate_size "${input_size}")
      shift 2
      ;;
    -t | --type)
      input_type="$2"
      shift 2
      ;;
    --)
      break
      ;;
    esac
  done

  if [[ ${real_size} -lt ${input_size} ]]; then
    std_prtmsg STDERR "\"${input_mp}\": current size is ${real_size} MB, required size is ${input_size} MB"
    return 4
  fi

  if [[ "${real_type}" != "${input_type}" ]]; then
    std_prtmsg STDERR "\"${input_mp}\": current type is \"${real_type}\", required type is \"${input_type}\""
    return 5
  fi

  return 0
}

# check whether a filesystem of a certain size (MB) could be created on the specific vg
function std_check_creation_of_filesystem() {
  local input_vg_name="$1"
  local input_size="$2"

  # check validity of input size
  if ! std_translate_size "${input_size}" 1>/dev/null 2>/dev/null; then
    std_prtmsg STDERR "invalid size: \"${input_size}\""
    return 1
  fi
  input_size=$(std_translate_size "${input_size}")

  # check whether input vg has enough space of input size
  local vg_free_space
  vg_free_space=$(std_get_vg_free_space "${input_vg_name}")

  # if there is enough space of input size, it is able to create this filesystem
  if [[ ${vg_free_space} -gt ${input_size} ]]; then
    std_prtmsg STDINFO "filesystem of size ${input_size} MB on vg \"${input_vg_name}\" can be created"
    return 0
  fi

  # reaching here means there is not enough space of input vg
  std_prtmsg STDERR "there is not enough space on vg \"${input_vg_name}\", now checking pv..."

  # get pv list
  local pv_list
  pv_list=$(lsblk -dnp | awk '{if($6=="disk") {print $1}}')

  # check which pv has enough space
  local pv_free_space=0
  local pv_chosen="NULL"
  for pv in ${pv_list}; do
    pv_free_space=$(std_get_pv_free_space "${pv}")
    if [[ ${pv_free_space} -ge ${input_size} ]]; then
      pv_chosen=${pv}
      break
    fi
  done

  # return if a proper pv can not be found
  if [[ ${pv_chosen} == NULL ]]; then
    std_prtmsg STDERR "there is not enough space on any pv of \"${pv_list}\", please add new pvs"
    return 2
  fi

  # if a fitted pv is found, then we will create a new partition
  # check how many partitions are there in the chosen pv, if > 3 return ERROR
  local pv_part_num
  pv_part_num=$(std_get_pv_part_num "${pv_chosen}")
  if [[ ${pv_part_num} -gt 3 ]]; then
    std_prtmsg STDERR "too many partitions found for \"${pv_chosen}\": ${pv_part_num} partitions"
    return 3
  fi

  # try to create a new partition
  local start_position choice
  start_position=$(parted -s "${pv_chosen}" print free | grep "Free Space" | tail -1 | awk '{print $1}')
  echo
  parted -s "${pv_chosen}" print free
  echo
  echo "command will be executed: parted -s ${pv_chosen} mkpart primary \"${start_position} -1\""
  read -rp "create a new partition on \"${pv_chosen}\"? (y/n): " choice
  if [[ ${choice} == y ]]; then
    parted -s "${pv_chosen}" mkpart primary "${start_position} -1"
  else
    std_prtmsg STDERR "cancel creating a new partition on \"${pv_chosen}\" by user"
    return 4
  fi

  # get the total number of partitions on the chosen pv
  pv_part_num=$(std_get_pv_part_num "${pv_chosen}")

  # set the new partition to type lvm
  parted -s "${pv_chosen}" set "${pv_part_num}" lvm on

  # extend vg
  vgextend "${input_vg_name}" "${pv_chosen}${pv_part_num}"

  # check whether input vg has enough space of input size
  vg_free_space=$(std_get_vg_free_space "${input_vg_name}")
  if [[ ${vg_free_space} -gt ${input_size} ]]; then
    std_prtmsg STDINFO "filesystem of size ${input_size} MB on vg \"${input_vg_name}\" can be created"
    return 0
  else
    std_prtmsg STDERR "there is not enough space on vg \"${input_vg_name}\", free space is ${vg_free_space} MB, required space is ${input_size} MB"
    return 5
  fi
}

function std_compare_version() {
  local v1="$1"
  local v2="$2"
  local IFS_old="${IFS}"
  IFS="."
  read -ra v1 <<EOF
${v1}
EOF
  read -ra v2 <<EOF
${v2}
EOF
  IFS=${IFS_old}

  # 获取数组长度
  local n1=${#v1[@]}
  local n2=${#v2[@]}
  local n
  [[ ${n1} -lt ${n2} ]] && n=${n1} || n=${n2}

  for ((i = 0; i < n; i++)); do
    if [[ ${v1[i]} -gt ${v2[i]} ]]; then
      echo "1"
      return 0
    elif [[ ${v1[i]} -lt ${v2[i]} ]]; then
      echo "-1"
      return 0
    fi
  done

  echo "0"
  return 0
}

function std_compare_kernel_version() {
  local current_kernel_version_main current_kernel_version_sub
  current_kernel_version_main=$(uname -r | cut -d- -f1)
  current_kernel_version_sub=$(uname -r | cut -d- -f2)
  local required_kernel_version="$1"
  local required_kernel_version_main required_kernel_version_sub
  required_kernel_version_main=$(echo "${required_kernel_version}" | cut -d- -f1)
  required_kernel_version_sub=$(echo "${required_kernel_version}" | cut -d- -f2)

  case $(std_compare_version "${current_kernel_version_main}" "${required_kernel_version_main}") in
  -1)
    return 1
    ;;
  1)
    return 0
    ;;
  0)
    if [[ $(std_compare_version "${current_kernel_version_sub}" "${required_kernel_version_sub}") -eq -1 ]]; then
      return 1
    else
      return 0
    fi
    ;;
  *)
    return 2
    ;;
  esac
}

function std_systemctl() {
  local usage="$1"
  local service="$2"

  case ${OS_FULL_NAME} in
  centos-7 | sles-12.3 | sles-12.5 | neokylin-V7.0 | kylinV10)
    case ${usage} in
    is-installed)
      if systemctl status "${service}" 2>&1 | grep -Eq "not-found|No such file or directory|could not be found"; then
        echo uninstalled
        return 1
      else
        echo installed
        return 0
      fi
      ;;
    status)
      systemctl status "${service}" 2>&1
      ;;
    is-enabled)
      if [[ $(systemctl is-enabled "${service}" 2>&1) == enabled ]]; then
        echo enabled
        return 0
      else
        echo disabled
        return 1
      fi
      ;;
    is-active)
      if [[ $(systemctl is-active "${service}" 2>&1) == active ]]; then
        echo active
        return 0
      else
        echo inactive
        return 1
      fi
      ;;
    enable)
      systemctl enable "${service}" 2>&1
      ;;
    disable)
      systemctl disable "${service}" 2>&1
      ;;
    stop)
      systemctl stop "${service}" 2>&1
      ;;
    restart)
      systemctl restart "${service}" 2>&1
      ;;
    *)
      std_prtmsg STDERR "unsupported usage: \"${usage}\""
      return 2
      ;;
    esac
    ;;
  sles11.4)
    case ${usage} in
    is-installed)
      if chkconfig -l "${service}" 2>&1 | grep -q "unknown service"; then
        echo uninstalled
        return 1
      else
        echo installed
        return 0
      fi
      ;;
    status)
      chkconfig -l "${service}"
      service "${service}" status
      ;;
    is-enabled)
      if chkconfig "${service}" 2>&1 | awk '{print $2}' | grep -oq "on"; then
        echo enabled
        return 0
      else
        echo disabled
        return 1
      fi
      ;;
    is-active)
      if service "${service}" status 2>&1 | grep -v "not running" | awk '{print $NF}' | grep -oq "running"; then
        echo "active"
        return 0
      else
        echo "inactive"
        return 1
      fi
      ;;
    enable)
      chkconfig "${service}" on
      ;;
    disable)
      chkconfig "${service}" off
      ;;
    start)
      service "${service}" start
      rc"${service}" start 2>/dev/null
      ;;
    stop)
      service "${service}" stop
      rc"${service}" stop 2>/dev/null
      ;;
    restart)
      service "${service}" restart
      rc"${service}" restart 2>/dev/null
      ;;
    *)
      std_prtmsg STDERR "unsupported usage: \"${usage}\""
      return 2
      ;;
    esac
    ;;
  *)
    std_prtmsg STDERR "unsupported os: \"${OS_FULL_NAME}\""
    return 3
    ;;
  esac
}
