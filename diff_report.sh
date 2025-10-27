#!/bin/bash

if [ $# -ne 3 ]; then
    echo "Usage: $0 <repo_url> <branch1> <branch2>"
    exit 1
fi

repo_url=$1
branch1=$2
branch2=$3

temp_dir=$(mktemp -d)
git clone $repo_url $temp_dir
cd $temp_dir

diff_output=$(git diff --name-status $branch1 $branch2)

added=$(echo "$diff_output" | grep '^A' | wc -l)
modified=$(echo "$diff_output" | grep '^M' | wc -l)
deleted=$(echo "$diff_output" | grep '^D' | wc -l)
total=$((added + modified + deleted))

report_file="diff_report_${branch1}_vs_${branch2}.txt"

{
echo "Отчет о различиях между ветками"
echo "================================"
echo "Репозиторий:    $repo_url"
echo "Ветка 1:        $branch1"
echo "Ветка 2:        $branch2"
echo "Дата генерации: $(date '+%Y-%m-%d %H:%M:%S')"
echo "================================"
echo ""
echo "СПИСОК ИЗМЕНЕННЫХ ФАЙЛОВ:"
echo "$diff_output"
echo ""
echo "СТАТИСТИКА:"
echo "Всего измененных файлов: $total"
echo "Добавлено (A):    $added"
echo "Удалено (D):      $deleted"
echo "Изменено (M):     $modified"
} > $report_file

cp $report_file /home/kirillkom/DevOpsDZ_sem1_mag/devops_sem_1_task_1/

cd /
rm -rf $temp_dir

echo "Report generated: $report_file"