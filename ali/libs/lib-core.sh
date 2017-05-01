#!/bin/bash

# +--------------------------------------------+
# | File    : lib-core.sh                      |
# | Email   : rcs[dot]devel[at]gmail[dot]com   |
# | Licence : GPLv3 GNU General Public License |
# +--------------------------------------------+

# [Part 1] Install the base system
installation ()
{
    title -c ":: [Part 1] Install the base system"
    title -t ":: Computer   : ${CYAN}${PC}"
    title -t ":: Keyboard   : ${CYAN}${KEYBOARD}"
    title -t ":: HardDisk   : ${CYAN}${HARDDISK}"
    title -t ":: BootLoader : ${CYAN}${BOOTLOADER}"
    title -t ":: BaseSystem : ${CYAN}${BASESYSTEM}"

    pause
    keyboardLayout
    diskPartitions
    diskFilesystems
    mountPartitions
    installBaseSystem
    generateFstabAndChroot
}

# [Part 2] Configure the base system (In chroot)
configuration ()
{
    title -c ":: [Part 2] Configure the base system"
    title -t ":: Zone       : ${CYAN}${ZONE}"
    title -t ":: SubZone    : ${CYAN}${SUBZONE}"
    title -t ":: BootLoader : ${CYAN}${BOOTLOADER}"

    pause
    configureMirrors
    configureEtcFiles
    configureBaseSystem
    configureBootloader
}

# [Part 3] Unmount and reboot the system
endInstallation ()
{
    title -c ":: [Part 3] Unmount and reboot Arch"
    title -t ":: TimeOut  : ${CYAN}${TIMEOUT}"
    title -t ":: HardDisk : ${CYAN}${HARDDISK}"

    pause
    unmountPartitions
    restartArchSystem
}

# [Part 4] Install X.Org, KDE environment
postInstallation ()
{
    title -c ":: [Part 4] Create new user, install X.Org..."
    title -t ":: XDriver    : ${CYAN}${XDRIVER}"
    title -t ":: UserName   : ${CYAN}${USERNAME}"
    title -t ":: UserShell  : ${CYAN}${USERSHELL}"
    title -t ":: UserGroups : ${CYAN}${USERGROUPS}"

    pause
    setupClock
    setupUsers
    installXorg
    installDesktop
    install3rdParty
    restartArchSystem
}

