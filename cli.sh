#!/bin/bash

# Set log file path
LOGFILE="/var/log/bassel_shell.log"

# Function to log commands
fucntion log_command() {
    echo "$(date +"%Y-%m-%d %T") - $1" >> $LOGFILE
}

# Check user mode
if [ "$EUID" -eq 0 ]; then
    mode="Admin"
else
    mode="User"
fi
#system info
function system_info() {
    log_command "Executing system_info"
    echo "CPU Info:"
    cat /proc/cpuinfo | grep 'model name\|temperature\|MHz' | uniq
    iostat -c | tail -n +2

    echo "RAM Info:"
    cat /proc/meminfo | grep 'MemTotal\|MemFree\|MemAvailable'

    echo "Disk Usage:"
    df -h | grep '^/dev'
}
#network info
function network_info() {
    log_command "Executing network_info"
    echo "Network configurations:"
    ifconfig

    echo "DNS Servers:"
    cat /etc/resolv.conf | grep "nameserver"

    echo "Current Network Traffic:"
    bmon -p enp0s3 -o ascii:quitafter=1 | awk '/enp0s3/ { rx = $2; tx = $4 } END { print "Download Rate: " rx " bps\nUpload Rate: " tx " bps" }'
}

function dir_sync() {
    log_command "Executing dir_sync"
    read -p "Enter source directory: " src
    read -p "Enter target IP: " target_ip
    read -p "Enter target directory: " target_dir
    rsync -avz $src $target_ip:$target_dir
}

function change_cpu_policy() {
    log_command "Executing change_cpu_policy"
    echo "Available CPU Governors:"
    cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors
    read -p "Enter desired CPU policy: " cpu_policy
    echo $cpu_policy | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
}

function set_battery_threshold() {
    log_command "Executing set_battery_threshold"
    read -p "Enter desired battery threshold (0-100): " threshold
    echo $threshold | sudo tee /sys/class/power_supply/BAT0/charge_control_end_threshold
}

function control_led() {
    log_command "Executing control_led"
    read -p "Turn CAPS LOCK LED on (1) or off (0): " led_state
    echo $led_state | sudo tee /sys/class/leds/input2::capslock/brightness
}

function reboot_system() {
    log_command "Executing reboot_system"
    shutdown -r now
}

function shutdown_system() {
    log_command "Executing shutdown_system"
    shutdown now
}

# Display kernel logs in real-time in the background
tail -f /var/log/kern.log &

while true; do
    echo "Bassel's shell$\$"
    read option
    case $option in
        sys) system_info ;;
        netw) network_info ;;
        sync_dir) dir_sync ;;
        dev)
            [ "$mode" = "Admin" ] && {
                read -p "change cpu policy (p) or change threshold (t) or capslock (c): " op
                if [ "$op" = "p" ]; then
                    change_cpu_policy
                elif [ "$op" = "c" ]; then
                    control_led
                elif [ "$op" = "t" ]; then
                    set_battery_threshold
                else
                    echo "$op not a valid option"
                fi
            } || {
                echo "permission denied try running with sudo"
            } ;;
        shut)
            [ "$mode" = "Admin" ] && {
                read -p "shutdown (s) or reboot (r): " rs
                if [ "$rs" = "s" ]; then
                    shutdown_system
                else
                    reboot_system
                fi
            } || {
                echo "permission denied try running with sudo"
            } ;;
        quit) break ;;
        *)
            echo "invalid option: $option"
            log_command "Invalid option: $option"
            ;;
    esac
done

# Kill the background tail process on exit
trap 'kill $(jobs -p)' EXIT
