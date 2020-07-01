#!/bin/bash

# This script queries the rpi thermal sensors, converts the results to Farenheit, and
# writes the entry to a logfile on a mounted share.

# Run it on a schedule with an entry in Cron (sudo crontab -e):
# 0 14 * * * /bin/bash /mnt/rpi_backup/_tempmonitor.sh

# This script uses the "bc" package. It must be installed via apt "sudo apt install bc"

gpu=$(/opt/vc/bin/vcgencmd measure_temp | awk -F "[=\']" '{print $2}')
cpu=$(</sys/class/thermal/thermal_zone0/temp)
cpu=$(echo "$cpu / 100 * 0.1" | bc)
cpuf=$(echo "(1.8 * $cpu) + 32" | bc)
gpuf=$(echo "(1.8 * $gpu) + 32" | bc)
{
echo "$(date) @ $(hostname)"
echo "GPU => $gpu'C ($gpuf'F)"
echo "CPU => $cpu'C ($cpuf'F)"
echo "-------------------------------------------"
echo ""
} 2>&1 | tee -a /mnt/rpi_backup/_tempmonitor.log

