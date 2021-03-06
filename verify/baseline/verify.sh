#!/bin/bash
function vrf_users() {
  # 检查所有新增用户的状态
  for user in sysop jgw; do
    if ! std_user_exists "${user}"; then
      std_prtmsg BE "${user} not found in /etc/passwd"
      return 1
    fi

    if ! std_is_user_password_normal "${user}"; then
      std_prtmsg BE "${user}'s password is not valid in /etc/shadow"
      return 2
    fi
  done

  # 检查所有需要锁定的用户的状态
  for user in at bin daemon ftp games gdm haldaemon lp mail messagebus nobody ntp postfix sshd suse-ncc wwwrun man news uucp ftpsecure polkituser pulse puppet rtkit polkitd uuidd; do
    if std_user_exists "${user}"; then
      if ! std_is_user_locked "${user}"; then
        std_prtmsg BE "${user} is not locked"
        return 3
      fi
    fi
  done

  echo CORRECT
  return 0
}



function vrf_baseline() {
  local parameters test_flag vrf_file current_time log_flag log_file only_flag only_item itemname importance current operator required tips null result all_correct len line

  vrf_file="${UBCT_VERIFY_DIR}/baseline/${OS_FULL_NAME}.vrf"
  test_flag=false
  log_flag=false
  only_flag=false
  current_time=$(date "+%Y-%m-%d %H:%M:%S")
  null='null'
  all_correct=true
  len=70

  if [[ ! -f ${vrf_file} ]]; then
    std_prtmsg FERR "not a file or not found: \"${vrf_file}\""
    return 2
  fi

  if ! parameters=$(getopt -o tl:o: --long test,log:,only: -n "$0" -- "$@"); then
    return 1
  fi

  eval set -- "${parameters}"

  while true; do
    case "$1" in
    -t | --test)
      test_flag=true
      shift
      ;;
    -l | --log)
      log_file="$2"
      if ! std_is_file_writable "${log_file}"; then
        std_prtmsg FERR "please check info above..."
        return 3
      fi
      log_flag=true
      shift 2
      ;;
    -o | --only)
      only_item="$2"
      if ! grep -q "^${only_item};;" "${vrf_file}"; then
        std_prtmsg FERR "unsupported baseline verify item: \"${only_item}\", for ${OS_FULL_NAME}"
        return 4
      fi
      only_flag=true
      shift 2
      ;;
    --)
      break
      ;;
    esac
  done

  if ! ${log_flag}; then # do not log
    std_prtline -c= -l70
    std_prtline -l70 -t"UBCT BASELINE VERIFY"
    std_prtline -c- -l70
    std_prtline -l70 -t"DATETIME: ${current_time}"
    std_prtline -c= -l70
  else # do log
    std_prtline -c= -l70 | tee -a "${log_file}"
    std_prtline -l70 -t"UBCT BASELINE VERIFY" | tee -a "${log_file}"
    std_prtline -c- -l70 | tee -a "${log_file}"
    std_prtline -l70 -t"DATETIME: ${current_time}" | tee -a "${log_file}"
    std_prtline -c= -l70 | tee -a "${log_file}"
  fi

  if ${only_flag}; then
    while read -r line; do
      itemname=$(std_strip "$(echo "${line}" | awk -v FS=';;' '{print $1}')")

      importance=$(std_strip "$(echo "${line}" | awk -v FS=";;" '{print $2}')")

      current=$(std_strip "$(eval "$(echo "${line}" | awk -v FS=";;" '{print $3}')")")
      [[ ${current} =~ '$' ]] && current=$(eval echo "${current}")

      operator=$(std_strip "$(echo "${line}" | awk -v FS=";;" '{print $4}')")

      required=$(std_strip "$(echo "${line}" | awk -v FS=";;" '{print $5}')")
      [[ ${required} =~ '$' ]] && required=$(eval echo "${required}")

      tips=$(std_strip "$(echo "${line}" | awk -v FS=";;" '{print $6}')")
      [[ ${tips} == "${null}" ]] && tips="please refer to official operation manuals"

      # deal with test_flag == true
      if ${test_flag}; then
        if ! ${log_flag}; then # do not log
          std_prtline -l${len} -c- -t"RAW INFO"
          cat <<EOF
itemname:     ${itemname}
importance:   [${importance}]
command:      $(echo "${line}" | awk -v FS=";;" '{print $3}')
current:      <${current}>
operator:     ${operator}
required:     <${required}>
tips:         ${tips}
EOF
          std_prtline -l${len} -c-
        else # do log
          std_prtline -l${len} -c- -t"RAW INFO" | tee -a "${log_file}"
          tee -a "${log_file}" <<EOF
itemname:     ${itemname}
importance:   [${importance}]
command:      $(echo "${line}" | awk -v FS=";;" '{print $3}')
current:      <${current}>
operator:     ${operator}
required:     <${required}>
tips:         ${tips}
EOF
          std_prtline -l${len} -c- | tee -a "${log_file}"
        fi
      fi

      # set value to "null" if empty
      current=${current:=${null}}

      # reset
      result=0

      case ${operator} in
      equal)
        [[ ${current} != "${required}" ]] && result=1
        ;;
      include)
        echo "${current}" | grep -Eq "${required}" || result=1
        ;;
      == | =)
        [[ ${current} -ne ${required} ]] && result=1
        ;;
      !=)
        [[ ${current} -eq ${required} ]] && result=1
        ;;
      \>)
        [[ ${current} -le ${required} ]] && result=1
        ;;
      \<)
        [[ ${current} -ge ${required} ]] && result=1
        ;;
      \>=)
        [[ ${current} -lt ${required} ]] && result=1
        ;;
      \<=)
        [[ ${current} -gt ${required} ]] && result=1
        ;;
      *)
        std_prtmsg FERR "unsupported operator: \"${operator}\""
        continue
        ;;
      esac

      if [[ ${result} -eq 1 && ${importance} == hard ]]; then
        all_correct=false
        result=2
      fi

      if ${test_flag}; then
        if ! ${log_flag}; then
          if [[ ${result} -eq 1 ]]; then
            printf "RESULT:       \e[47;30mERROR\e[0m\n"
          elif [[ ${result} -eq 2 ]]; then
            printf "RESULT:       \e[47;30;5mERROR\e[0m\n"
          else # result == 0
            printf "RESULT:       \e[31;1mCORRECT\e[0m\n"
          fi
          std_prtline -l${len} -c=
        else # log_flag == true
          if [[ ${result} -eq 1 ]]; then
            printf "RESULT:       \e[47;30mERROR\e[0m\n" | tee -a "${log_file}"
          elif [[ ${result} -eq 2 ]]; then
            printf "RESULT:       \e[47;30;5mERROR\e[0m\n" | tee -a "${log_file}"
          else # result == 0
            printf "RESULT:       \e[31;1mCORRECT\e[0m\n" | tee -a "${log_file}"
          fi
          std_prtline -l${len} -c= | tee -a "${log_file}"
        fi
      else # test_flag == false
        if ! ${log_flag}; then
          if [[ ${result} -eq 1 ]]; then
            printf "%-12s\e[31;1m%s\e[0m [\e[47;30m%s\e[0m]\n" "ITEMNAME:" "${itemname}" "${importance}"
            printf "%-12s%s\n" "CURRENT:" "${current}"
            printf "%-12s%s %s\n" "REQUIRED:" "${operator}" "${required}"
            printf "%-12s%s\n" "TIPS:" "${tips}"
            std_prtline -l${len} -c=
          elif [[ ${result} -eq 2 ]]; then
            printf "%-12s\e[31;1m%s\e[0m [\e[47;30;5m%s\e[0m]\n" "ITEMNAME:" "${itemname}" "${importance}"
            printf "%-12s%s\n" "CURRENT:" "${current}"
            printf "%-12s%s %s\n" "REQUIRED:" "${operator}" "${required}"
            printf "%-12s%s\n" "TIPS:" "${tips}"
            std_prtline -l${len} -c=
          fi
        else # log_flag == true
          if [[ ${result} -eq 1 ]]; then
            printf "%-12s\e[31;1m%s\e[0m [\e[47;30m%s\e[0m]\n" "ITEMNAME:" "${itemname}" "${importance}" | tee -a "${log_file}"
            printf "%-12s%s\n" "CURRENT:" "${current}" | tee -a "${log_file}"
            printf "%-12s%s %s\n" "REQUIRED:" "${operator}" "${required}" | tee -a "${log_file}"
            printf "%-12s%s\n" "TIPS:" "${tips}" | tee -a "${log_file}"
            std_prtline -l${len} -c= | tee -a "${log_file}"
          elif [[ ${result} -eq 2 ]]; then
            printf "%-12s\e[31;1m%s\e[0m [\e[47;30;5m%s\e[0m]\n" "ITEMNAME:" "${itemname}" "${importance}" | tee -a "${log_file}"
            printf "%-12s%s\n" "CURRENT:" "${current}" | tee -a "${log_file}"
            printf "%-12s%s %s\n" "REQUIRED:" "${operator}" "${required}" | tee -a "${log_file}"
            printf "%-12s%s\n" "TIPS:" "${tips}" | tee -a "${log_file}"
            std_prtline -l${len} -c= | tee -a "${log_file}"
          fi
        fi
      fi
    done < <(grep -E "^${only_item};;" "${vrf_file}")

    if ${all_correct}; then
      if ! ${log_flag}; then
        std_prtline -l${len} -t"ALL CORRECT"
        std_prtline -l${len} -c=
      else
        std_prtline -l${len} -t"ALL CORRECT" | tee -a "${log_file}"
        std_prtline -l${len} -c= | tee -a "${log_file}"
      fi
    else # all_correct == false
      if ! ${log_flag}; then
        std_prtline -l${len} -t"ERROR: check info above for details"
        std_prtline -l${len} -c=
      else
        std_prtline -l${len} -t"ERROR: check info above for details" | tee -a "${log_file}"
        std_prtline -l${len} -c= | tee -a "${log_file}"
      fi
    fi
  else # only_flag == false
    # TODO
    std_prtmsg SKIP "TODO"
  fi
}
