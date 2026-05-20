# CRUX on iMac 20" (A1224 / iMac8,1)

<img src="this-device.png" width="400" />


### About this device

In May 2022 I bought this machine on the second-hand market for 45 euros. It came with a common fault on these models: nothing on screen. When the iMac sits upright for years, the original GPU tends to desolder; reballing fixes it for a while but the problem often returns.

I replaced the graphics card with an **ATI Radeon HD 2600** with 256 MB of RAM (about 25 euros) and it worked straight away. I also swapped the original disk for a **500 GB SSD** and maxed out the RAM at **4 GB SODIMM**.

The native option is **macOS El Capitan** — performance is still acceptable, but much of the stack is obsolete and no longer updated, so it was time to try **CRUX**. The machine now **dual-boots macOS and CRUX 3.8**.


### Specification

iMac 20" (Early 2008, model A1224 / iMac8,1 — EMC 2133 / 2210)

* **Processor:** Intel Core 2 Duo E8335 @ 2.66 GHz (2 cores, 2 threads), 6 MB L3
* **Chipset:** Intel Mobile PM965/GM965 (ICH8M)
* **Memory:** 4 GB DDR2 SO-DIMM
* **Graphics:** AMD/ATI Mobility Radeon HD 2600 XT/2700 (RV630), 256 MB (`radeon`)
* **Display:** Built-in 20" LCD, 1680×1050 @ 60 Hz
* **Storage:** Samsung SSD 860 500 GB (SATA AHCI, `ahci`)
* **Optical:** 8× SuperDrive (DVD±RW DL)
* **Ethernet:** Marvell 88E8058 Gigabit (`sky2`)
* **Wi-Fi:** Broadcom BCM4321 (`b43-pci-bridge` / `ssb`)
* **Audio:** Intel HD Audio ICH8 (`snd_hda_intel`)
* **FireWire:** LSI FW643 1394b (`firewire_ohci`)
* **USB:** Intel ICH8 UHCI/EHCI (`uhci_hcd`, `ehci-pci`)
* **Bluetooth:** 2.1 + EDR
* **Ports:** 3× USB 2.0, FW400, FW800, Mini-DVI, audio I/O
* **Power:** 180 W internal PSU
* **macOS support:** 10.5 Leopard → 10.11 El Capitan


## Installation

After proper partitioning, the installation was started from a USB drive with the CRUX 3.8 image, installing all the packages from the core collection and some from opt to enable Wi-Fi (wireless-tools, wpa_supplicant, ...) and EFI boot (grub2-efi, efivar, efibootmgr, ...). Dual-boot layout keeping macOS El Capitan and CRUX 3.8:

Partitions:
```shell
$ sudo fdisk -l
Disk /dev/sda: 465.76 GiB, 500107862016 bytes, 976773168 sectors
Disk model: Samsung SSD 860
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: gpt
Disk identifier: A3EA75C9-F760-43B2-8198-B2C40997FA4B

Device         Start       End   Sectors   Size Type
/dev/sda1       2048   1050623   1048576   512M EFI System
/dev/sda2    1050624 314353887 313303264 149.4G Apple HFS/HFS+
/dev/sda3  314353888 315623423   1269536 619.9M Apple boot
/dev/sda4  315623424 944769023 629145600   300G Linux filesystem
/dev/sda5  944769024 976773119  32004096  15.3G Linux swap
```


### Packages

Select all packages from core, opt and xorg and grub2 as the bootloader

Wait until installation finishes


### Kernel

Uncompress and prepare kernel sources
```
# cd /usr/src
# tar xf linux-6.12.23.tar.xz
# ln -s linux-6.12.23 linux
```

Copy kernel config file [config-6.12.23](boot/config-6.12.23)
```
# wget https://raw.githubusercontent.com/sepen/crux-on-devices/master/imac20/boot/config-6.12.23
# mv config-6.12.23 /usr/src/linux-6.12.23/.config
```

Build the kernel
```
# cd /usr/src/linux-6.12.23
# make
```

Install kernel files
```
# cd /usr/src/linux-6.12.23
# make modules_install
# cp arch/x86_64/boot/bzImage /boot/vmlinuz-6.12.23
# cp .config /boot/config-6.12.23
# cp System.map /boot/System.map-6.12.23
```

### Bootloader

Make symlinks using generic names so that the bootloader auto-discovers the config
```
# cd /boot
# ln -s vmlinuz-6.12.23 vmlinuz
# ln -s config-6.12.23 config
# ln -s System.map-6.12.23 System.map
```

Create grub config file and install the bootloader
```
# mkdir /boot/grub 
# grub-mkconfig -o /boot/grub/grub.cfg
# grub-install
```


## Sensors (applesmc)

Temperature sensors and fan control on this iMac go through the **`applesmc`** driver. Enable it in the kernel (`Device Drivers` → `Hardware Monitoring support` → `Apple SMC`):

* built-in: `CONFIG_SENSORS_APPLESMC=y` (as in [config-6.12.23](boot/config-6.12.23))
* or as a module: `CONFIG_SENSORS_APPLESMC=m`, then load it:

```shell
$ sudo modprobe applesmc
```

Check that the option is enabled in the running kernel:

```shell
$ zgrep -i applesmc /proc/config.gz
CONFIG_SENSORS_APPLESMC=y
```

When the driver is active, sysfs exposes fans and temperatures under a path like `/sys/devices/platform/applesmc.768/` (the number after `applesmc` may differ):

```shell
$ ls /sys/devices/platform/applesmc.768/
```

Useful files include `temp*_input` / `temp*_label` for sensors and `fan*_input`, `fan*_min`, `fan*_max`, `fan*_manual` for each fan.

**Raise minimum fan speed** (example: fan 1, default min 1000 RPM → 2500 RPM for extra GPU cooling):

```shell
$ cat /sys/devices/platform/applesmc.768/fan1_min
1000
$ echo 2500 | sudo tee /sys/devices/platform/applesmc.768/fan1_min
```

Values are in RPM. Stay within `fan*_min` / `fan*_max`; changes via sysfs are lost on reboot unless scripted (e.g. `rc.local` or a small oneshot service).

### lm_sensors

For monitoring, install the **`lm_sensors`** port. The kernel must also provide:

* `CONFIG_HWMON=y` (or `=m`) — hardware monitoring framework
* `CONFIG_I2C_CHARDEV=y` (or `=m`) — `/dev/i2c-*` character devices for sensor detection

Verify on a running system:

```shell
$ zgrep -E 'CONFIG_HWMON=|CONFIG_I2C_CHARDEV=' /proc/config.gz
```

[config-6.12.23](boot/config-6.12.23) ships with `CONFIG_HWMON=y`; enable `CONFIG_I2C_CHARDEV` if you rebuild the kernel before relying on `sensors-detect`.

```shell
$ sudo prt-get depinst lm_sensors
$ sudo sensors-detect   # answer the prompts; safe defaults are usually fine on this iMac
$ sensors
```

Typical output on this iMac (GPU via `radeon`, fans/temps via `applesmc`, CPU via `coretemp`):

```
radeon-pci-0100
Adapter: PCI adapter
temp1:        +55.0 C

applesmc-isa-0300
Adapter: ISA adapter
ODD :         998 RPM  (min = 1000 RPM, max = 5100 RPM)
HDD :        1500 RPM  (min = 1500 RPM, max = 6000 RPM)
CPU :        2498 RPM  (min = 2500 RPM, max = 3900 RPM)
TA0P:         +25.2 C
TC0D:         +38.0 C
...
Tp0P:         +71.5 C

coretemp-isa-0000
Adapter: ISA adapter
Core 0:       +43.0 C  (crit = +105.0 C)
Core 1:       +45.0 C  (crit = +105.0 C)
```

#### fancontrol / pwmconfig (not usable here)

The usual `lm_sensors` fan daemon expects PWM-controlled fans. On this iMac, `applesmc` exposes fan speeds through sysfs (`fan*_min`), not standard PWM chips:

```shell
$ sudo pwmconfig
# There are no pwm-capable sensor modules installed
```

So `pwmconfig` cannot build `/etc/fancontrol`, and `sudo fancontrol` is not an option. Use **`sensors` for read-only monitoring** and a custom script for fan curves.


### Fan control script

Script in the repo: [opt/sbin/fancontrol.sh](opt/sbin/fancontrol.sh). It reads applesmc temperatures and writes minimum RPM to each fan every 10 seconds:

| Fan (sensors label) | sysfs | Sensor | Label |
| :------------------ | :---- | :----- | :---- |
| ODD | `fan1_min` | `temp10_input` | TO0P (optical drive) |
| HDD | `fan2_min` | `temp8_input` | TH0P (HDD proximity) |
| CPU | `fan3_min` | `temp2_input` | TC0D (CPU die) |

Install and start at boot (adjust `BASE` in the script if your `applesmc.*` path differs):

```shell
$ sudo install -m755 opt/sbin/fancontrol.sh /opt/sbin/fancontrol.sh
$ echo '/opt/sbin/fancontrol.sh &' | sudo tee -a /etc/rc.local
$ sudo chmod +x /etc/rc.local
```

Run manually in the background:

```shell
$ sudo /opt/sbin/fancontrol.sh &
```


## Ports

### pkgutils

Configure pkgbuild to use -j2 in CFLAGS

[/etc/pkgmk.conf](etc/pkgmk.conf)


## Desktop

<img src="screenshot.png" width="400" />

### Xorg

The GPU is handled by the in-kernel **`radeon`** driver (AMD replacement card instead of the stock Intel/ATI soldered on the board).

TBD — `xorg.conf.d`, DDX/modesetting driver, acceleration, and 1680×1050 display tuning.

Activate `tap to click` 
```shell
$ echo '# Activate "tap to click" on touchpad
Section "InputClass"
	Identifier "libinput touchpad catchall"
	MatchIsTouchpad "on"
	MatchDevicePath "/dev/input/event*"
	Driver "libinput"
	Option "Tapping" "on"
EndSection' | sudo tee /etc/X11/xorg.conf.d/40-libinput.conf
```

### Wi-Fi (Broadcom b43)

The **BCM4321** (AirPort Extreme) uses the **b43** stack. Proprietary firmware (`b43-firmware` or equivalent from ports) is usually required in addition to the kernel module. Wireless packages were installed during setup (`wireless-tools`, `wpa_supplicant`, ...).

TBD — exact firmware packages and `wpa_supplicant` configuration.


### Audio

Intel HD Audio via **`snd_hda_intel`**.

TBD — ALSA mixer, default device, and testing.


### Xterm/UXterm

Install xrdb tool
```shell
$ sudo prt-get depinst xorg-xrdb
```

Create ~/.Xresources

```shell
$ xrdb -merge ~/.Xresources
```

Additionally we want some fonts
```shell
$ sudo prt-get depinst xorg-fonts-adobe-75dpi xorg-fonts-adobe-100dpi nerd-fonts-dejavu siji-ng
```

### Firefox

ALSA support was dropped starting Firefox 52.0 and later.
https://support.mozilla.org/en-US/questions/1209469

I still want to use ALSA and try to avoid pulseaudio as much as possible, so `apulse` comes to the rescue:
```shell
$ sudo prt-get depinst apulse
$ apulse firefox
```

### Openbox

Install `imlib2` and rebuild `openbox` to have icon support
```shell
$ sudo prt-get depinst imlib2
$ sudo prt-get update -fr openbox
```

Extras
```shell
$ sudo prt-get depinst xdg-utils
```

Install openbox configuration manager
```shell
$ sudo prt-get depinst obconf
```

Install openbox themes. Then apply a theme you desire using `obconf`
```shell
$ mkdir -p ~/.themes
$ git clone https://github.com/terroo/openbox-themes themes-1 && \
    mv themes-1/* ~/.themes && rm -rf themes-1
$ git clone https://github.com/addy-dclxvi/openbox-theme-collections themes-2 && \
    mv themes-2/* ~/.themes && rm -rf themes-2
$ obconf
```

Auto-start openbox when running `startx` command:
[~/.config/openbox/autostart](home/sepen/.config/openbox/autostart)

Show openbox menu when windows key is pressed,
Edit [~/.config/openbox/rc.xml](home/sepen/.config/openbox/rc.xml) and add this code block:
```xml
<keybind key="Super_L">
  <action name="ShowMenu">
    <menu>root-menu</menu>
  </action>
</keybind>
```
And then reread the Openbox settings:
```shell
$ openbox --reconfigure
```

Generate openbox menu with `obmenu-generator`
```shell
$ sudo prt-get depinst obmenu-generator
$ obmenu-generator -i > $HOME/.config/openbox/menu.xml
```

Add a dynamic menu by copying this contents to [~/.config/openbox/menu.xml](home/sepen/.config/openbox/menu.xml)

```xml
<?xml version="1.0" encoding="utf-8"?>
<openbox_menu xmlns="http://openbox.org/"
 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://openbox.org/">
    <menu id="root-menu" label="obmenu-generator" execute="/usr/bin/obmenu-generator -i" />
</openbox_menu>
```

### Polybar

Install an eye candy status bar: `polybar`
```shell
$ sudo prt-get depinst polybar
$ cp /usr/share/polybar/config.example ~/.config/polybar/config
$ polybar -c ~/.config/polybar/config example
```

### XDM

<img src="screenshot-xdm.png" width="400" />

Install Xorg Display Manager
```shell
$ sudo prt-get depinst xorg-xdm
```

Enable it
```shell
$ ln -s .xinitrc ~/.xsession
```

Test it
```shell
$ sudo /etc/rc.d/xdm start
```

Customize
```shell
$ sudo vim /usr/X11/xdm/Xresources
$ sudo cp cruxlogo.xpm /usr/lib/X11/xdm/pixmaps
```

Take a screenshot of XDM login screen using scrot
```shell
$ sudo prt-get depinst scrot
$ sudo vim /usr/lib/X11/xdm/Xsetup_0
```
Add these lines at the end (or before any exec lines):
```
(sleep 5; DISPLAY=:0 /usr/bin/scrot /tmp/xdm_login.png) &
```
