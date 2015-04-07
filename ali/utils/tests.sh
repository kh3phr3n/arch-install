#!/bin/bash

# +--------------------------------------------+
# | File    : tests.sh                         |
# | Email   : rcs[dot]devel[at]gmail[dot]com   |
# | Licence : GPLv3 GNU General Public License |
# +--------------------------------------------+

# Root privileges required
[[ "${UID}" -ne 0 ]] && exit 0

# Current pc
PC='hp'
# Tests logfile
LOGS='/root/ali/tests.log'

# System files to test
MSCFILES=('/boot/grub/grub.cfg' '/boot/grub/locale/en.mo' '/etc/sudoers')
PY2LINKS=('/usr/local/bin/pip' '/usr/local/bin/pydoc' '/usr/local/bin/python' '/usr/local/bin/ipython' '/usr/local/bin/virtualenv')
CATFILES=('/etc/fstab' '/etc/mkinitcpio.conf' '/etc/pacman.d/mirrorlist' '/etc/modprobe.d/nobeep.conf' '/etc/profile.d/qt5-style.sh')

# Load settings
source conf/${PC}.conf || exit 1

# Begin Tests
# -----------

# Check users directories
ls -alR /root >> ${LOGS} && ls -alR /home/${USERNAME} >> ${LOGS}

# Check owners/permissions
for file in "${MSCFILES[@]}" ; do ls -l $file                      >> ${LOGS} ; done
for file in "${PY2LINKS[@]}" ; do ls -l $file                      >> ${LOGS} ; done
for file in "${ETCFILES[@]}" ; do ls -l /etc/$file                 >> ${LOGS} ; done
for file in "${FCGLINKS[@]}" ; do ls -l /etc/fonts/conf.d/$file    >> ${LOGS} ; done
for file in "${XFILES[@]}"   ; do ls -l /etc/X11/xorg.conf.d/$file >> ${LOGS} ; done

# Check owners/permissions + content files
for file in "${CATFILES[@]}" ; do cat $file | less && ls -l $file  >> ${LOGS} ; done

