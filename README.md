# Bassel's Shell Script

## Overview

This script provides various system management functionalities including system information, network information, directory synchronization, CPU policy changes, battery threshold settings, and LED control. It also logs all executed commands and displays real-time kernel logs.

## Features

- **System Information**: Displays CPU, RAM, and Disk usage information.
- **Network Information**: Shows network configurations, DNS servers, and current network traffic.
- **Directory Synchronization**: Syncs a source directory to a target directory on a remote system.
- **CPU Policy Management**: Allows changing the CPU governor policy.
- **Battery Threshold Setting**: Sets the battery charging threshold.
- **LED Control**: Controls the CAPS LOCK LED.
- **System Reboot/Shutdown**: Reboots or shuts down the system.
- **Real-time Kernel Logs**: Displays kernel logs in real-time.
- **Command Logging**: Logs all executed commands to a log file.

## Requirements

- **Bash Shell**
- **Superuser (sudo) Access**: Required for certain commands.
- **Utilities**:
  - `iostat` for CPU statistics
  - `bmon` for network traffic monitoring
  - `rsync` for directory synchronization

## Setup

1. **Install Required Utilities**:
   ```bash
   sudo apt-get update
   sudo apt-get install sysstat bmon rsync
2. **Create and Make the Script Executable:**:
   ```bash
   chmod +x bassel_shell.sh
2. **Run the Script:**:
   ```bash
   sudo ./bassel_shell.sh

   
