# CRUX on RaspberryPi 3B

<img src="https://raw.githubusercontent.com/sepen/crux-on-devices/master/raspberrypi-3b/this-device.jpg" width="400" />

## Table of contents
- [About this device](#about-this-device)
- [Specifications](#specifications)
- [Installation](#installation)
- [Ports](#ports)
- [Desktop](#desktop)
- [Misc](#misc)


## About this device <a name="about-this-device"></a>

I didn't have to buy this raspberrypi, it was the prize for winning a hackathon at the company I worked for in 2017. Curiously, part of my project was with CRUX-ARM on an EfikaMX and a high-gain Wifi antenna, and I configured it as a mobile device detector, detecting wifi beacons, to count pedestrian traffic around a store. One way or another, the efikamx prepared its own replacement for the raspberrypi.


## Specifications <a name="specifications"></a>

* SoC: Broadcom BCM2837B0 Quad-Core Cortex-A53 (ARMv8) 64-bit @ 1.2GHz
* GPU: Broadcom VideoCore IV 400 MHz
* RAM: 1GB LPDDR2 SDRAM
* Networking: Fast Ethernet 10/100 Gbps
* Storage: Micro-SD
* GPIO: 40-pin GPIO header, populated
* Full size HDMI
* 3.5mm analogue audio-video jack
* 4x USB 2.0
* Camera Serial Interface (CSI)
* Display Serial Interface (DSI)


## Installation <a name="installation"></a>

To install CRUX-ARM the best option is to download the latest version optimized for this device.

### Prepare the SD card<a name="install-media"></a>

The installation consists of copying the contents of the CRUX-ARM release to an SD card, adding the necessary files to make it bootable and editing some files to configure the system.

For the SD card we will create 2 partitions, one of 100M of type vfat for the bootloader and another with the remaining space of type ext4 for the root system.
```
$ sudo fdisk -l /dev/sdb
Disk /dev/sdb: 59,49 GiB, 63864569856 bytes, 124735488 sectors
Disk model: SD/MMC/MS PRO   
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x00000000

Device     Boot  Start       End   Sectors  Size Id Type
/dev/sdb1  *      2048    206847    204800  100M  b W95 FAT32
/dev/sdb2       206848 124735487 124528640 59,4G 83 Linux
```
```
$ sudo mkfs.vfat -F 32 /dev/sdb1
$ sudo mkfs.ext4 /dev/sdb2
```

### Install bootloader

Download and copy bootloader files to first partition on the SD card
```
$ curl -O https://resources.crux-arm.nu/files/devices/raspberrypi3/boot.tar.xz
$ curl -O https://resources.crux-arm.nu/files/distfiles/raspberrypi3/kernel8.img
```
```
$ sudo mount /dev/sdb1 /mnt
$ sudo tar -C /mnt -xvf boot.tar.xz
$ sudo cp kernel8.img /mnt/boot
$ sudo umount /mnt
```

Configure `config.txt`.

Instead of the BIOS found on a conventional PC, Raspberry Pi devices use a configuration file called config.txt. The GPU reads config.txt before the Arm CPU and Linux initialise. Raspberry Pi OS looks for this file in the boot partition, located at /boot/firmware/.
https://www.raspberrypi.com/documentation/computers/config_txt.html
```
$ sudo vim /boot/config.txt
```

### Install rootfs and kernel modules
```
$ curl -O https://master.dl.sourceforge.net/project/crux-arm/releases/3.7/crux-arm-3.7-aarch64-RC1-raspberrypi3.rootfs.tar.xz
$ curl -O https://resources.crux-arm.nu/files/distfiles/raspberrypi3/4.19.79-v8%2B-modules.tar.xz

```
```
$ sudo mount /dev/sdb2 /mnt
$ sudo tar -C /mnt -xvf crux-arm-rootfs-3.6-aarch64-rpi3.tar.xz
$ sudo tar -C /mnt/lib/modules -xvf 4.19.79-v8%2B-modules.tar.xz
$ sudo umount /mnt
```

### Add swap file

This is optional and necessary if the rpi will later be used to compile ports such as gcc or glibc that require large amounts of ram, since the rpi3 only has 1GB and it is insufficient.
```
$ sudo dd if=/dev/zero of=/var/swap bs=1M count=8192
$ sudo mkswap /var/swap
$ sudo swapon /var/swap
```
```
$ diff -purN /etc/fstab~ /etc/fstab
--- /etc/fstab~	2022-10-28 20:39:48.000000000 +0200
+++ /etc/fstab	2024-11-16 11:54:36.445998783 +0100
@@ -8,6 +8,7 @@
 #/dev/#XFS_ROOT#       /         xfs       defaults                         0      0
 #/dev/#F2FS_ROOT#      /         f2fs      defaults                         0      0
 #/dev/#SWAP#           swap      swap      defaults                         0      0
+/var/swap              swap      swap      defaults                         0      0
 #/dev/#EXT4FS_HOME#    /home     ext4      defaults                         0      2
 #/dev/#BTRFS_HOME#     /home     btrfs     defaults                         0      0
 #/dev/#XFS_HOME#       /home     xfs       defaults                         0      0
```
```
$ sudo swapon /var/swap
```


## Ports<a name="ports"></a>

Download and install `raspberrypi3b-arm64` repository overlay
```
$ sudo wget -P /etc/ports https://raw.githubusercontent.com/sepen/crux-ports-raspberrypi3b-arm64/3.7/raspberrypi3b-arm64.httpup
$ sudo ports -u raspberrypi3b-arm64
```

I add also my repository to install some ports listed in this doc
```
$ sudo wget -P /etc/ports https://raw.githubusercontent.com/sepen/crux-ports-sepen/main/sepen.httpup
$ sudo ports -u sepen
```

### pkgutils

To configure CFLAGS on ARM devices
```
$ curl -O https://gist.githubusercontent.com/sepen/4ae1d5e2f7782ba2848ef5806772c7db/raw/044dc807a5719bbe1b8989ed906e7ba11a2a5de9/arminfo.sh
$ chmod +x arminfo.sh
$ ./arminfo.sh
HOSTNAME   rpi3b
MODEL      unknown
FEATURES   fp asimd evtstrm crc32
MACHTYPE   aarch64-unknown-linux-gnu
CFLAGS     -march=armv8-a+crc -mabi=lp64 -mtune=cortex-a53
MAKEFLAGS  -j4
```

Use this information to update [/etc/pkgmk.conf](etc/pkgmk.conf)


## Desktop<a name="desktop"></a>

Install some xorg packages and xterm
```
$ sudo prt-get depinst xorg-xinit xorg-xrandr xkeyboard-config xorg-xauth
$ sudo prt-get depinst xorg-xf86-input-evdev xorg-xf86-video-fbdev xterm
```

Install some nice to have packages
```
sudo prt-get depinst xorg-xdriinfo glu
```

## Misc<a name="misc"></a>

### gpu

Reference: https://forums.raspberrypi.com/viewtopic.php?t=223592

Add this line to `/boot/config.txt`
```
dtoverlay=vc4-fkms-v3d
```

Load kernel VideoCoder IV module
```
$ sudo modprobe vc4
```
