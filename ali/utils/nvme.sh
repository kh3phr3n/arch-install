#!/bin/bash

# Colors
OFF='\e[0m'
CYAN='\e[0;36m'
BLUE='\e[1;34m'
YELLOW='\e[1;33m'

# NVMe device
NVME='/dev/nvme0'
# NVMe namespace
NAMESPACE='/dev/nvme0n1'
# NVMe namespace size (Bytes)
BLOCKSIZE=$(blockdev --getsize64 ${NAMESPACE})

# Root privileges required
[[ "${UID}" -ne 0 ]] && exit 0 || clear

# Util functions
title () { echo -e "${BLUE}:: $1\n${OFF}"; }
pause () { echo -e "${YELLOW}\n:: Press any key to continue...${OFF}"; read; }

# Zero-fill
title 'Zero-fill namespace'
dd if=/dev/zero of=${NAMESPACE} bs=4096 count=${BLOCKSIZE} iflag=count_bytes status=progress && pause

# Nvme-format
title 'Format namespace'
nvme format ${NAMESPACE} --ses=1 --force && pause

# Nvme-smart-log
title 'SMART log device'
nvme smart-log ${NVME}

