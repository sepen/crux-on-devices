# CRUX on Acer Aspire One ZG5

![this-device](https://raw.githubusercontent.com/sepen/crux-on-devices/master/acer-aspire-one/this-device.jpg)


### About this device

About May 2021 I bought this device for 20 euros in the second hand market.

I upgraded it to 1.5G of RAM, the maximum capacity it allows and added a 120GB SSD disk for better performance.

Debian 10 worked fine on it but playing youtube videos is only possible at 360p resolution. while CRUX can run at 480p without framedrops.

### Specification

* Processor: Intel Atom N270 1.66 Ghz
* Motherboard Chipset: Intel 945 GM + CH7M
* Maximum memory (RAM): 1.5 GB DDR2
* Graphics Processor: Intel GMA 945GMS
* Display: TFT 16:09
* Screen size: 8.9 in
* 3 x USB 2.0
* Microphone Jack
* D-Sub
* RJ45
* Headphone Jack
* Multi-card reader
* SD slot


## Installation

Download the last supported version available for this device.
We have to go for the i686 architecture, so then we will use `CRUX 3.5 i686` which is still alive thanks to Matt Housh (jaeger).
```
$ wget https://crux.ninja/i686-iso/crux-3.5-i686.iso
$ wget https://crux.ninja/i686-iso/crux-3.5-i686.md5
$ md5sum -c crux-3.5-i686.md5
```

### Packages

Select all packages from core, opt and xorg and grub2 as the bootloader

Wait until installation finishes


### Kernel

Copy kernel sources from the iso
```
# mount -o loop crux-3.5-i686.iso /mnt
# cp /mnt/crux/kernel/linux-4.19.112.tar.xz /usr/src
```

Uncompress and prepare kernel sources
```
# cd /usr/src
# tar xf linux-4.19.112.tar.xz
# ln -s linux-4.19.112 linux
```

Copy kernel config file [config-4.19.112](boot/config-4.19.112)
```
# wget https://raw.githubusercontent/sepen/crux-on-devices/master/acer-aspire-one/boot/config-4.19.112
# mv config-4.19.112 /usr/src/linux-4.19.112/.config
```

Build the kernel
```
# cd /usr/src/linux-4.19.112
# make
```

Install kernel files
```
# cd /usr/src/linux-4.19.112
# make modules_install
# cp arch/x86/boot/bzImage /boot/vmlinuz-4.19.112
# cp .config /boot/config-4.19.112
# cp System.map /boot/System.map-4.19.112
```

### Bootloader

Make symlinks using generic names so that the bootloader auto-discovers the config
```
# cd /boot
# ln -s vmlinuz-4.19.112 vmlinuz
# ln -s config-4.19.112 config
# ln -s System.map-4.19.112 System.map
```

Create grub config file
```
# mkdir /boot/grub 
# grub-mkconfig -o /boot/grub/grub.cfg
```

## Ports

### pkgutils

Configure pkgbuild to use -j2 in CFLAGS

[/etc/pkgmk.conf](etc/pkgmk.conf)


### ports

Download and install crux-i686 overlay repository
```
$ sudo wget -P /etc/ports https://raw.githubusercontent.com/sepen/crux-i686/3.5/crux-i686.httpup
$ sudo ports -u crux-i686
```

Optionally add my repository to install some ports listed in this doc
```
$ sudo wget -P /etc/ports https://raw.githubusercontent.com/sepen/crux-ports-sepen/main/sepen.httpup
$ sudo ports -u sepen
```

### prt-get

Add crux-i686 as an overlay for all repositories.
Optionally add my repository.
[/etc/prt-get.conf](etc/prt-get.conf)


## Desktop

![screenshot](https://raw.githubusercontent.com/sepen/crux-on-devices/master/acer-aspire-one/screenshot.png)

### Xorg

Activate `tap to click` 
```
$ echo '# Activate "tap to click" on touchpad
Section "InputClass"
	Identifier "libinput touchpad catchall"
	MatchIsTouchpad "on"
	MatchDevicePath "/dev/input/event*"
	Driver "libinput"
	Option "Tapping" "on"
EndSection' | sudo tee /etc/X11/xorg.conf.d/40-libinput.conf
```

### Firefox

ALSA support was dropped starting Firefox 52.0 and later.
https://support.mozilla.org/en-US/questions/1209469

I still want to use ALSA and try to avoid pulseaudio as much as possible, so `apulse` comes to the rescue:
```
$ sudo prt-get depinst apulse
$ apulse firefox
```

### Openbox

Install `imlib2` and rebuild `openbox` to have icon support
```
$ sudo prt-get depinst imlib2
$ sudo prt-get update -fr openbox
```

Install openbox configuration manager
```
$ sudo prt-get depinst obconf
```

Install openbox themes. Then apply a theme you desire using `obconf`
```
$ git clone https://github.com/addy-dclxvi/openbox-theme-collections ~/.config/openbox/themes
$ obconf
```

Auto-start openbox when running `startx` command:
[~/.config/openbox/autostart](home/sepen/.config/openbox/autostart)

Show openbox menu when windows key is pressed,
Edit [~/.config/openbox/rc.xml](home/sepen/.config/openbox/rc.xml) and add this code block:
```
<keybind key="Super_L">
  <action name="ShowMenu">
    <menu>root-menu</menu>
  </action>
</keybind>
```

Generate openbox menu with `obmenu-generator`
```
$ sudo prt-get depinst obmenu-generator
$ obmenu-generator -i > $HOME/.config/openbox/menu.xml
```

Add a dynamic menu by copying this contents to [~/.config/openbox/menu.xml](home/sepen/.config/openbox/menu.xml)

```
<?xml version="1.0" encoding="utf-8"?>
<openbox_menu xmlns="http://openbox.org/"
 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://openbox.org/">
    <menu id="root-menu" label="obmenu-generator" execute="/usr/bin/obmenu-generator -i" />
</openbox_menu>
```

### Polybar

Install an eye candy status bar: `polybar`
```
$ sudo prt-get depinst polybar
$ cp /usr/share/polybar/config.example ~/.config/polybar/config
$ polybar -c ~/.config/polybar/config example
```
