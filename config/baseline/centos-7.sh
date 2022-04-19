#!/bin/bash
function check_os() {
  std_prtmsg FUNCSTART

  if [[ ${OS_FULL_NAME} != "centos-7" ]]; then
    std_prtmsg FUNCERR "current os is not \"centos-7\""
    std_prtmsg FUNCEND
    exit 255
  fi

  std_prtmsg FUNCEND "CORRECT"
}
