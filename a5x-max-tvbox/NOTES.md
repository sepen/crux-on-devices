El primero hilo y el desarrollo de balbes150
- https://forum.armbian.com/topic/8082-armbian-for-tv-box-rk3328/page/1/


## LibreELEC

Lo bueno de LibreELEC es el soporte para la GPU y los drivers que traen aceleracion

Buscando se encuentra info de un post de LibreELEC preguntando por el A5X Max+
Pero es para la instalación directa a la eMMC en lugar de la SD
- https://forum.libreelec.tv/thread/23023-libreelec-on-rk3328-a5x-max-plus/


## U-Boot

Issues relacionados con el A5X Max+ para tener un u-boot ad-hoc:
- https://github.com/hexdump0815/u-boot-misc/issues/1
- https://github.com/hexdump0815/u-boot-misc/issues/2


## Armbian

Hilo sobre el A5X Max+ donde se habla del bootloader y que u-boot tiene hardcodeado el UUID de las particiones a arrancar
- https://forum.armbian.com/topic/4895-a5x-max-rk3328-4gb16gb/

Hay alguien que ha hecho una PR y ha dejado un zip pero no han mergeado por no estar alineada con el mainline
- https://github.com/armbian/build/pull/1415


## Kernel

Desarrollo de archlinux para los 3328
- https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=linux-rk3328



## 1st BOOT

- Tuesto la imagen LibreELEC-RK3328.arm-9.2.6-box.img en una SD de 1GB y la meto en la ranura de SD
- Tuesto la misma imagen en una uSD y la meto con un adaptador USB a algun puerto libre
- Con este combo SD+USB arranca y puedo entrar a LibreELEC Kodi Leia
- Desde Kodi configuro para que permita acceso por SSH y conecto por wifi a mi red (la ethernet no me funciona)
- Soy capaz de hacer login como root (pass: libreelec)
```
##############################################
#                 LibreELEC                  #
#            https://libreelec.tv            #
##############################################

LibreELEC (official): 9.2.6 (RK3328.arm)

```

## 1st version of CRUX-ARM ?

SOLUCION 1 (alpha) PARA TENER CRUX-ARM = SD+USB(uSD)

- Con LibreELEC 10 y 9 soy capaz de hacer bootear pero se necesita otro dtb para que tire de la SD card. Hace falta un combo para arrancar con la SD + USB (tostando una img en ambos)
  He probado algunos dtb y este es el menos malo rk3328-box-trn9.dtb (LE 9)

- Las release de LibreELEC oficiales que mas se ajustan:
    LibreELEC-RK3328.arm-9.2.6-box.img
    LibreELEC-RK3328.arm-9.2.6-box-trn9.img

- Se podría en una primera version de crux-arm para este dispositivo el usar un SD de arranque y luego tirar del USB (adaptador a uSD con una tarjeta rapidita) para crux-arm


- Hay otras versiones de LibreELEC no oficiales que pueden resultar en este dispositivo. La que mas se puede ajustar es la h96max

  https://github.com/knaerzche/LibreELEC.tv/releases/tag/RK322x-le980-e49037d
  https://github.com/knaerzche/LibreELEC.tv/releases/download/RK322x-le980-e49037d/LibreELEC-RK322x.arm-9.80-devel-20200228164917-cd590c7-rk3228a-h96mini.img.gz


