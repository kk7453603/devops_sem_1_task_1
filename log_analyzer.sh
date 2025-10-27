#!/bin/bash

if [ $# -ne 2 ]; then
    echo "Usage: $0 <log_file> <keyword>"
    exit 1
fi

log_file=$1
keyword=$2

count=$(grep -c "$keyword" "$log_file")
echo "Количество найденных ошибок: $count"

output_file="errors_${keyword}.txt"
grep "$keyword" "$log_file" > "$output_file"
echo "Ошибки сохранены в $output_file"