#!/bin/bash
function verify_hostname() {
  std_prtmsg FS

  local current_hostname file count
  current_hostname=$(hostname)

  file="/etc/hosts"

  count=$(grep "${IP_ADDR}" "${file}" | grep -w "${current_hostname}" | grep -cv "^[[:space:]]*#")

  if [[ ${count} -gt 1 ]]; then
    std_prtmsg FW "more than 1 rows are found in \"${file}\", please check manually"
    echo
    grep "${IP_ADDR}" "${file}" | grep -v "^[[:space:]]*#" | grep -w "${current_hostname}"
    echo
    std_prtmsg FEND "WARNING"
    return 1
  elif [[ ${count} -eq 1 ]]; then
    std_prtmsg FI "hostname verification passed"
    std_prtmsg FEND "CORRECT"
    return 0
  else  # count == 0
    std_prtmsg FERR "cannot find any rows of hostname \"${current_hostname}\" in \"${file}\", try \"ubct config hostname YOUR_HOSTNAME\""
    std_prtmsg FEND "ERROR"
    return 2
  fi
}
