# U-Boot 

## Debugging with `U-Boot` prompt

Setup a serial console connection and then power up the device.
This will output some info when the bootloader (U-Boot) starts:
```
U-Boot 2009.01-2.0.6-efikamx (Nov 02 2010 - 17:13:53)

CPU:   Freescale i.MX51 family 3.0V at 800 MHz
mx51 pll1: 800MHz
mx51 pll2: 665MHz
mx51 pll3: 216MHz
ipg clock     : 66500000Hz
ipg per clock : 665000000Hz
uart clock    : 66500000Hz
cspi clock    : 54000000Hz
Board: MX51 Efika MX 3.0 [POR]
DRAM:  512 MB
JEDEC ID: 0xbf:0x25:0x4a
Reading SPI NOR flash 0x40000 [0x10000 bytes] -> ram 0x975f06e8
.SUCCESS

*** Warning - bad CRC, using default environment

In:    serial
Out:   serial
Err:   serial
board id: 1.0.1, rev1.3
Boot Source: SPI NOR FLASH BOOT
Boot Cmd: for device in "mmc ide"; do if strcmp ${device} == mmc; then; mmcinit; setenv units "0 1"; else; setenv units "0"; fi; for interface in ${units}; do if strcmp ${device} == mmc; then mmcprobe ${interface}; else; ide reset; fi; for fs in "ext2 fat"; do setenv loadcmd "${fs}load ${device} 0:1"; if ${loadcmd} ${scriptaddr} boot.scr; then; if imi ${scriptaddr}; then; autoscr ${scriptaddr}; fi; fi; done; done; done;
```

When this message apperas:
```
Hit any key to stop autoboot:  3 0
```

Press a key to interrumpt the boot process. Then a prompt appears:
```
U-Boot#
```

## Boot from a kernel backup

To boot a backup kernel (`uImage.backup`) from the first partition of the internal storage:
```
U-Boot# ide reset; ide device 0; setenv bootargs console=tty1 console=ttymxc0,115200 root=/dev/sda2 rootwait rw noinitrd; ext2load ide 0:1 ${kerneladdr} uImage.backup; bootm ${kerneladdr} "";
```

Explanation command by command:

- Prepare device
  ```
  U-Boot# ide reset;
  Reset IDE: Bus 0: OK
  Device 0: Model: SanDisk pSSD-P2 8GB  Firm: SSD 5.20 Ser#:  BBZ050310055830
              Type: Hard Disk
              Capacity: 7641.2 MB = 7.4 GB (15649200 x 512)
  ```
  ```
  U-Boot# ide device 0
  IDE device 0: Model: SanDisk pSSD-P2 8GB  Firm: SSD 5.20 Ser#:  BBZ050310055830
              Type: Hard Disk
              Capacity: 7641.2 MB = 7.4 GB (15649200 x 512)
  ... is now current device
  ```
- Get info about partitions
  ```
  U-Boot# ide part 0
  Partition Map for IDE device 0  --   Partition Type: DOS
  Partition     Start Sector     Num Sectors     Type
      1		      7812	    242189	83
      2		    250001	  15399199	83
  ```
- List files from partition. We are locking for a backup `uImage`
  ```
  U-Boot# ext2ls ide 0:1
  <DIR>       1024 .
  <DIR>       1024 ..
               442 boot.scr
               370 boot.script
           2194712 uImage
           2322761 uImage.backup
  ```

- Setup boot arguments
  ```
  U-Boot# setenv bootargs console=tty1 console=ttymxc0,115200 root=/dev/sda2 rootwait rw noinitrd;
  ```
- Load kernel into memory
  ```
  U-Boot# setenv kernel uImage.backup;
  ```
  ```
  U-Boot# setenv loadcmd ext2load ide 0:1;
  ```
  ```
  U-Boot#  ${loadcmd} ${kerneladdr} ${kernel}
  2348288 bytes read
  ```
- Boot the kernel `uImage.backup` (the empty "" means without ramdisk)
  ```
  U-Boot# bootm ${kerneladdr} ""
  ## Booting kernel from Legacy Image at 90007fc0 ...
     Image Name:   CRUX-ARM kernel-efikamx 2.6.31
     Image Type:   ARM Linux Kernel Image (uncompressed)
     Data Size:    2348224 Bytes =  2.2 MB
     Load Address: 90008000
     Entry Point:  90008000
     Verifying Checksum ... OK
     Loading Kernel Image ... OK
  OK
  Starting kernel ...
  Uncompressing Linux......
  ```


## Environment Variables

`U-Boot` uses some environment variables to store `kerneladdr`, `scriptaddr`, `bootcmd`, `loadcmd`, etc.
To know the actual values of all these environment variables use the `printenv` command:
```
U-Boot# printenv
bootdelay=3
baudrate=115200
loadaddr=0x90007FC0
firmware_version=20101102171353
uboot_addr=0x00000000
uboot_size=0x00040000
env_addr=0x00040000
kerneladdr=0x90007FC0
scriptaddr=0x91000000
ramdiskaddr=0x92000000
console=ttymxc0,115200
model=mx
bootcmd=for device in "mmc ide"; do if strcmp ${device} == mmc; then; mmcinit; setenv units "0 1"; else; setenv units "0"; fi; for interface in ${units}; do if strcmp ${device} == mmc; then mmcprobe ${interface}; else; ide reset; fi; for fs in "ext2 fat"; do setenv loadcmd "${fs}load ${device} 0:1"; if ${loadcmd} ${scriptaddr} boot.scr; then; if imi ${scriptaddr}; then; autoscr ${scriptaddr}; fi; fi; done; done; done;
stdin=serial
stdout=serial
stderr=serial

Environment size: 706/65532 bytes
```

And for example, with the info above we can extract the logic from `bootcmd`:
```
for device in "mmc ide"; do

  if strcmp ${device} == mmc; then;
    mmcinit;
    setenv units "0 1";
  else;
    setenv units "0";
  fi;

  for interface in ${units}; do

    if strcmp ${device} == mmc; then
      mmcprobe ${interface};
    else;
      ide reset;
    fi;

    for fs in "ext2 fat"; do

      setenv loadcmd "${fs}load ${device} 0:1";

      if ${loadcmd} ${scriptaddr} boot.scr; then;
        if imi ${scriptaddr}; then;
          autoscr ${scriptaddr};
        fi;
      fi;

    done;

  done;

done;

```