#!/bin/bash

# +--------------------------------------------+
# | File    : lib-core.sh                      |
# | Email   : rc[dot]dev[at]tuxico[dot]com     |
# | Licence : GPLv3 GNU General Public License |
# +--------------------------------------------+

# [Part 1] Install the base system
installation ()
{
    clear
    title ":: [Part 1] Install the base system\n"
    title ":: Computer   : ${CYAN}${PC}"
    title ":: Keyboard   : ${CYAN}${KEYBOARD}"
    title ":: HardDisk   : ${CYAN}${HARDDISK}"
    title ":: BootLoader : ${CYAN}${BOOTLOADER}"
    title ":: BaseSystem : ${CYAN}${BASESYSTEM}"

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
    clear
    title ":: [Part 2] Configure the base system\n"
    title ":: Zone       : ${CYAN}${ZONE}"
    title ":: SubZone    : ${CYAN}${SUBZONE}"
    title ":: BootLoader : ${CYAN}${BOOTLOADER}"

    pause
    configureMirrors
    configureEtcFiles
    configureBaseSystem
    configureBootloader
}

# [Part 3] Unmount and reboot the system
endInstallation ()
{
    clear
    title ":: [Part 3] Unmount and reboot Arch\n"
    title ":: HardDisk : ${CYAN}${HARDDISK}"

    pause
    unmountPartitions
    restartArchSystem
}

# [Part 4] Install X.Org, KDE environment
postInstallation ()
{
    clear
    title ":: [Part 4] Create new user, install X.Org...\n"
    title ":: XDriver    : ${CYAN}${XDRIVER}"
    title ":: UserName   : ${CYAN}${USERNAME}"
    title ":: UserShell  : ${CYAN}${USERSHELL}"
    title ":: UserGroups : ${CYAN}${USERGROUPS}"

    pause
    setupClock
    setupUsers
    installXorg
    installDesktop
    install3rdParty
    restartArchSystem
}

