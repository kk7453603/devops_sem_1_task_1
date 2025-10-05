#!/bin/bash

PID_FILE="system_monitor.pid"

case $1 in
    START)
        if [ -f $PID_FILE ]; then
            pid=$(cat $PID_FILE)
            if kill -0 $pid 2>/dev/null; then
                echo "Already running with PID $pid"
                exit 1
            else
                rm $PID_FILE
            fi
        fi
        nohup $0 MONITOR &
        echo $! > $PID_FILE
        echo "Started with PID $(cat $PID_FILE)"
        ;;
    STOP)
        if [ -f $PID_FILE ]; then
            pid=$(cat $PID_FILE)
            kill $pid
            rm $PID_FILE
            echo "Stopped"
        else
            echo "Not running"
        fi
        ;;
    STATUS)
        if [ -f $PID_FILE ]; then
            pid=$(cat $PID_FILE)
            if kill -0 $pid 2>/dev/null; then
                echo "Running with PID $pid"
            else
                echo "PID file exists but process not running"
                rm $PID_FILE
            fi
        else
            echo "Not running"
        fi
        ;;
    MONITOR)
        while true; do
            timestamp=$(date +%s)
            # Memory: total;free;%used
            mem_info=$(free | awk 'NR==2{printf "%.0f;%.0f;%.2f;", $2, $4, $3*100/$2}')
            # CPU %
            cpu_used=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
            # Disk %
            disk_used=$(df / | awk 'NR==2{print $5}' | sed 's/%//')
            # Load average 1m
            load_avg=$(uptime | awk '{print $NF}')
            # CSV line
            line="$timestamp;$mem_info$cpu_used;$disk_used;$load_avg"
            date_today=$(date +%Y-%m-%d)
            csv_file="system_report_$date_today.csv"
            echo $line >> $csv_file
            sleep 600
        done
        ;;
    *)
        echo "Usage: $0 {START|STOP|STATUS}"
        exit 1
        ;;
esac