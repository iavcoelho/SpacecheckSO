#!/bin/bash

find_name=".*"
find_date=$(date -d "n" +%s)
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
exit 0
}


while getopts ":harl:s:d:n:" o; do 
  case "$o" in
    a) sort_options="-k2 "
    ;;
    r) reverse_sort=1
    ;;
    s)
        if [[ -z ${OPTARG} ]]; then
            echo "error: option -s is missing an argument"
            print_help
            exit 1
        fi
        if ! [[ "${OPTARG}" == ?([[:digit:]]*) ]]; then
            echo "Error: File size has to be a positive number"
            print_help
            exit 1
        fi
        find_size="+${OPTARG}c"
    ;;
    d)  
        if [[ -z ${OPTARG} ]]; then
            echo "Error: Option -d is missing an argument"
            print_help
            exit 1
        fi
        if !(date -d "${OPTARG}") > /dev/null 2>&1; then
            echo "Error: Invalid date"
            print_help
            exit 1
        fi
        find_date="$(date --date "${OPTARG}" +%s)"
    ;;
    n)  
        if [[ -z ${OPTARG} ]]; then
            echo "Error: Option -n is missing an argument"
            print_help
            exit 1
        fi
        find_name+="${OPTARG}"
    ;;
    l)  
    if [[ "${OPTARG}" == ?([[:digit:]]*) ]]; then
        # Check if the argument is numeric
        max_lines="${OPTARG}"
      else
        echo "Error: The maximum number of lines has to be a positive number"
        print_help
        exit 1
      fi
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
echo "SIZE  NAME $(date +%Y%m%d) $@"
shift $((OPTIND-1))
if [[ "$#" == "0" ]]; then
    echo "An error has occured parsing the arguments"
    print_help
    exit 1
fi

if [[ $sort_options != "-k2 " ]]; then
  sort_options="-n -k1 "
  reverse_sort=$(( 1 - $reverse_sort ))
fi

if [[ $reverse_sort == 1 ]]; then
  sort_options+="-r"
fi

regular_output=""
error_output=""
while IFS= read -r -d $'\0' folder; do 
  if find "$folder" >/dev/null 2>&1; then
    output="$(find "$folder" -type f -regex "^.*/$find_name$" ! -newermt @"$find_date" -size "$find_size" -print0 | du -c --files0-from=- -b --max-depth=0 | tail -n1 | awk '{print $1}')"
    regular_output+="$output\t$folder\n"
  else
    error_output+="NA\t"$folder"\n"
  fi

done < <(find "$@" -type d -print0 2>/dev/null)

printf "$regular_output$error_output" | sort $sort_options | head -n $max_lines
