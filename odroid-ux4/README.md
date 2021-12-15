## CRUX on Odroid XU4

## About this device

TODO

### Specification

* Samsung Exynos 5422 Cortex™-A15 2Ghz and Cortex™-A7 Octa-core CPUs
* Mali-T628 MP6 (OpenGL ES 3.0/2.0/1.1 and OpenCL 1.1 Full profile)
* 2GB LPDDR3 RAM
* eMMC5.0 HS400 Flash Storage
* 2x USB 3.0 Host, 1x USB 2.0 Host
* Gigabit Ethernet
* HDMI 1.4a


### Installation

NOTE: I use an SD card instead the eMMC to install CRUX-ARM. I prefer to keep the eMMC with the original OS Linux provided by the manufacturer. I considered to buy a bigger eMMC (>32G) but for now it is fine to use an SD card since I will use a 32G Sandisk Extreme PRO which has an acceptable performance.

Flash the eMMC with the original image by hardkernel. This system will be used to build CRUX on the SD card.
```
$ sudo dd if=ubuntu-18.04.3-4.14-minimal-odroid-xu4-20190910.img of=/dev/sda bs=1M conv=fsync
2662+0 records in
2662+0 records out
2791309312 bytes (2,8 GB, 2,6 GiB) copied, 744,577 s, 3,7 MB/s
```

Attach the eMMC to the device.
Switch the boot mode to eMMC.
Connect an HDMI monitor and a keyboard to login via tty.
Connect network cable if you want to login via ssh (user/pass: root/odroid)


Login to odroid shell where we will prepare the SD card for CRUX-ARM.


Prepare partitions on the SD card
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

Install CRUX-ARM to rootfs
root@odroid:~# safe-crux/safe-crux run /dev/mmcblk1p2
```
root@odroid:~# wget https://resources.crux-arm.nu/releases/3.6/crux-arm-rootfs-3.6-odroidxu4.tar.xz
root@odroid:~# wget https://resources.crux-arm.nu/releases/3.6/crux-arm-rootfs-3.6-odroidxu4.tar.xz.md5
root@odroid:~# md5sum -c crux-arm-rootfs-3.6-odroidxu4.tar.xz.md5
root@odroid:~# mount /dev/mmcblk1p2 /mnt
root@odroid:~# sudo tar xf crux-arm-rootfs-3.6-odroidxu4.tar.xz -C /mnt
root@odroid:~# sudo umount /mnt
```

I use `safe-crux` to test the rootfs, setup a root password and configure some files
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

Time to make the bootloader stuff
Checkout U-boot source tree from Hardkernel's Github, compile u-boot image and install to SD card
Reference: https://wiki.odroid.com/old_product/odroid-xu3/software/building_u-boot
```
root@odroid:~# git clone https://github.com/hardkernel/u-boot.git -b odroidxu4-v2017.05
root@odroid:~# cd u-boot
root@odroid:~/u-boot# make odroid-xu4_defconfig
root@odroid:~/u-boot# cd sd_fuse
root@odroid:~/u-boot/sd_fuse# ./sd_fusing.sh /dev/mmcblk1
root@odroid:~/u-boot/sd_fuse# cd ~
```

Compile kernel stuff. Mount boot and root partitions and copy files to them
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
```

