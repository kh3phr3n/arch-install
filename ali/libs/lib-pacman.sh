#!/bin/bash

# +--------------------------------------------+
# | File    : lib-pacman.sh                    |
# | Email   : rcs[dot]devel[at]gmail[dot]com   |
# | Licence : GPLv3 GNU General Public License |
# +--------------------------------------------+

# Update/Upgrade system
updatePkg ()
{
    title -n ":: Synchronize and upgrade packages"
    pacman --sync --refresh --sysupgrade; pause
}

# $@: Packages: 'vlc' 'zip unzip'
installPkg ()
{
    for package in "$@"
    do
        title -c ":: Package(s): ${CYAN}$package"
        pacman --sync --logfile ${LOGFILE} $package; sleep 1
    done
}

# Install packages without [Y/n] confirmation
# $@: cf. installPkg()
installNcPkg ()
{
    for package in "$@"
    do
        title -c ":: Package(s): ${CYAN}$package"
        pacman --sync --noconfirm --logfile ${LOGFILE} $package; sleep 1
    done
}

