#!/bin/bash

sort_options=""
reverse_sort=0
max_lines="-0"
 
print_help() {
  cat <<EOF
Usage: ./spacecheck.sh [options] directory1 directory2 ...

Options:
  -l: Specify a maximum number of lines to show.
  -r: Sort by reverse order.
  -a: Sort by file name.
  -h: Display this help text.
EOF
}


while getopts ":harl:" o; do 
  case "$o" in
    a) sort_options="-k2 "
    ;;
    r) reverse_sort=1
    ;;
    l) 
    if [[ "${OPTARG}" == ?([[:digit:]]*) ]]; then
        # Check if the argument is numeric
        max_lines="${OPTARG}"
      else
        echo "Error: ${OPTARG} is an invalid argument for -l"
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
if [[ $sort_options != *"-k2"* ]]; then
  sort_options="-n -k1 "
  reverse_sort=$(( -reverse_sort ))
fi

if [[ $reverse_sort == 0 ]]; then
  sort_options+="-r"
fi


declare -A old_data
declare -A new_data
result="" 
while IFS=$'\t' read -r size path; do
  old_data["$path"]=$size
done < <(tail -n +2 "$1") 

while IFS=$'\t' read -r size path; do
  new_data["$path"]=$size
done < <(tail -n +2 "$2");

for key in "${!old_data[@]}"; do
  if [[ -v new_data["$key"] ]]; then
    new_value="${new_data["$key"]}"
    old_value="${old_data["$key"]}"
    if [[ "$new_value" != "NA" && "$old_value" != "NA" ]]; then
      difference=$((new_value - old_value))
    else
      difference="NA"
    fi
    output="$(printf "%s\t%s\n" "$difference" "$key")"
    result+="$output\n"
  else
    result+="$(printf -- "-${old_data["$key"]}\t$key\tREMOVED\n")\n"
  fi
done

for key in "${!new_data[@]}"; do
  if ! [[ -v old_data["$key"] ]]; then
    result+="$(printf "%s\t%s\tNEW\n" ${new_data["$key"]} "$key")\n"
  fi
done

printf "$result" | sort $sort_options | head -n $max_lines
