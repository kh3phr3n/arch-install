#!/bin/bash

# [Part 1]
installation ()
{
    block ":: [Part 1] Install base system"
    label ":: Computer   : ${CYAN}${PC}"
    label ":: Keyboard   : ${CYAN}${KEYBOARD}"
    label ":: HardDisk   : ${CYAN}${HARDDISK}"
    label ":: BootLoader : ${CYAN}${BOOTLOADER}"
    label ":: BaseSystem : ${CYAN}${BASESYSTEM}"

    pause
    kbLayout
    prepareDisk
    encryptDisk
    buildFileSystems
    mountFileSystems
    installBaseSystem
    generateFstabAndChroot
}

# [Part 2]
configuration ()
{
    block ":: [Part 2] Configure base system"
    label ":: Zone       : ${CYAN}${ZONE}"
    label ":: SubZone    : ${CYAN}${SUBZONE}"
    label ":: BootLoader : ${CYAN}${BOOTLOADER}"

    pause
    configureMirrors
    configureEtcFiles
    configureBaseSystem
    configureBootloader
}

# [Part 3]
endInstallation ()
{
    block ":: [Part 3] Unmount and reboot system"
    label ":: HardDisk : ${CYAN}${HARDDISK}"

    pause
    unmountFileSystems
    restartLinuxSystem
}

# [Part 4]
postInstallation ()
{
    block ":: [Part 4] Create new user, install X.Org..."
    label ":: XDriver    : ${CYAN}${XDRIVER}"
    label ":: UserName   : ${CYAN}${USERNAME}"
    label ":: UserShell  : ${CYAN}${USERSHELL}"
    label ":: UserGroups : ${CYAN}${USERGROUPS}"

    pause
    setupClock
    setupUsers
    installXorg
    installDesktop
    install3rdParty
    restartLinuxSystem
}

