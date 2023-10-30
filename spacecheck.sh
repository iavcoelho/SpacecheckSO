#!/bin/bash

find_name=".*"
find_date=0
find_size="+0"
sort_options=""
reverse_sort=0
max_lines="-0"

print_help() {
  cat <<EOF
Usage: ./spacecheck.sh [options] directory1 directory2 ...

Options:
  -s: Specify a minimum file size.
  -d: Specify a file's last modification date.
  -n: Specify a regular expression for file names.
  -l: Specify a maximum number of lines to show.
  -r: Sort by reverse order.
  -a: Sort by file name.
  -h: Display this help text.

EOF
}


while getopts ":harl:s:d:n:" o; do 
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
    h) print_help
      exit
    ;;
    \?) print_help
      exit
    ;;
    : ) echo "Option -$OPTARG requires an argument" >&2
        print_help
        exit
    ;;
  esac
done
shift $((OPTIND-1))

echo "SIZE  NAME $(date +%Y%m%d) $@"

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
    output="$(find "$folder" -type f -regex "$find_name" -newermt @"$find_date" -size "$find_size" -print0 | du -c --files0-from=- -b --max-depth=0 | tail -n1 | awk '{print $1}')"
    regular_output+="$output\t$folder\n"
  else
    error_output+="NA\t"$folder"\n"
  fi
done < <(find "$@" -type d -print0 2>/dev/null)

printf "$regular_output" | sort $sort_options | head -n $max_lines
printf "$error_output" | sort $sort_options | head -n $max_lines
