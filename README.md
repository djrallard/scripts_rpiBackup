# RaspberryPi Scripts for Automated Backup, Updates, and Monitoring

This project consists of several scripts written to support a personal RaspberryPi project that I have had successfully running for over a year. I've seen many people asking about RaspberryPi backups on various Pi Facebook groups, so I decided to share them here. I hope someone else can find them useful in their project. 

These scripts were created from a variety of sources found in various places online. I do not have the original sources or I would have credited them here.


## Who are these scripts for?

* Anyone who is looking for a simple, automated, live backup process for their raspberryPi project.
* Anyone who wants to quickly recover their Pi in the event of a failed SD card.
* Anyone who wants to keep their Pi updated via automatic, unattended updates (I fully understand the arguments for and against using apt auto-updates on Debian based Linux). However, and because I have a good backup solution with a quick recovery time, I felt it was an acceptable risk for my situation. YMMV!

## What do these scripts do?

#### _`rpi-backup.sh`_  
This script makes an backup image of the Raspberry Pi SD card (/dev/mmcblk0), compresses it, and writes the resulting _'file.image.gz'_ to a share on another machine on the network that is mounted as a local folder. The resulting image file can be restored using any image writer software, like Rufus.  
 
My main goal with this script was to backup only the critical Pi system files to a remote machine. Since my Pi was mounted oudoors, and in a generator enclosure , I needed to do the backup without taking the Pi offline, or shutting down to manually copy the SD card, periodically. This script accomplishes that, and also trims the number backups in the mounted folder, so that only the newest five backups are kept. That gives me plenty of time to review the log files every few weeks and jump back 5 weeks if something bad happened.

* While there may be several good ways to accomplish this task, this script uses "dd" to backup the filesystem "live", while it is running. There seems to be some debate about using DD in this way as called out to me in a Facebook group. I advise that you do your research on this topic and determine for yourself if it is right for your use-case. For reference:
https://www.raspberrypi.org/forums/viewtopic.php?t=211268


#### _`rpi-temperature.sh`_  
This script queries the rpi thermal sensors, converts the results to Farenheit, and writes the formatted entry to a logfile in a mounted folder. I was having an issue with thermal throttling since my Pi was mounted outside inside a backup generator enclosure. I cobbled this script together to periodically log the temps on my Pi. I used cron to automate the execution schedule and capture temp log entries when my generator was idle, when it was running, points during the day, and points during the night. I also call this script from other scripts to determine if heavy processing jobs are having a significant impact on temps due to the unique mounting of my setup. It helped me determine optimal placement inside the generator enclosure and determine if a different case/fan setup was necessary for my Pi (it was).

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
<dl>
    <dd>1. I wanted the scripts, and the resulting logfiles, to reside somewhere other than local on the Pi. If the Pi died, I needed to be able to recover quickly. That's why I have the scripts and logfiles saved in a mounted folder on a remote machine.</dd>
    <dd>2. I wanted everything automated. I did not want to login to the Pi often to do routine maintenance. I just wanted to check logfiles periodically and scan for issues.</dd>
    <dd>3. I wanted simplicity. </dd>
</dl>

#### NOTE: _If you decide to use these scripts in your setup_;

* They likely will not work "out of the box". They will require some editing to fit your individual use-case and network setup. The scripts refer to "/mnt/rpi_backup" in several locations. This is a remote share on an "always-on" server that is mounted locally on each boot of my RaspberryPi. As long as the remote machine is online when my Pi boots, "/mnt/rpi_backup" will always be available. I'll detail how to set that up for anyone that needs a hand with it.


## Prerequisites

The only prereq is the "bc" package used by the temperature logging script.

Install with ``` sudo apt install bc ``` or ``` sudo apt-get install bc ```

## Installing and Using

You can save and execute these scripts locally on the Pi itself. However, as mentioned above, I have these scripts saved in a remote shared folder on a Windows Server. If you choose to setup similarly, here are the instructions for setting up the Pi.

The scripts uses folder mounted locally on the Pi as `/mnt/rpi_backups`. In my network, this is a Windows share on an "always-on" machine that I use for network file storage. 



### Create backup mount point: 

<dd>

```
   sudo mkdir /mnt/rpi_backup
   sudo chmod u+rw-x,go-rwx /mnt/rpi_backup
```

<dt>Edit fstab file to auto-mount at boot time:</dt>
  
``` 
sudo nano /etc/fstab

Add this line to the end of the file (obviously, edit the remote IP and folder names as needed):
//192.168.x.x/rpibackup /mnt/rpi_backup cifs credentials=/home/pi/.cifsuser,uid=pi,gid=pi,iocharset=utf8,sec=ntlmssp,vers=3.0,_netdev,rw 0 0
 ```
_<strong> press `crtl+o` to write the file, press `enter` to save, `ctrl+x` to exit nano editor </strong>_

---

My Windows Share requires credentials for each connection. Those credentials are saved in the Pi user home directory in a file called `.cifsuser`

It can be created with the following commands:  
### Create Credential File:

```
	sudo nano /home/pi/.cifsuser
```

<dt> File contents:</dt>

```
	username=yourwindowsshareusername
    password=yourwindowsshareusername
	#Domain=  (optional - uncomment if used)
```
_<strong> press `crtl+o` to write the file, press `enter` to save, `ctrl+x` to exit nano editor </strong>_

<dt> Change Permissions on credential file: </dt>

```
    sudo chmod u+r-wx,go-rwx /home/pi/.cifsuser
```

</dd>

---

### To run the scripts on a schedule, use cron

 for help with cron schedules, visit https://crontab.guru/
<dt>Edit crontab file:</dt>
<dd>

```
	type:  sudo crontab -e

    These are examples of my cron entries. The last one will pipe the upgrade script to the logfile.

     Add these entries to bottom of the cron file as needed:
        0 3 * * 0,3,5 /bin/bash /mnt/rpi_backup/rpibackup.sh
        0 14 * * * /bin/bash /mnt/rpi_backup/rpi-temerature.sh
        0 20 * * * /bin/bash /mnt/rpi_backup/rpi-temperature.sh
        0 4 * * FRI /bin/bash /mnt/rpi_backup/rpi-debautoupgrade.sh >> /mnt/rpi_backup/rpiupgrade.log 2>&1 -q -f 
``` 
_<strong> press `crtl+o` to write the file, press `enter` to save, `ctrl+x` to exit nano editor </strong>_
</dd>  

 

## Testing help

To run the scripts manually for testing, use the following commands from console.

###### Testing Scripts
```
/bin/bash /mnt/rpi_backup/rpibackup.sh
/bin/bash /mnt/rpi_backup/rpi-temerature.sh
/bin/bash /mnt/rpi_backup/rpi-debautoupgrade.sh >> /mnt/rpi_backup/rpiupgrade.log 2>&1 -q -f
```

###### Testing fstab mounting

```
	Manual mount test:
		sudo mount -t cifs -o credentials=/home/pi/.cifsuser, uid=pi,gid=pi, //192.168.x.x/rpibackup /mnt/rpi_backup,rw 0 0

```

## License

Free to use



