# RaspberryPi Scripts for Automated Backup, Updates, and Monitoring

## Front Matter
This project consists of several scripts written to support a personal RaspberryPi project that I have had successfully running for several years. These scripts are for my own personal use, but I've seen many people asking about RaspberryPi backups on various Pi Facebook/Reddit groups, so I decided to share them here. I hope someone else can find them useful in their project. 

These scripts were created from a variety of sources found in various places online. They have evolved over time to adapt to changing requirments in my network environment and backup needs. I do not have the original sources or I would have credited them here. If anyone is familiar with where similar scripts/commands might have been first published, please let me know and I will happily credit those sources.
## Who are these scripts for?
* Anyone who is looking for a simple, automated, "live" backup process for their raspberryPi project. _("live" = I wanted to backup without taking the Pi offline and physically removing the SD to do a backup)_
* Anyone who wants to quickly recover their Pi in the event of a failed SD card. _(Using PiShrink, the resulting image can be restored to any SD card and resized (expanded) on first boot)_
* Anyone who wants to keep their Pi updated via automatic, unattended updates _(I fully understand the arguments for and against using apt auto-updates on Debian based Linux). However, and because I have a good backup solution with a quick recovery time, I felt it was an acceptable risk for my situation._ YMMV!
## What do these scripts do?
#### _`rpi-backup.sh`_  
This script makes an backup image (using DD) of the Raspberry Pi SD card (/dev/mmcblk0) and writes the resulting _'backup_date.img'_ to a mounted network share. That image file is then compressed using the [PiShrink.sh](https://github.com/Drewsif/PiShrink) script and saved as _'backup_date.img.xz'_ The resulting image file can be restored using any image writing software, like Rufus.  

My primary goal with this script was to backup only the critical Pi system files to a remote machine. Since my Pi was mounted oudoors, and in a generator enclosure, I needed to do scheduled backups without taking the Pi offline, or shutting down to manually copy the SD card. This script accomplishes that, and also trims the number backups in the mounted folder, so that only the newest five backups are kept. That gives me plenty of time to review the log files every few weeks and jump back 5 backups if something bad happened.

* **Note:** _While there may be several good ways to accomplish this task, this script uses "dd" to backup the filesystem "live", while it is running. There seems to be some debate about using DD in this way as called out to me in a Facebook group. I've been running some version of this script for several years and I have never had an issue. However, I recommend that you do your own research on this topic and determine for yourself if it is right for your use-case. For reference:  
https://www.raspberrypi.org/forums/viewtopic.php?t=211268_
#### _`rpi-temperature.sh`_  
This script queries the rpi thermal sensors, converts the results to Farenheit, and writes the formatted entry to a logfile in a mounted folder. I was having an issue with thermal throttling since my Pi was mounted outside inside a backup generator enclosure. I cobbled this script together to periodically log the temps on my Pi. I used cron to automate the execution schedule and capture the temp readings to log entries when my generator was idle, when it was running, during various points during the day, and points during the night. I also call this script from other scripts to determine if heavy processing jobs are having a significant impact on temps due to the unique mounting of my setup. It helped me determine optimal placement inside the generator enclosure and determine if a different case/fan setup was necessary for my Pi (it was).
###### Example Logfile Output for _`rpi-temperature.sh`_ :
```
Tue 30 Jun 2020 02:00:01 PM EDT @ rPi
GPU => 53.7'C (128.6'F)
CPU => 53.6'C (128.4'F)
-------------------------------------------

Tue 30 Jun 2020 08:00:02 PM EDT @ rPi
GPU => 51.5'C (124.7'F)
CPU => 51.5'C (124.7'F)
-------------------------------------------

Wed 01 Jul 2020 02:00:01 PM EDT @ rPi
GPU => 54.8'C (130.6'F)
CPU => 53.6'C (128.4'F)
-------------------------------------------
```
#### _`rpi-debautoupgrade.sh`_  
This script runs an unattended apt update/upgrade/clean and echoes the output to a logfile for later examination. This script runs well on RaspberryOS, but I suspect it should also work on any Debian based OS.

###### Example Logfile Output for _`rpi-debautoupgrade.sh`_ :
```
Fri 20 Sep 2019 04:00:01 AM EDT >> rPi Package Updates Started  
-------------------------------------------  
Get:1 https://archive.raspberrypi.org/debian buster InRelease [25.2 kB]  
Get:2 http://raspbian.raspberrypi.org/raspbian buster InRelease [15.0 kB]  
Get:3 https://archive.raspberrypi.org/debian buster/main armhf Packages [229 kB]  
Get:4 http://raspbian.raspberrypi.org/raspbian buster/main armhf Packages [13.0 MB]  
Fetched 13.3 MB in 55s (243 kB/s)  
Reading package lists...
Reading package lists...
Building dependency tree...
Reading state information...
Calculating upgrade...
The following packages will be upgraded:
  lxplug-network tzdata
2 upgraded, 0 newly installed, 0 to remove and 0 not upgraded.
Need to get 293 kB of archives.
After this operation, 2,048 B of additional disk space will be used.
Get:1 http://mirror.pit.teraswitch.com/raspbian/raspbian buster/main armhf tzdata all 2019c-0+deb10u1 [261 kB]
Get:2 https://archive.raspberrypi.org/debian buster/main armhf lxplug-network armhf 0.18 [31.9 kB]
debconf: unable to initialize frontend: Dialog
debconf: (TERM is not set, so the dialog frontend is not usable.)
debconf: falling back to frontend: Readline
debconf: unable to initialize frontend: Readline
debconf: (This frontend requires a controlling tty.)
debconf: falling back to frontend: Teletype
dpkg-preconfigure: unable to re-open stdin: 
Fetched 293 kB in 1s (385 kB/s)
(Reading database ... 
(Reading database ... 5%
(Reading database ... 10%
...
(Reading database ... 95%
(Reading database ... 100%
(Reading database ... 124398 files and directories currently installed.)
Preparing to unpack .../tzdata_2019c-0+deb10u1_all.deb ...
Unpacking tzdata (2019c-0+deb10u1) over (2019b-0+deb10u1) ...
Preparing to unpack .../lxplug-network_0.18_armhf.deb ...
Unpacking lxplug-network (0.18) over (0.17) ...
Setting up tzdata (2019c-0+deb10u1) ...
debconf: unable to initialize frontend: Dialog
debconf: (TERM is not set, so the dialog frontend is not usable.)
debconf: falling back to frontend: Readline

Current default time zone: 'America/New_York'
Local time is now:      Fri Sep 20 04:01:37 EDT 2019.
Universal Time is now:  Fri Sep 20 08:01:37 UTC 2019.
Run 'dpkg-reconfigure tzdata' if you wish to change it.

Setting up lxplug-network (0.18) ...
Processing triggers for hicolor-icon-theme (0.17-2) ...
Reading package lists...
Building dependency tree...
Reading state information...
0 upgraded, 0 newly installed, 0 to remove and 0 not upgraded.
-------------------------------------------
Fri 20 Sep 2019 04:01:45 AM EDT >> Package Updates Complete
```

## Things to know about these scripts
I had several specific goals I wanted to accomplish with these scripts.  
1. I wanted the scripts, and the resulting logfiles, to reside somewhere other than local on the Pi. If the Pi died, I needed to be able to recover quickly. That's why I have the scripts and logfiles saved in a mounted folder on a remote machine.
2. I wanted everything automated. I did not want to login to the Pi often to do routine maintenance. I just wanted to check logfiles periodically and scan for issues.
3. I wanted simplicity. 

#### NOTE: _If you decide to use these scripts in your setup_;
* They likely will not work "out of the box". They will require some editing to fit your individual use-case and network setup.  
* The scripts refer to "/mnt/rpi_backup" in several locations. This is a remote share on an "always-on" server that is mounted locally on each boot of my RaspberryPi. As long as the remote machine is online when my Pi boots, "/mnt/rpi_backup" will always be available. I'll detail how to set that up for anyone that needs a hand with it.
* If you decide to run these scripts from the Pi, instead of from the network share location, you will need to mount the share using one of the methods in the next section and make sure it is mounted before the backup script is executed.
* The backup script will take a long time to run. Don't be in a hurry. The DD image creation takes almost 1hr on my 32GB SD card. The resulting DD _.img_ file is approx 6GB. After DD finishes, PiShrink takes another 2hrs to compress the image using XZ compression. The resulting _.img.xz_ file is approx 2.5GB with a total completion time around 3 hours. For this reason, I have the backup scheduled during periods when my network is usually very quiet and has no traffic (overnight).

## Prerequisites
**Three requirements for these scripts:**  
The (2) software package requirements for these scripts are the "bc" and "pishrink". These are used by the temperature logging and backup scripts.

* **PiShrink:**
The backup script will install pishrink if it is not installed.
Install it manually from here if prefered:
https://github.com/Drewsif/PiShrink

* **BC:**  
Install with ``` sudo apt install bc ``` or ``` sudo apt-get install bc ```

* The third requirment is a mount at /mnt/rpi_backup that is mounted and writable to a network share or USB device. 
## Installing and Using
You can save and execute these scripts locally on the Pi itself. However, as mentioned above, I have these scripts saved in a remote shared folder on a Windows Server. If you choose to setup similarly, here are the instructions for setting up the Pi.  

The scripts use a folder mounted locally on the Pi as `/mnt/rpi_backups`. In my network, this is a Windows share on an "always-on" machine that I use for network file storage. 
### Credential File:
My Windows Share requires credentials for each connection. Those credentials are saved in the Pi user home directory in a file called 
`.cifsuser`  
It can be created with the following commands:  
###### Create Credential File:
```
    sudo nano /home/pi/.cifsuser
```
###### File contents:
```
    username=yourwindowsshareusername
    password=yourwindowssharepassword
    #Domain=  (optional - uncomment if used)
```
##### **_press `crtl+o` to write the file, press `enter` to save, `ctrl+x` to exit nano editor_**
###### Change Permissions on credential file:
```
    sudo chmod u+r-wx,go-rwx /home/pi/.cifsuser
```
---
### Create backup mount point: 
```
   sudo mkdir /mnt/rpi_backup
   sudo chmod u+rw-x,go-rwx /mnt/rpi_backup
```
#### Mounting Options: 
**Note:** _change //192.168.x.x and folder names to match your network setup_
###### To manually mount as-needed
``` 
    Mount:
        sudo mount -t cifs -o rw,vers=3.0,credentials=/home/pi/.cifsuser //192.168.x.x/rpibackup /mnt/rpi_backup
    
    Unmount:
        sudo umount -q /mnt/rpi_backup
```
###### To permanently mount at boot time (via fstab)
``` 
    sudo nano /etc/fstab
    
    Add this line to the end of the file (obviously, edit the remote IP and folder names as needed):
    //192.168.x.x/rpibackup /mnt/rpi_backup cifs credentials=/home/pi/.cifsuser,uid=pi,gid=pi,iocharset=utf8,sec=ntlmssp,vers=3.0,_netdev,rw 0 0
 ```
##### **_press `crtl+o` to write the file, press `enter` to save, `ctrl+x` to exit nano editor_**
###### Testing mount points
```
    To force mounting of all entries in the fstab file, type:
        sudo mount -a
		
    Or, for manual mounting, a slightly different mount format is required.
    Manual mount test:
        sudo mount -t cifs -o rw,vers=3.0,credentials=/home/pi/.cifsuser //192.168.x.x/rpibackup /mnt/rpi_backup
		
    To verify mount, type:
        df -h    
		
    Unmount:
        sudo umount -q /mnt/rpi_backup
```
---
### To run the scripts on a schedule, use cron
 for help with cron schedules, visit https://crontab.guru/
###### Edit crontab file:
``` 
    type:  sudo crontab -e

    These are examples of my cron entries. The last one will pipe the upgrade script to the logfile.

     Add these entries to bottom of the cron file as needed:
        0 3 * * 0,3,5 /bin/bash /mnt/rpi_backup/rpibackup.sh
        0 14 * * * /bin/bash /mnt/rpi_backup/rpi-temperature.sh
        0 20 * * * /bin/bash /mnt/rpi_backup/rpi-temperature.sh
        0 4 * * FRI /bin/bash /mnt/rpi_backup/rpi-debautoupgrade.sh >> /mnt/rpi_backup/rpiupgrade.log 2>&1 -q -f 
``` 
##### **_press `crtl+o` to write the file, press `enter` to save, `ctrl+x` to exit nano editor_**
## Testing help
To run the scripts manually for testing, use the following commands from console.
###### Testing Scripts
``` 
/bin/bash /mnt/rpi_backup/rpibackup.sh
/bin/bash /mnt/rpi_backup/rpi-temperature.sh
/bin/bash /mnt/rpi_backup/rpi-debautoupgrade.sh >> /mnt/rpi_backup/rpiupgrade.log 2>&1 -q -f 
```
## License
No License. Free to use and distribute with no restrictions.



