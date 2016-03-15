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
        pacman --sync $package; sleep 1
    done
}

# Install packages without confirmation
# $@: cf. installPkg()
installNcPkg ()
{
    for package in "$@"
    do
        title -c ":: Package(s): ${CYAN}$package"
        pacman --sync --noconfirm $package; sleep 1
    done
}

