#!/bin/bash

INTERVAL=5

# Flags for each option
SHOW_ALL=true
SHOW_CPU=false
SHOW_MEMORY=false
SHOW_NETWORK=false
SHOW_DISK=false
SHOW_LOAD=false
SHOW_PROCESSES=false
SHOW_SERVICES=false
SHOW_TOP_APPS=false

# Parsing Command Line Arguments
while [ "$1" != "" ]; do
    case $1 in
        -cpu) SHOW_CPU=true; SHOW_ALL=false ;;
        -memory) SHOW_MEMORY=true; SHOW_ALL=false ;;
        -network) SHOW_NETWORK=true; SHOW_ALL=false ;;
        -disk) SHOW_DISK=true; SHOW_ALL=false ;;
        -load) SHOW_LOAD=true; SHOW_ALL=false ;;
        -processes) SHOW_PROCESSES=true; SHOW_ALL=false ;;
        -services) SHOW_SERVICES=true; SHOW_ALL=false ;;
        -top) SHOW_TOP_APPS=true; SHOW_ALL=false ;;
        *) echo "Invalid option: $1" && exit 1 ;;
    esac
    shift
done

while true; do
    clear

    if [ "$SHOW_ALL" = true ] || [ "$SHOW_CPU" = true ]; then
        echo "CPU Monitoring:"
        
        # Detailed CPU Usage Breakdown
        CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk -F'[, ]+' '{print "User: " $2 "%, System: " $4 "%, Idle: " $8 "%, Nice: " $6 "%, IOWait: " $10 "%, IRQ: " $12 "%, SoftIRQ: " $14 "%"}')
        echo "$CPU_USAGE"
        echo

        sleep $INTERVAL
    fi

    if [ "$SHOW_ALL" = true ] || [ "$SHOW_MEMORY" = true ]; then
        echo "Memory Monitoring:"
        free -h
        echo

        sleep $INTERVAL
    fi

    if [ "$SHOW_ALL" = true ] || [ "$SHOW_NETWORK" = true ]; then
        echo "Network Monitoring:"

        # Number of concurrent connections
        CONNECTIONS=$(ss -s | grep -i "tcp:" | awk '{print $2}')
        echo "Number of concurrent connections to the server: $CONNECTIONS"

        # Packet drops
        INTERFACE=$(ip route | grep '^default' | awk '{print $5}')
        packet_drops_start=$(cat /sys/class/net/$INTERFACE/statistics/rx_dropped)

        # Sleep interval for accurate measurement
        sleep $INTERVAL

        packet_drops_end=$(cat /sys/class/net/$INTERFACE/statistics/rx_dropped)
        packet_drops_diff=$((packet_drops_end - packet_drops_start))
        echo "Packet drops in the last $INTERVAL seconds: $packet_drops_diff"

        # Network traffic in and out (MB)
        RX_BYTES_START=$(cat /sys/class/net/$INTERFACE/statistics/rx_bytes)
        TX_BYTES_START=$(cat /sys/class/net/$INTERFACE/statistics/tx_bytes)

        # Sleep interval for accurate measurement
        sleep $INTERVAL

        RX_BYTES_END=$(cat /sys/class/net/$INTERFACE/statistics/rx_bytes)
        TX_BYTES_END=$(cat /sys/class/net/$INTERFACE/statistics/tx_bytes)

        RX_MB=$(echo "scale=2; ($RX_BYTES_END - $RX_BYTES_START) / 1024 / 1024" | bc)
        TX_MB=$(echo "scale=2; ($TX_BYTES_END - $TX_BYTES_START) / 1024 / 1024" | bc)
        echo "Number of MB in: $RX_MB MB"
        echo "Number of MB out: $TX_MB MB"

        echo "Interpretation: Monitoring current network usage and performance."
        echo

        sleep $INTERVAL
    fi

    if [ "$SHOW_ALL" = true ] || [ "$SHOW_DISK" = true ]; then
        echo "Disk Usage:"
        df -h

        echo "Partitions using more than 80% of the space:"
        df -h | awk '$5+0 > 80 {print $0}'
        echo

        sleep $INTERVAL
    fi

    if [ "$SHOW_ALL" = true ] || [ "$SHOW_LOAD" = true ]; then
        echo "System Load and CPU Usage:"
        
        # Load Average
        LOAD_AVERAGE=$(uptime | awk -F'load average: ' '{print "Load Average: " $2}')
        echo "$LOAD_AVERAGE"

        # Detailed CPU Usage Breakdown
        CPU_BREAKDOWN=$(top -bn1 | grep "Cpu(s)" | awk -F'[, ]+' '{print "User: " $2 "%, System: " $4 "%, Idle: " $8 "%, Nice: " $6 "%, IOWait: " $10 "%, IRQ: " $12 "%, SoftIRQ: " $14 "%"}')
        echo "$CPU_BREAKDOWN"
        echo

        sleep $INTERVAL
    fi

    if [ "$SHOW_ALL" = true ] || [ "$SHOW_PROCESSES" = true ]; then
        echo "Process Monitoring:"
        echo "Number of active processes: $(ps aux | wc -l)"
        echo "Top 5 processes by CPU usage:"
        ps -eo pid,comm,%cpu --sort=-%cpu | head -n 6
        echo "Top 5 processes by memory usage:"
        ps -eo pid,comm,%mem --sort=-%mem | head -n 6
        echo

        sleep $INTERVAL
    fi

    if [ "$SHOW_ALL" = true ] || [ "$SHOW_SERVICES" = true ]; then
        echo "Service Monitoring:"
        for service in sshd nginx apache2 iptables; do
            systemctl is-active --quiet $service
            if [ $? -eq 0 ]; then
                echo "$service: Active"
            else
                echo "$service: Inactive"
            fi
        done
        echo

        sleep $INTERVAL
    fi

    if [ "$SHOW_ALL" = true ] || [ "$SHOW_TOP_APPS" = true ]; then
        echo "Top 10 Most Used Applications:"
        echo "Top 10 applications by CPU usage:"
        ps -eo pid,comm,%cpu --sort=-%cpu | head -n 11
        echo "Top 10 applications by memory usage:"
        ps -eo pid,comm,%mem --sort=-%mem | head -n 11
        echo

        sleep $INTERVAL
    fi

    # Global sleep to control overall loop interval
    sleep $INTERVAL
done

