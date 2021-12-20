# CRUX on Airis Kira N7000

![this-device](https://raw.githubusercontent.com/sepen/crux-on-devices/master/airis-kira-n7000/this-device.jpg)


### About this device

I bought this device for 5€ in the second hand marketplace.
It comes with an ancient version of Android pre-installed which didn't work. I upgraded the firmware and it worked fine.

This netbook was a gift from a newspaper, so there is hardly any documentation out there, and for this reason, to
install CRUX-ARM I will use another distro for the boot files and then customize the installation as well as compile
my own kernel.

### Specification

* Processor VIA C7-M
* Bios 1MB Flash ROM
* Chipset VIA VX800U
* Main Memory DDR2 256MB/512MB/1GB (depends on model)
* LCD Display 7” TFT LCD
* Graphics Embedded. Display Mode 800x480
* Modem 56Kbps, V.90/92 support
* LAN & WLAN Built-in Ethernet
* Interface I/O Ports
  * Line out
  * Mic in
  * DC in
  * RJ-11 connector for modem
  * RJ-45 connector for Ethernet
  * 2 USB ports
  * VGA out
* Audio Internal stereo speakers
* Internal mono microphone
* Card Reader 3-in-1: SD/MMC/ MS
* Built-in Touch Pad with 2-way scroll function

## Installation

I need a kernel and the bootloader stuff so I will use Kirbian project as a base to create a custom SD card (>=2GB)
```
$ wget https://phoenixnap.dl.sourceforge.net/project/kirbian/Linux/kirbian_18.1_armhf_minimal.7z
$ 7z x kirbian_18.1_armhf_minimal.7z
$ sudo dd if=kirbian_18.2_armhf_minimal.img of=/dev/sda bs=1M conv=fsync
```

The SD card will contain two partitions:
```
$ sudo fdisk -l /dev/sda
Disk /dev/sda: 7,22 GiB, 7744782336 bytes, 15126528 sectors
Disk model: SD/MMC/MS PRO
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x000ddf56

Device     Boot Start     End Sectors  Size Id Type
/dev/sda1       16065   57024   40960   20M  4 FAT16 <32M
/dev/sda2       64260 3839534 3775275  1,8G 83 Linux
```

Mount root partition to inspect contents and copy some files:
```
$ sudo mount /dev/sda2 /mnt
$ mkdir kirbian-files
$ cp -a /mnt/etc/securetty kirbian-files
$ cp -a /mnt/lib/firmware kirbian-files
$ cp -a /mnt/lib/modules/2.6.32.9 kirbian-files
$ cp -a /mnt/boot/config-2.6.32.9 kirbian-files
$ sudo umount /mnt
```

Delete the second partition and resize it to whole available space. I will use this partition later for CRUX-ARM.
New partition table look like this:
```
$ sudo fdisk -l /dev/sda
Disk /dev/sda: 7,22 GiB, 7744782336 bytes, 15126528 sectors
Disk model: SD/MMC/MS PRO
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x000ddf56

Device     Boot Start      End  Sectors  Size Id Type
/dev/sda1       16065    57024    40960   20M  4 FAT16 <32M
/dev/sda2       64260 15126527 15062268  7,2G 83 Linux
```

Format root partition with ext2 or ext3 since ext4 is not supported by the kernel I will use
```
$ sudo mkfs.ext3 /dev/sda2
```

Since kernel version 2.6.32 I will use CRUX-ARM 3.2 which is the last one with glibc support for this kernel version.
```
$ wget https://resources.crux-arm.nu/releases/3.2/crux-arm-rootfs-3.2.tar.xz
$ wget https://resources.crux-arm.nu/releases/3.2/crux-arm-rootfs-3.2.tar.xz.md5
$ md5sum -c crux-arm-rootfs-3.2.tar.xz.md5
```

Uncompress CRUX-ARM 3.2 to root partition on SD card
```
$ sudo mount /dev/sda2 /mnt
$ sudo tar -C /mnt -xf crux-arm-rootfs-3.2.tar.xz
```

Copy files from backup we made to root partition on SD card.
Also edit some important files and umount the partition.
```
$ sudo cp kirbian-files/securetty /mnt/etc
$ sudo cp -a kirbian-files/firmware/* /mnt/lib/firmware
$ sudo cp -a kirbian-files/2.6.32.9 /mnt/lib/modules
$ sudo chown -R root:root /mnt/etc/securetty /mnt/lib/{firmware,modules}
$ sudo vim /mnt/etc/fstab
$ sudo vim /mnt/etc/rc.conf
$ sudo vim /mnt/etc/rc.d/net
```

Finally we need to do some tricks. Since we are using a third-party kernel.

The kernel lacks support for devtmpfs (CONFIG_DEVTMPFS=y) so I need a trick to run udev.
* Replace `/sbin/start_udev` with this file: [start_udev](https://raw.githubusercontent.com/sepen/crux-on-devices/master/airis-kira-n7000/sbin/start_udev)
* Download and copy these udev rules to `/etc/udev/rules.d`:
  * [40-scratch.rules](https://raw.githubusercontent.com/sepen/crux-on-devices/master/airis-kira-n7000/etc/udev/rules.d/40-scratch.rules)
  * [70-persistent-net.rules](https://raw.githubusercontent.com/sepen/crux-on-devices/master/airis-kira-n7000/etc/udev/rules.d/70-persistent-net.rules)
  * [99-input.rules](https://raw.githubusercontent.com/sepen/crux-on-devices/master/airis-kira-n7000/etc/udev/rules.d/99-input.rules)


Umount the root partition and the SD card is now ready!
```
$ sudo umount /mnt
```


## Troubleshoting

I have tried to get CRUX-ARM 3.6 running on this device and failed.
I have also tried 3.5, 3.4 and 3.2 but the problem was the same: `FATAL: kernel too old`
```
# wget https://resources.crux-arm.nu/releases/3.6/crux-arm-rootfs-3.6.tar.xz
# wget https://resources.crux-arm.nu/releases/3.6/crux-arm-rootfs-3.6.tar.xz.md5
# md5sum -c crux-arm-rootfs-3.6.tar.xz.md5
# mkdir /crux-3.6
# tar -C /crux-3.6 -xf crux-arm-rootfs-3.6.tar.xz
# mount --bind /dev /crux-3.6/dev
# mount --bind /proc /crux-3.6/proc
# mount -t sysfs sysfs /crux-3.6/sys
# chroot /crux-3.6
FATAL: kernel too old
```

Unfortunatelly a newer kernel can't be built for this device. I forked a branch
create from some guys from InfoTM for IMAPX200 based devices but even that is
prepared for crosscompilation and requires some work for being used today.

On the other hand, Glibc >= 2.24 requires a kernel 3.2.x which makes more difficult
to run a decent CRUX-ARM version on this device.

My solution to keep alive this device is to use CRUX-ARM 3.2 + my own port overlay
where contribute recent ports whenever be possible.


## Wireless Networking

Since 3.2 is a bit old we will need to fix some packages to get wireless networking

First we should fix the source url for wireless-tools:
```
# diff -purN /usr/ports/opt/wireless-tools/Pkgfile Pkgfile                           
--- /usr/ports/opt/wireless-tools/Pkgfile	2010-09-22 02:03:27.000000000 +0200
+++ Pkgfile	2021-12-19 17:59:19.000000000 +0100
@@ -7,7 +7,7 @@
 name=wireless-tools
 version=29
 release=2
-source=(http://www.labs.hpe.com/personal/Jean_Tourrilhes/Linux/${name/-/_}.$version.tar.gz)
+source=(https://hewlettpackard.github.io/wireless-tools/wireless_tools.$version.tar.gz)
 
 build() {
 	cd ${name/-/_}.$version
```

To get wpa_supplicant working we also need to fix sources for expat dependency. In this case
version 2.2.0 is no longer downloadable from any place as it was marked as vulnerable release.
The original file in sourceforge was renamed to expat-2.2.0-RENAMED-VULNERABLE-PLEASE-USE-2.3.0-INSTEAD. It was uploaded on 2021-03-25.
2.3.0 was also marked as vulnerable: https://sourceforge.net/projects/expat/files/expat/2.3.0/expat-2.3.0-RENAMED-VULNERABLE-PLEASE-USE-2.4.1-INSTEAD.tar.gz/download


Source url for wpa_supplicant also changed to: https://w1.fi/releases/wpa_supplicant-2.6.tar.gz

