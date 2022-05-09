#!/bin/bash
# 去掉字符串两端的空格
function init_strip() {
  echo "$*" | sed -r 's/^[[:space:]]+//' | sed -r 's/[[:space:]]+$//'
  return 0
}

# 获取配置文件中的值
function init_get_conf() {
  local var="$1"
  local file="$2"
  local line

  line=$(grep -E "^[[:space:]]*${var}([[:space:]]+|[[:space:]]*=)" "${file}" | tail -1)

  if [[ ${line} =~ '=' ]]; then
    eval echo "$(init_strip "$(echo "${line}" | awk -F= '{print $2}')")"
  else
    eval echo "$(init_strip "$(echo "${line}" | awk '{print $2}')")"
  fi
}

# 字符串标准化：将字符串中的 '.' 替换为 '_'
function init_standardize() {
  echo "$*" | sed -r 's/\./_/g'
  return 0
}

# 常数
REGEX_IP="(2[0-4][0-9]|25[0-5]|1[0-9][0-9]|[1-9]?[0-9])(\.(2[0-4][0-9]|25[0-5]|1[0-9][0-9]|[1-9]?[0-9])){3}"

# UBCT 相关信息
UBCT_CONF=${UBCT_ROOT_DIR}/ubct.conf
UBCT_VERSION=$(init_get_conf UBCT_VERSION "${UBCT_CONF}")
UBCT_STD=${UBCT_ROOT_DIR}/std.sh
UBCT_CONFIG_DIR=${UBCT_ROOT_DIR}/config
UBCT_VERIFY_DIR=${UBCT_ROOT_DIR}/verify

# OS 相关信息
PRIMARY_NIC=$(ip route | head -1 | awk '{print $5}')
GATEWAY_ADDR=$(ip route | grep default | awk '{print $3}')
MAC_ADDR=$([[ -f /sys/class/net/"${PRIMARY_NIC}"/address ]] && cat /sys/class/net/"${PRIMARY_NIC}"/address)
IP_ADDR=$(ip addr show "${PRIMARY_NIC}" | grep -Eo "${REGEX_IP}" | head -1)
HOSTNAME=$(hostname)
MANUFACTURER=$(init_strip "$([[ -e /dev/mem ]] && dmidecode -t1 | grep "Manufacturer:" | awk -F: '{print $2}')")
PRODUCT_NAME=$(init_strip "$([[ -e /dev/mem ]] && dmidecode -t1 | grep "Product Name:" | awk -F: '{print $2}')")
CPU_NUM=$(init_strip "$(lscpu | grep -E "^CPU\(s\):" | awk -F: '{print $2}')")
CPU_TYPE=$(uname -m)
MEM_SIZE_KB=$(grep "MemTotal:" /proc/meminfo | grep -Eo "[0-9]+")
MEM_SIZE_GB=$(echo "scale=2; ${MEM_SIZE_KB} / 1048576" | bc)
MEM_SIZE_B=$((MEM_SIZE_KB * 1024))
PAGE_SIZE_B=$(getconf PAGESIZE)
PAGE_NUM=$((MEM_SIZE_B / PAGE_SIZE_B))
OS_ID=$(init_get_conf ID /etc/os-release)
OS_VERSION_ID=$(init_get_conf VERSION_ID /etc/os-release)
OS_FULL_NAME=${OS_ID}-${OS_VERSION_ID}
OS_STANDARD_NAME=$(init_standardize "${OS_ID}")_$(init_standardize "${OS_VERSION_ID}")

# 根据IP地址和主机名等确定网段类型和机器的物理位置（假设主机名和网段划分具有明确的规则）
if [[ ${IP_ADDR%.*.*} == "192.168" ]]; then
  NET_ZONE=TEST
else
  NET_ZONE=NULL
fi
if [[ ${HOSTNAME:0:5} == "local" ]]; then
  MACHINE_LOCATION=HOME
else
  MACHINE_LOCATION=NULL
fi

