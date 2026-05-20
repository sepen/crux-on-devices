#!/bin/sh

BASE=/sys/devices/platform/applesmc.768

# Sensors
CPU_TEMP=$BASE/temp2_input   # TC0D CPU Die
HDD_TEMP=$BASE/temp8_input   # TH0P HDD Proximity
ODD_TEMP=$BASE/temp10_input  # TO0P Optical Drive Proximity

# Fans
FAN_ODD=$BASE/fan1_min  # ODD  range: 1000-5100 RPM
FAN_HDD=$BASE/fan2_min  # HDD  range: 1000-6000 RPM
FAN_CPU=$BASE/fan3_min  # CPU  range: 2500-3900 RPM

get_temp() { awk '{print int($1/1000)}' $1; }

while true; do
    CPU_T=$(get_temp $CPU_TEMP)
    HDD_T=$(get_temp $HDD_TEMP)
    ODD_T=$(get_temp $ODD_TEMP)

    # CPU fan based on TC0D
    if   [ $CPU_T -lt 40 ]; then echo 2500 > $FAN_CPU
    elif [ $CPU_T -lt 50 ]; then echo 2800 > $FAN_CPU
    elif [ $CPU_T -lt 60 ]; then echo 3200 > $FAN_CPU
    elif [ $CPU_T -lt 70 ]; then echo 3600 > $FAN_CPU
    else                         echo 3900 > $FAN_CPU
    fi

    # HDD fan based on TH0P
    if   [ $HDD_T -lt 35 ]; then echo 1000 > $FAN_HDD
    elif [ $HDD_T -lt 42 ]; then echo 1500 > $FAN_HDD
    elif [ $HDD_T -lt 48 ]; then echo 2500 > $FAN_HDD
    elif [ $HDD_T -lt 54 ]; then echo 4000 > $FAN_HDD
    else                         echo 6000 > $FAN_HDD
    fi

    # ODD fan based on TO0P
    if   [ $ODD_T -lt 35 ]; then echo 1000 > $FAN_ODD
    elif [ $ODD_T -lt 42 ]; then echo 1500 > $FAN_ODD
    elif [ $ODD_T -lt 48 ]; then echo 2500 > $FAN_ODD
    elif [ $ODD_T -lt 54 ]; then echo 3500 > $FAN_ODD
    else                         echo 5100 > $FAN_ODD
    fi

    sleep 10
done
