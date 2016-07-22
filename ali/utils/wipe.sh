#!/bin/bash

# +--------------------------------------------+
# | File    : wipe.sh                          |
# | Email   : rc[dot]dev[at]tuxico[dot]com     |
# | Licence : GPLv3 GNU General Public License |
# +--------------------------------------------+

# Colors
OFF='\e[0m'
CYAN='\e[0;36m'
BLUE='\e[1;34m'
YELLOW='\e[1;33m'

# Hard Disk Drive label
HARDDISK='/dev/sda'
# Hard Disk Drive size (B)
HARDDISKSIZE=$(blockdev --getsize64 ${HARDDISK})
# Hard Disk Drive type (0 = SSD)
HARDDISKTYPE=$(cat /sys/block/${HARDDISK##*/}/queue/rotational)
# Hard Disk Drive state ("" = frozen)
HARDDISKSTATE=$(hdparm -I ${HARDDISK} | grep -P 'not[ \t]frozen')

# Root privileges required
[[ "${UID}" -ne 0 ]] && exit 0 || clear
# SSD 'not frozen' required
[[ "${HARDDISKTYPE}" -eq 0 ]] && [[ -z "${HARDDISKSTATE}" ]] && exit 0

# Util functions
title () { echo -e "${BLUE}:: $1: ${CYAN}${HARDDISK}\n${OFF}"; }
pause () { echo -e "${YELLOW}\n:: Press any key to continue...${OFF}"; read; }

# Zero-fill
title 'Zero-fill device'
dd if=/dev/zero of=${HARDDISK} bs=4096 count=${HARDDISKSIZE} iflag=count_bytes status=progress && pause

# Hdparm tool
if [ "${HARDDISKTYPE}" -eq 0 ]
then
    title 'ATA Secure Erase'
    hdparm --user-master u --security-set-pass NULL ${HARDDISK}       | sed -n '/Issuing/s/^[ \t]*//;4p' && \
    hdparm --user-master u --security-erase-enhanced NULL ${HARDDISK} | sed -n '/Issuing/s/^[ \t]*//;4p' && pause
fi

# Smartctl tool
if [ "${HARDDISK}" == "/dev/sda" ]
then
    title 'Smart diagnostic'
    smartctl --test=short ${HARDDISK} && while [[ $(smartctl --all ${HARDDISK}) =~ 'progress' ]]; do sleep 10; done

    title 'Smart statistics'
    smartctl --health --log=error --log=xselftest,1 ${HARDDISK}

    title 'Smart support'
    smartctl --info ${HARDDISK} | grep 'SMART support'
fi

