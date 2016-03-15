#!/bin/bash

# +--------------------------------------------+
# | File    : wipe.sh                          |
# | Email   : rcs[dot]devel[at]gmail[dot]com   |
# | Licence : GPLv3 GNU General Public License |
# +--------------------------------------------+

# Root privileges required
[[ "${UID}" -ne 0 ]] && exit 0

# Hard Disk Drive label
HARDDISK='/dev/sda'

# Zero-fill
dd if=/dev/zero of=${HARDDISK} bs=1M status=progress

# Diagnostic
smartctl --test=short ${HARDDISK} && while [[ $(smartctl --all ${HARDDISK}) =~ 'progress' ]]; do sleep 10; done

# Statistics
smartctl --health ${HARDDISK}
smartctl --log=error ${HARDDISK}
smartctl --log=selftest ${HARDDISK}

# SMART status
smartctl --info ${HARDDISK} | grep 'SMART support'

