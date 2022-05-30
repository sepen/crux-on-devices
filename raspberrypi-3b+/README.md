# CRUX on RaspberryPi 3B+

![this-device](https://raw.githubusercontent.com/sepen/crux-on-devices/master/raspberrypi-3b+/this-device.jpg)


### About this device

TODO


### Specification

* SoC: Broadcom BCM2837B0 quad-core A53 (ARMv8) 64-bit @ 1.4GHz
* GPU: Broadcom Videocore-IV
* RAM: 1GB LPDDR2 SDRAM
* Networking: Gigabit Ethernet (via USB channel), 2.4GHz and 5GHz 802.11b/g/n/ac Wi-Fi
* Bluetooth: Bluetooth 4.2, Bluetooth Low Energy (BLE)
* Storage: Micro-SD
* GPIO: 40-pin GPIO header, populated
* Ports: HDMI, 3.5mm analogue audio-video jack, 4x USB 2.0, Ethernet, Camera Serial Interface (CSI), Display Serial Interface (DSI)


## Installation

Install the optimized release for RaspberryPi 3 (Aarch64)

Download required files
```
# wget https://resources.crux-arm.nu/releases/3.6/crux-arm-rootfs-3.6-aarch64-rpi3.tar.xz
# wget https://resources.crux-arm.nu/releases/3.6/crux-arm-rootfs-3.6-aarch64-rpi3.tar.xz.md5
# wget https://resources.crux-arm.nu/files/devices/raspberrypi3/boot.tar.xz
# wget https://resources.crux-arm.nu/files/distfiles/raspberrypi3/4.19.79-v8%2B-modules.tar.xz
# wget https://resources.crux-arm.nu/files/distfiles/raspberrypi3/kernel8.img 
# md5sum -c crux-arm-rootfs-3.6-aarch64-rpi3.tar.xz.md5
```
Create the installation media
```
# fdisk -l /dev/sdb
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
# mkfs.vfat -F 32 /dev/sdb1
# mount /dev/sdb1 /mnt
# tar -C /mnt -xvf boot.tar.xz
# umount /mnt
# mkfs.ext4 /dev/sdb2
# mount /dev/sdb2 /mnt
# tar -C /mnt -xvf crux-arm-rootfs-3.6-aarch64-rpi3.tar.xz
# tar -C /mnt/lib/modules -xvf 4.19.79-v8%2B-modules.tar.xz
# umount /mnt
```

