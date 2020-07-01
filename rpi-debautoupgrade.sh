#/bin/bash

# this script auto-updates the RaspberryOS. 

# this script is meant to be called from a cron entry with a syntax that performs the update unattended and 
# sends the output the operation to a logfile in the same directory.

# Run: "sudo crontab -e" and add the following line to the file:
#  0 4 * * FRI /bin/bash /mnt/rpi_backup/rpiupgrade.sh >> /mnt/rpi_backup/rpiupgrade.log 2>&1 -q -f

echo ""
echo "$(date) >> RPi Package Updates Started"
echo "-------------------------------------------"
DEBIAN_FRONTEND=noninteractive apt-get update && apt-get full-upgrade -y && apt-get autoremove && apt-get autoclean && sudo apt-get clean
echo "-------------------------------------------"
echo "$(date) >> Package Updates Complete"
echo ""
exit