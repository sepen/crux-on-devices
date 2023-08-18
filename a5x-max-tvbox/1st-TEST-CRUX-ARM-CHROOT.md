Connect via ssh to the device and follow these steps:

Download CRUX-ARM for aarch64 generic devices
```
LibreELEC:~ # wget 'https://master.dl.sourceforge.net/project/crux-arm/releases/3.7/crux-arm-3.7-aarch64-rc5.rootfs.tar.xz'
Connecting to master.dl.sourceforge.net (216.105.38.12:443)
Connecting to downloads.sourceforge.net (204.68.111.105:443)
Connecting to master.dl.sourceforge.net (216.105.38.12:443)
saving to 'crux-arm-3.7-aarch64-rc5.rootfs.tar.xz'
crux-arm-3.7-aarch64 100% |************************************************************************************|  156M  0:00:00 ETA
'crux-arm-3.7-aarch64-rc5.rootfs.tar.xz' saved
```

Prepare the directory for installation
```
LibreELEC:~ # mkdir /storage/crux-arm
LibreELEC:~ # tar -C /storage/crux-arm -xf crux-arm-3.7-aarch64-rc5.rootfs.tar.xz
```

Chroot into it
```
LibreELEC:~ # mount --bind /dev /storage/crux-arm/dev
LibreELEC:~ # mount --bind /sys /storage/crux-arm/sys
LibreELEC:~ # mount --bind /run /storage/crux-arm/run
LibreELEC:~ # mount --bind /proc /storage/crux-arm/proc
LibreELEC:~ # chroot /storage/crux-arm /bin/bash --login
# crux
CRUX-ARM 64b version 3.7
```
