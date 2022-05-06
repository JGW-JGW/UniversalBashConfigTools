#!/bin/bash
function verify_baseline() {
  local parameters test_flag file current_time log_flag log_file only_flag only_item line itemname importance current operator required tips default_null

  if ! parameters=$(getopt -o tlo: --long test,log:,only: -n "$0" -- "$@"); then
    return 1
  fi

  eval set -- "${parameters}"

  test_flag=false
  log_flag=false
  only_flag=false
  file="${UBCT_VERIFY_DIR}/baseline/${OS_FULL_NAME}.vrf"
  current_time=$(date "+%Y-%m-%d_%H_%M_%S")
  default_null='NULL'
  
  if [[ ! -f ${file} ]]; then
    std_prtmsg FERR "not a file or not found: \"${file}\""
    return 2
  fi

  while true; do
    case "$1" in
    -t | --test)
      test_flag=true
      shift
      ;;
    -l | --log)
      log_flag=true
      log_file="$2"
      if ! std_is_file_writable "${log_file}"; then
        std_prtmsg FERR "please check info above..."
        return 3
      fi
      shift 2
      ;;
    -o | --only)
      only_flag=true
      only_item="$2"
      if ! grep -E "^${only_item}[[:space:]]+" "${file}"; then
        std_prtmsg FERR "unsupported baseline verify item: \"${only_item}\", for ${OS_FULL_NAME}"
        return 4
      fi
      shift 2
      ;;
    --)
      break
      ;;
    esac
  done

  if ${log_flag}; then
    std_prtline -c= -l70
    std_prtline -c= -l70 -t"UBCT BASELINE VERIFY"
    std_prtline -c= -l70
  else
    std_prtline -c= -l70 | tee -a "${log_file}"
    std_prtline -c= -l70 -t"UBCT BASELINE VERIFY" | tee -a "${log_file}"
    std_prtline -c= -l70 | tee -a "${log_file}"
  fi

  if ${only_flag}; then
    while read -r line; do
      itemname=$(std_strip "$(echo "${line}" | awk -v FS="\t\t" '{print $1}')")
      importance=$(std_strip "$(echo "${line}" | awk -v FS="\t\t" '{print $2}')")



    done < <(grep -E "^${only_item}[[:space:]]+" "${file}")
  fi
}