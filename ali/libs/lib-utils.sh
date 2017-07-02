#!/bin/bash

# Display blue message
label () { cecho "$1" blue; }

# Variants of label function
title () { label "$1\n"; }
split () { label "\n$1\n"; }
block () { clear; label "$1\n"; }

# Pause installation
pause () { cecho "\n:: Press any key to continue..." yellow; read; }
# Update user's password -- $1: Username, $2: Password
password () { printf "$1:$2" | chpasswd --crypt-method=SHA${BITS} --sha-rounds=5000 && cecho ":: Password updated successfully\n"; }

# Initialize colors
colors ()
{
    PURPLE='\e[0;35m'
    YELLOW='\e[1;33m'
    GREEN='\e[0;32m'
    CYAN='\e[0;36m'
    BLUE='\e[1;34m'
    RED='\e[0;31m'
    OFF='\e[0m'
}

# Display colored message
# $1: Message
# $2: Color
cecho ()
{
    case "$2" in
        purple ) echo -e "${PURPLE}$1 ${OFF}" ;;
        yellow ) echo -e "${YELLOW}$1 ${OFF}" ;;
        green  ) echo -e "${GREEN}$1  ${OFF}" ;;
        cyan   ) echo -e "${CYAN}$1   ${OFF}" ;;
        blue   ) echo -e "${BLUE}$1   ${OFF}" ;;
        red    ) echo -e "${RED}$1    ${OFF}" ;;
        *      ) echo -e "${OFF}$1    ${OFF}" ;;
    esac
}

# Pacman utils
# ------------

# Update/Upgrade system
updatePkg ()
{
    title ":: Synchronize and upgrade packages"
    pacman --sync --refresh --sysupgrade; pause
}

# $@: Packages: 'vlc' 'zip unzip'
installPkg ()
{
    for package in "$@"
    do
        block ":: Package(s): ${CYAN}$package"
        pacman --sync $package; sleep 1
    done
}

# System utils
# ------------

initramfs ()
{
    split ":: Generate new initial ramdisk"
    # Wiki.archlinux.org/index.php/Initramfs
    mkinitcpio -p linux
}

# $@: Units list: 'kdm.service' 'cronie.service'
addUnits ()
{
    block ":: Enable systemd unit(s)"

    # Enable *.service, *.target, ...
    for unit in "$@"
    do
        systemctl --quiet enable $unit > /dev/null 2>&1 && cecho ":: Unit enabled: ${CYAN}$unit"
    done
}

# Wiki.archlinux.org/index.php/Mkinitcpio
updateHooks ()
{
    split ":: Update /etc/mkinitcpio.conf"

    # Hooks required by LUKS
    for hook in encrypt keymap
    do
        sed -i "/^HOOKS=/s/block/& $hook/" /etc/mkinitcpio.conf && cecho ":: Hook added: ${CYAN}$hook"
    done; pause
}

# Wiki.archlinux.org/index.php/Systemd-timesyncd
setupClock ()
{
    block ":: Configure Network Time Protocol"
    # Enable systemd-timesyncd daemon for synchronizing the system clock across the network
    timedatectl set-ntp true && cecho ":: Service enabled: ${CYAN}systemd-timesyncd"; pause
}

# $1: Module: 'i915', 'amdgpu', 'radeon', 'nouveau', 'intel_agp i915'
earlyStart ()
{
    block ":: Update /etc/mkinitcpio.conf"
    # Kernel Mode Setting: wiki.archlinux.org/index.php/KMS
    sed -i "/^MODULES=/s/\"$/$1&/" /etc/mkinitcpio.conf && cecho ":: Module added: ${CYAN}$1" && initramfs
}

# Wiki.archlinux.org/index.php/MySQL
secureMySQL ()
{
    if [ -x /usr/bin/mysql_secure_installation ]
    then
        title ":: Secure MySQL installation"
        # Start MySQL server, securize and reload
        systemctl start mysqld && mysql_secure_installation && systemctl restart mysqld; pause
    fi
}

# Kernel.org/doc/Documentation/blockdev/zram.txt
setupZramSwap ()
{
    # Enable systemd unit
    addUnits 'systemd-swap.service'
    # Github.com/Nefelim4ag/systemd-swap
    split ":: Update /etc/systemd/swap.conf"
    # Disable Zswap and enable Zram
    sed -i "/^zswap_enabled=/s/1/0/;/^zram_enabled=/s/0/1/" /etc/systemd/swap.conf && cecho ":: Swap enabled: ${CYAN}Zram"
}

# Wiki.archlinux.org/index.php/Kernel_modules#Blacklisting
blacklistMods ()
{
    block ":: Update /etc/modprobe.d/blacklist.conf"

    # Blacklist Kernel Module(s)
    for module in "$@"
    do
        echo "blacklist $module" >> /etc/modprobe.d/blacklist.conf && cecho ":: Module blacklisted: ${CYAN}$module"
    done
}

# Wiki.archlinux.org/index.php/Qt
# Wiki.archlinux.org/index.php/Uniform_Look_for_Qt_and_GTK_Applications
setupQtStyle ()
{
    block ":: Set GTK+ style for Qt5"

    local file='/etc/profile.d/qt5-style.sh'
    # Force GTK+ style for all Qt5 applications
    echo "export QT_QPA_PLATFORMTHEME=$1" > $file && chmod 755 $file && cecho ":: File updated: ${CYAN}$file"; pause
}

