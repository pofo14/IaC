#!/bin/bash

LOG_FILE="/var/log/simple_fancontrol.log"
IPMITOOL="ipmitool"

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Function to set fan speed
set_fan_speed() {
    local zone=$1
    local speed=$2
    local percentage=$3
    log_message "Setting fan speed to $percentage"
    $IPMITOOL raw 0x30 0x91 0x5A 0x3 $zone $speed
}

# Function to get drive temperatures
get_drive_temps() {
    local temps=()
    for drive in /dev/sd?; do
        temp=$(smartctl -A $drive | awk '/Temperature_Celsius/ {print $10}')
        temps+=($temp)
    done
    echo "${temps[@]}"
}

# Function to calculate average temperature
calculate_average_temp() {
    local temps=("$@")
    local total=0
    local count=${#temps[@]}
    for temp in "${temps[@]}"; do
        total=$((total + temp))
    done
    echo $((total / count))
}

# Main loop
while true; do
    drive_temps=($(get_drive_temps))
    avg_temp=$(calculate_average_temp "${drive_temps[@]}")
    log_message "Average drive temperature: $avg_temp"

    if [ $avg_temp -lt 35 ]; then
        # set_fan_speed 0x11 0x20  # Set FANA-B to 12.5%
        # ipmitool raw 0x30 0x91 0x5A 0x3 0x10 0x20
        set_fan_speed 0x10 0x20 12.5%  # Set FAN1-4 to 12.5%
    elif [ $avg_temp -lt 48 ]; then
        # set_fan_speed 0x11 0x40  # Set FANA-B to 25%
        set_fan_speed 0x10 0x40 25% # Set FAN1-4 to 25%
    elif [ $avg_temp -lt 55 ]; then
        # set_fan_speed 0x11 0x7f  # Set FANA-B to 50%
        # ipmitool raw 0x30 0x91 0x5A 0x3 0x10 0x7f
        set_fan_speed 0x10 0x7f 50% # Set FAN1-4 to 50%
    else
        # set_fan_speed 0x11 0xff  # Set FANA-B to 100%
        set_fan_speed 0x10 0xff 100% # Set FAN1-4 to 100%
    fi

    sleep 300  # Check every 5 minutes
done
 
 