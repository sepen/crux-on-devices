# CRUX on VIA Epia PD

![this-device](https://raw.githubusercontent.com/sepen/crux-on-devices/master/via-epia-pd/this-device.jpg)


### About this device

I saved this PC from the trash at the first company I worked for.

The interesting thing is that the motherboard has 2 network interfaces, useful for making a gateway, firewall, load balancer, etc.

The last distro I used in the past it was Debian 8, which was the last version supporting VIA C3.


### Specification

* Processor: VIA C3 Nehemiah 1GHz
* Motherboard Chipset: VIA CLE266 North Bridge, VT8235 South Bridge
* Maximum memory (RAM): 1 GB DDR266 DIMM
* Graphics Processor: Integrated VIA UniChrome AGP graphics
* USB 2.0 Support included in South Bridge
* Audio: VT1612A two-channel AC'97 codec
* Dual LAN: VIA VT6105 and VT6103 PHY 
* IDE: UltraDMA 66/100/133


> NOTE for VIA C3 "Nehemiah". Since most distros treats this CPU as 586, compile option `CONFIG_MVIAC3_2`in kernel enables usage of SSE and tells gcc to treat the CPU as a 686.



## Installation

Download the last supported version available for this device.
We have to go for the i586 architecture, so then we will use `CRUX 2.7 i586` which was ported thanks to Juergen Daubert (jue).
```

$ wget http://jue.li/crux/crux-i586/crux-i586-2.7.iso
$ wget http://jue.li/crux/crux-i586/crux-i586-2.7.md5
$ md5sum -c crux-i586-2.7.md5
```

Then you need to create a bootable media (cdrom) and start the installation from it

Alternatively you can use `safe-crux` to install it on secondary partition with just one command
```
$ scx setup -t block i586-2.7 /dev/sda2
```

### Packages

Select all packages from core, opt and xorg and grub2 as the bootloader

Wait until installation finishes


### Kernel

Copy kernel sources from the iso
```
$ sudo mount -o loop var/iso/crux-i586-2.7.iso var/iso/mnt
$ sudo mount /dev/sda2 var/mnt
$ sudo cp var/iso/mnt/crux/kernel/linux-2.6.36.7* var/mnt/usr/src
$ sudo umount var/mnt /var/iso/mnt
```

Uncompress and prepare kernel sources
```
$ scx run /dev/sda2
# cd /usr/src
# tar xf linux-2.6.36.7.tar.bz2
# ln -s linux-2.6.36.7 linux
```

Copy kernel config file [config-2.6.36.7](boot/config-2.6.36.7)
```
# wget https://raw.githubusercontent/sepen/crux-on-devices/master/via-epia-pd/boot/config-2.6.36.7
# mv config-2.6.36.7 /usr/src/linux-2.6.36.7/.config
```

Build the kernel
```
# cd /usr/src/linux-2.6.36.7
# make
```

Install kernel files
```
# cd /usr/src/linux-2.6.36.7
# make modules_install
# cp arch/x86/boot/bzImage /boot/vmlinuz-2.6.36.7

# cp .config /boot/config-2.6.36.7
# cp System.map /boot/System.map-2.6.36.7
```

### Bootloader

Make symlinks using generic names so that the bootloader auto-discovers the config
```
# cd /boot
# ln -s vmlinuz-2.6.36.7 vmlinuz
# ln -s config-2.6.36.7 config
# ln -s System.map-2.6.36.7 System.map
```

Create grub config file
```
# mkdir /boot/grub 
# grub-mkconfig -o /boot/grub/grub.cfg
```

## Ports

### pkgutils

Configure pkgbuild to use right CFLAGS

[/etc/pkgmk.conf](etc/pkgmk.conf)
