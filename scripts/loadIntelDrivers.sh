#!/bin/bash
/mnt/sw/compilers/IntelSoftware/sepdk/src/insmod-sep3 -g root
/mnt/sw/compilers/IntelSoftware/sepdk/src/vtsspp/insmod-vtsspp -g root
echo 0 > /proc/sys/kernel/nmi_watchdog
