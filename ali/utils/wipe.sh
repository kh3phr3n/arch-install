#!/bin/bash

# +--------------------------------------------+
# | File    : wipe.sh                          |
# | Email   : rc[dot]dev[at]tuxico[dot]com     |
# | Licence : GPLv3 GNU General Public License |
# +--------------------------------------------+

# Root privileges required
[[ "${UID}" -ne 0 ]] && exit 0 || clear

# Colors
OFF='\e[0m'
CYAN='\e[0;36m'
BLUE='\e[1;34m'
YELLOW='\e[1;33m'

# Hard Disk Drive label
HARDDISK='/dev/sda'
# Hard Disk Drive size (B)
HARDDISKSIZE=$(blockdev --getsize64 ${HARDDISK})

# Zero-fill
echo -e "${BLUE}:: Zero-fill device: ${CYAN}${HARDDISK}\n${OFF}"
dd if=/dev/zero of=${HARDDISK} bs=4096 count=${HARDDISKSIZE} iflag=count_bytes status=progress && echo -e "${YELLOW}\n:: Press any key to continue...${OFF}"; read

if [ "${HARDDISK}" == "/dev/sda" ]
then
    # Diagnostic
    echo -e "${BLUE}:: Smart diagnostic: ${CYAN}${HARDDISK}\n${OFF}"
    smartctl --test=short ${HARDDISK} && while [[ $(smartctl --all ${HARDDISK}) =~ 'progress' ]]; do sleep 10; done

    # Statistics
    echo -e "${BLUE}\n:: Smart statistics: ${CYAN}${HARDDISK}\n${OFF}"
    smartctl --health --log=error --log=xselftest,1 ${HARDDISK}

    # Status
    echo -e "${BLUE}:: Smart support: ${CYAN}${HARDDISK}\n${OFF}"
    smartctl --info ${HARDDISK} | grep 'SMART support'
fi

