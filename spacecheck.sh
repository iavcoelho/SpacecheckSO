#!/bin/bash

find_name=".*"
find_date=0
find_size="+0"
sort_options=""
reverse_sort=0
max_lines="-0"

echo "SIZE  NAME $(date +%Y%m%d) $@"
while getopts ":arl:s:d:n:" o; do 
  case "$o" in
    a) sort_options="-k2 "
    ;;
    r) reverse_sort=1
    ;;
    s)  find_size="+${OPTARG}c"
    ;;
    d)  find_date="$(date --date "${OPTARG}" +%s)"
    ;;
    n)  find_name+="${OPTARG}"
    ;;
    l)  max_lines="${OPTARG}"
    ;;
  esac
done
shift $((OPTIND-1))


if [[ $sort_options != *"-k2"* ]]; then
  sort_options="-n -k1 "
  reverse_sort=$(( -reverse_sort ))
fi

if [[ $reverse_sort == 0 ]]; then
  sort_options+="-r"
fi

regular_output=""
error_output=""
while IFS= read -r -d $'\0' folder; do 
  if find "$folder" >/dev/null 2>&1; then
    output="$(du -b --max-depth=0 "$folder" | awk '{print $0}')"
    regular_output+="$output\n"
  else
    error_output+="NA\t"$folder"\n"
  fi
done < <(find "$@" -type d -regex "$find_name" -newermt @"$find_date" -size "$find_size" -print0 2>/dev/null)

printf "$regular_output" | sort $sort_options | head -n $max_lines
printf "$error_output" | sort $sort_options | head -n $max_lines
