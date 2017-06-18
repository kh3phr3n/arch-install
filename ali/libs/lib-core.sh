#!/bin/bash

# [Part 1]
installation ()
{
    clear
    title ":: [Part 1] Install base system\n"
    title ":: Computer   : ${CYAN}${PC}"
    title ":: Keyboard   : ${CYAN}${KEYBOARD}"
    title ":: HardDisk   : ${CYAN}${HARDDISK}"
    title ":: BootLoader : ${CYAN}${BOOTLOADER}"
    title ":: BaseSystem : ${CYAN}${BASESYSTEM}"

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
    clear
    title ":: [Part 2] Configure base system\n"
    title ":: Zone       : ${CYAN}${ZONE}"
    title ":: SubZone    : ${CYAN}${SUBZONE}"
    title ":: BootLoader : ${CYAN}${BOOTLOADER}"

    pause
    configureMirrors
    configureEtcFiles
    configureBaseSystem
    configureBootloader
}

# [Part 3]
endInstallation ()
{
    clear
    title ":: [Part 3] Unmount and reboot system\n"
    title ":: HardDisk : ${CYAN}${HARDDISK}"

    pause
    unmountFileSystems
    restartLinuxSystem
}

# [Part 4]
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
    restartLinuxSystem
}

