#!/bin/bash

outFile="rpibackup_$(date +%Y%m%d).img" # Create final filename with date and .img suffix
backupDir=/mnt/rpi_backup #this is auto mounted to a Windows share via an fstab entry (see README.md)
localDev=/dev/mmcblk0 # this is the local SD card that we want an image of

#check if PiShrink is installed. If not, install.
#use PiShrink to compress DD image. See README.md for more information on this
echo "Checking required package(s) ..."
if [ -x /usr/local/bin/pishrink.sh ]; then
    echo "package (PiShrink) is installed and is executable."
else 
    echo "package (PiShrink) is not installed, installing ..."
    wget https://raw.githubusercontent.com/Drewsif/PiShrink/master/pishrink.sh
    chmod +x pishrink.sh && sudo mv pishrink.sh /usr/local/bin && sleep 3
    if [ -x /usr/local/bin/pishrink.sh ]; then
        echo "package (PiShrink) is installed and is executable."
    else
        echo "package (PiShrink) could not be installed."
        echo "visit https://github.com/Drewsif/PiShrink to manually install."
        echo "exiting script..." && exit
    fi
fi

# check the backup directory is mounted and change directory
echo "Checking mount at $backupDir ..."
if  mountpoint -q $backupDir; then
    echo "$backupDir is mounted, continue." 
    cd $backupDir
else  
    echo "$backupDir is not mounted. Script cannot continue."
    echo "Check that $backupDir is properly mounted and writable and retry the script."
    echo "exiting script ..." && exit  
fi

# Copy to image file using DD and save as img
echo "Creating DD image of device $localDev - $backupDir/$outFile ..."
sudo dd if=$localDev of=$backupDir/$outFile
if ! [ -f "$backupDir/$outFile" ]; then
    echo "Something went wrong; ERROR: DD finished, but $outFile does not exist in $backupDir"
    echo "exiting script ..." && exit
else
    echo "DD Backup file: $outFile - Created"
fi

# Call PiShrink to shrink and compress image. This removes uneeded folders/files, reduces image size, and makes it restorable to any size SD card.
echo "Calling pishrink.sh to shrink and compress the img file..."
sudo pishrink.sh -Zad $backupDir/$outFile &> /dev/null
                # -Z Compress image after shrinking with xz
                # -a Compress image in parallel using multiple cores
                # -d Write debug messages in a debug log file
                # https://github.com/Drewsif/PiShrink
if [ -f "$backupDir/$outFile.xz" ]; then
    echo "PiShrink Backup file: $outFile.xz - Created"
else
    echo "Something went wrong; ERROR: $outFile.xz does not exist in $backupDir"
    echo "exiting script ..." && exit 
fi

# delete all but the last 5 backups
echo "Cleaning up the backup directory, keeping last 5 backups ..."
ls -trd *.img.xz | head -n -5 | xargs --no-run-if-empty rm --

# **Optional** run tempmonitor script to log current rpi temp
#echo "---rPi Backup Script---" >> /mnt/rpi_backup/rpi-temperature.log
#bash /mnt/rpi_backup/rpi-temperature.sh

echo "Done. exit ..."
exit
