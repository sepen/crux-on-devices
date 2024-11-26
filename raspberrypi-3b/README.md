# CRUX on RaspberryPi 3B+

![this-device](https://raw.githubusercontent.com/sepen/crux-on-devices/master/raspberrypi-3b/this-device.jpg)


### About this device

In 2017 I won this raspberry at the first hackathon of the company I was working for. It was my first 64-bit ARM device.


### Specification

* SoC: Broadcom BCM2837B0 quad-core A53 (ARMv8) 64-bit @ 1.4GHz
* GPU: Broadcom Videocore-IV
* RAM: 1GB LPDDR2 SDRAM
* Networking: Gigabit Ethernet (via USB channel), 2.4GHz and 5GHz 802.11b/g/n/ac Wi-Fi
* Bluetooth: Bluetooth 4.2, Bluetooth Low Energy (BLE)
* Storage: Micro-SD
* GPIO: 40-pin GPIO header, populated
* Full size HDMI
* 3.5mm analogue audio-video jack
* 4x USB 2.0
* 100 Base Ethernet
* Camera Serial Interface (CSI)
* Display Serial Interface (DSI)


## Installation

Install the optimized release for RaspberryPi 3 (Aarch64)

Download required files.
```
$ wget https://master.dl.sourceforge.net/project/crux-arm/releases/3.7/crux-arm-3.7-aarch64-RC1-raspberrypi3.rootfs.tar.xz
$ wget https://resources.crux-arm.nu/files/devices/raspberrypi3/boot.tar.xz
$ wget https://resources.crux-arm.nu/files/distfiles/raspberrypi3/4.19.79-v8%2B-modules.tar.xz
$ wget https://resources.crux-arm.nu/files/distfiles/raspberrypi3/kernel8.img
```

Prepare the SD card
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
Install all files to SD card
```
$ sudo mount /dev/sdb1 /mnt
$ sudo tar -C /mnt -xvf boot.tar.xz
$ sudo cp kernel8.img /mnt/boot
$ sudo umount /mnt
```
```
$ sudo mount /dev/sdb2 /mnt
$ sudo tar -C /mnt -xvf crux-arm-rootfs-3.6-aarch64-rpi3.tar.xz
$ sudo tar -C /mnt/lib/modules -xvf 4.19.79-v8%2B-modules.tar.xz
$ sudo umount /mnt
```

Add swap file
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
