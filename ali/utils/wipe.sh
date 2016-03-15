#!/bin/bash

# +--------------------------------------------+
# | File    : wipe.sh                          |
# | Email   : rcs[dot]devel[at]gmail[dot]com   |
# | Licence : GPLv3 GNU General Public License |
# +--------------------------------------------+

# Root privileges required
[[ "${UID}" -ne 0 ]] && exit 0 || clear

# Colors
OFF='\e[0m'
CYAN='\e[0;36m'
BLUE='\e[1;34m'

# Hard Disk Drive label
HARDDISK='/dev/sda'

# Zero-fill
echo -e "${BLUE}:: Zero-fill device: ${CYAN}${HARDDISK}\n${OFF}"
dd if=/dev/zero of=${HARDDISK} bs=1M status=progress

# Diagnostic
echo -e "${BLUE}:: Smart diagnostic: ${CYAN}${HARDDISK}\n${OFF}"
smartctl --test=short ${HARDDISK} && while [[ $(smartctl --all ${HARDDISK}) =~ 'progress' ]]; do sleep 10; done

# Statistics
echo -e "${BLUE}\n:: Smart statistics: ${CYAN}${HARDDISK}\n${OFF}"
smartctl --health ${HARDDISK}
smartctl --log=error ${HARDDISK}
smartctl --log=xselftest,1 ${HARDDISK}

# Status
echo -e "${BLUE}:: Smart support: ${CYAN}${HARDDISK}\n${OFF}"
smartctl --info ${HARDDISK} | grep 'SMART support'

