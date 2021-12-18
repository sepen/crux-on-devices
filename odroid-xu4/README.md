# CRUX on Odroid XU4

![this-device](https://raw.githubusercontent.com/sepen/crux-on-devices/master/odroid-xu4/this-device.jpg)


### About this device

This device was a donation from ReversoLabs to CRUX-ARM and since then my friend Victor Martinez (pitillo) has been doing a
very good job supporting and building optimized releases for this device.

As a curiosity, we received 2 units and we had to pay in taxes almost the value of the device itself.
The package came with a charger and an 8GB eMMC card with Ubuntu pre-installed.

This was a very powerful device for year 2015 and even today it is still a good device.
It can be used as a server, although its best use would be as a desktop, given the
graphics chip that it brings. The biggest lack would be not having a wifi device, so
we will have to use a usb one and have kernel support for it.

### Specification

* Samsung Exynos 5422 Cortex™-A15 2Ghz and Cortex™-A7 Octa-core CPUs
* Mali-T628 MP6 (OpenGL ES 3.0/2.0/1.1 and OpenCL 1.1 Full profile)
* 2GB LPDDR3 RAM
* eMMC5.0 HS400 Flash Storage
* 2x USB 3.0 Host, 1x USB 2.0 Host
* Gigabit Ethernet
* HDMI 1.4a


## Installation

In my case I will use the original eMMC as a rescue media so I prepared a fresh installation on it:
```
$ wget https://odroid.in/ubuntu_18.04lts/XU3_XU4_MC1_HC1_HC2/ubuntu-18.04.3-4.14-minimal-odroid-xu4-20190910.img.xz
$ wget https://odroid.in/ubuntu_18.04lts/XU3_XU4_MC1_HC1_HC2/ubuntu-18.04.3-4.14-minimal-odroid-xu4-20190910.img.md5sum
$ unxz ubuntu-18.04.3-4.14-minimal-odroid-xu4-20190910.img.xz
$ md5sum -c ubuntu-18.04.3-4.14-minimal-odroid-xu4-20190910.img.md5sum
$ sudo dd if=ubuntu-18.04.3-4.14-minimal-odroid-xu4-20190910.img of=/dev/sda bs=1M conv=fsync
2662+0 records in
2662+0 records out
2791309312 bytes (2,8 GB, 2,6 GiB) copied, 744,577 s, 3,7 MB/s
```
FILTER_BRANCH_SQUELCH_WARNING=1
WARNING: git-filter-branch has a glut of gotchas generating mangled history
         rewrites.  Hit Ctrl-C before proceeding to abort, then use an
         alternative filtering tool such as 'git filter-repo'
         (https://github.com/newren/git-filter-repo/) instead.  See the
         filter-branch manual page for more details; to squelch this warning,
         set FILTER_BRANCH_SQUELCH_WARNING=1.


### Native installation on SD card

This installation method is about creating the SD card from the device itself, using the eMMC.
It is summarized in the following steps:
1. Boot from eMMC with Ubuntu and network support
2. Insert the SD card and create the partitions: boot and rootfs
3. Download the CRUX-ARM release and install on the rootfs partition
4. Download and compile the kernel natively and installl on the boot partition
5. Download and compile the bootloader files natively and installl on the boot partition


#### 1. Boot from eMMC 

Prepare everything to boot the device from eMMC card
* Attach the eMMC to the device.
* Switch the boot mode to eMMC.
* Connect network cable to login via ssh (user/pass: root/odroid)
* (optional) Connect an HDMI monitor and a keyboard to login via tty.

Connect via SSH to the device and get a shell.

#### 2. Create SD partitions

Insert the SD card and create partitions on it:
```
root@odroid:~# lsblk 
NAME         MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
mmcblk0      179:0    0  7.3G  0 disk 
├─mmcblk0p1  179:1    0  128M  0 part /media/boot
└─mmcblk0p2  179:2    0  7.2G  0 part /
mmcblk0boot0 179:16   0    4M  1 disk 
mmcblk0boot1 179:32   0    4M  1 disk 
mmcblk0rpmb  179:48   0    4M  0 disk 
mmcblk1      179:64   0 29.7G  0 disk 
```

We need to create a *dos* partition table with 2 partitions like this:
```
root@odroid:~# fdisk -l /dev/mmcblk1
Disk /dev/mmcblk1: 29.7 GiB, 31914983424 bytes, 62333952 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x8e386dae

Device         Boot  Start      End  Sectors  Size Id Type
/dev/mmcblk1p1        2048   264191   262144  128M  b W95 FAT32
/dev/mmcblk1p2      264192 62333951 62069760 29.6G 83 Linux
```

Format partitions
```
root@odroid:~# apt-get update && apt-get install -y dosfsutils
root@odroid:~# mkfs.vfat -n bootfs /dev/mmcblk1p1
root@odroid:~# mkfs.ext4 -n rootfs /dev/mmcblk1p2
```

#### 3. Install CRUX-ARM optimized release 

Install the optimized release for Odroid XU4
```
root@odroid:~# wget https://resources.crux-arm.nu/releases/3.6/crux-arm-rootfs-3.6-odroidxu4.tar.xz
root@odroid:~# wget https://resources.crux-arm.nu/releases/3.6/crux-arm-rootfs-3.6-odroidxu4.tar.xz.md5
root@odroid:~# md5sum -c crux-arm-rootfs-3.6-odroidxu4.tar.xz.md5
root@odroid:~# mount /dev/mmcblk1p2 /mnt
root@odroid:~# sudo tar xf crux-arm-rootfs-3.6-odroidxu4.tar.xz -C /mnt
root@odroid:~# sudo umount /mnt
```

Test the installation, setup a root password and configure some important files.
I recommend here to use `safe-crux` for making it easier and faster to deal with chroot.
```
root@odroid:~# apt-get install -y git 
root@odroid:~# git clone https://github.com/sepen/safe-crux
root@odroid:~# safe-crux/safe-crux run /dev/mmcblk1p2
bash-5.1# crux
CRUX-ARM version 3.6
bash-5.1# passwd
New password: 
Retype new password: 
passwd: password updated successfully
bash-5.1# vim /etc/fstab
bash-5.1# vim /etc/rc.conf
bash-5.1# vim /etc/rc.d/net
bash-5.1# exit
```

#### 4. Build and install the kernel

Mount boot and root partitions and copy files to them.

Reference: https://wiki.odroid.com/odroid-xu4/software/building_kernel
```
root@odroid:~# apt-get install -y gcc g++ build-essential libssl-dev bc libncurses5-dev
root@odroid:~# git clone --depth 1 https://github.com/hardkernel/linux -b odroidxu4-4.14.y
root@odroid:~# cd linux
root@odroid:~/linux# make mrproper
root@odroid:~/linux# make odroidxu4_defconfig
root@odroid:~/linux# make menuconfig # I disabled sha512-arm and sha256-arm otherwise won't compile
root@odroid:~/linux# make -j7 # I don't use -j8 because it hangs the system
root@odroid:~/linux# mount /dev/mmcblk1p2 /mnt
root@odroid:~/linux# mount /dev/mmcblk1p1 /mnt/boot
root@odroid:~/linux# make modules_install INSTALL_MOD_PATH=/mnt
root@odroid:~/linux# cp arch/arm/boot/zImage /mnt/boot
root@odroid:~/linux# cp arch/arm/boot/dts/exynos5422-odroidxu4.dtb /mnt/boot
root@odroid:~/linux# cp .config /mnt/boot/config-`make kernelrelease`
root@odroid:~/linux# umount /mnt/boot
root@odroid:~/linux# umount /mnt
root@odroid:~/linux# sync
root@odroid:~/linux# cd ~
```

#### 5. Build and install the bootloader stuff

Checkout `u-boot` source tree from Hardkernel's, compile u-boot image and install to SD card.

Reference: https://wiki.odroid.com/old_product/odroid-xu3/software/building_u-boot
```
root@odroid:~# git clone https://github.com/hardkernel/u-boot.git -b odroidxu4-v2017.05
root@odroid:~# cd u-boot
root@odroid:~/u-boot# make odroid-xu4_defconfig
root@odroid:~/u-boot# cd sd_fuse
root@odroid:~/u-boot/sd_fuse# ./sd_fusing.sh /dev/mmcblk1
root@odroid:~/u-boot/sd_fuse# cd ~
```


## CPU frequency governor

List available scaling governors for each CPU core
```
$ ls /sys/devices/system/cpu/cpufreq
policy0/  policy1/  policy2/  policy3/  policy4/  policy5/  policy6/  policy7/

$ cat /sys/devices/system/cpu/cpufreq/policy{0..7}/scaling_available_governors
ondemand performance powersave
ondemand performance powersave
ondemand performance powersave
ondemand performance powersave
ondemand performance powersave
ondemand performance powersave
ondemand performance powersave
ondemand performance powersave
```

Setup for example `ondemand` governor for all CPU cores
```
$ for core in {0..7}; do echo 'ondemand' | sudo tee  /sys/devices/system/cpu/cpufreq/policy${core}/scaling_governor
```