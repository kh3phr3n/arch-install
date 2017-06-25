#!/bin/bash

# Display blue messages
label () { cecho "$1" blue; }
title () { cecho "$1\n" blue; }
split () { cecho "\n$1\n" blue; }
block () { clear; cecho "$1\n" blue; }

# Pause installation
pause () { cecho "\n:: Press any key to continue..." yellow; read; }
# Check if an element exist in a string -- $1: Choice, $2: List of Choices
contains () { for e in "${@:2}"; do [[ $e == $1 ]] && break; done; }
# Initialize terminal colors
colors () { PURPLE='\e[0;35m' YELLOW='\e[1;33m' GREEN='\e[0;32m' CYAN='\e[0;36m' BLUE='\e[1;34m' RED='\e[0;31m' OFF='\e[0m'; }
# Update user's password -- $1: Username, $2: Password
password () { echo "$1:$2" | chpasswd --crypt-method SHA256 --sha-rounds 5000 && cecho ":: $1's password updated successfully\n"; }

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

    # wiki.archlinux.org/index.php/Initramfs
    mkinitcpio -p linux
}

# $@: Units list: 'kdm.service' 'cronie.service'
addUnits ()
{
    title ":: Enable systemd unit(s)"

    # Enable *.service, *.target, ...
    for unit in "$@"
    do
        systemctl --quiet enable $unit > /dev/null 2>&1 && cecho ":: Unit enabled: ${CYAN}$unit"
    done
}

# wiki.archlinux.org/index.php/Dm-crypt/Encrypting_an_entire_system#Configuring_mkinitcpio
updateHooks ()
{
    split ":: Update /etc/mkinitcpio.conf"

    # Update consolefont, keyboard, keymap, encrypt
    sed -i "/^HOOKS=/s/ keyboard//" /etc/mkinitcpio.conf && \
    sed -i "/^HOOKS=/s/block/& encrypt/" /etc/mkinitcpio.conf && \
    sed -i "/^HOOKS=/s/block/consolefont keyboard keymap &/" /etc/mkinitcpio.conf && \
    # Updated successfully
    cecho ":: Hooks updated: ${CYAN}consolefont keyboard keymap encrypt"; pause
}

# wiki.archlinux.org/index.php/Systemd-timesyncd
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

# wiki.archlinux.org/index.php/MySQL
secureMySQL ()
{
    if [ -x /usr/bin/mysql_secure_installation ]
    then
        title ":: Secure MySQL installation"

        # Start MySQL server, securize and reload
        systemctl start mysqld && mysql_secure_installation && systemctl restart mysqld; pause
    fi
}

# github.com/Nefelim4ag/systemd-swap
setupZramSwap ()
{
    block ":: Update /etc/systemd/swap.conf"

    # Disable Zswap and enable Zram
    sed -i "/^zswap_enabled=/s/1/0/" /etc/systemd/swap.conf && \
    sed -i "/^zram_enabled=/s/0/1/" /etc/systemd/swap.conf && \
    # Enabled successfully
    cecho ":: Swap enabled: ${CYAN}Zram\n"

    # Enable systemd unit
    addUnits 'systemd-swap.service'
}

# wiki.archlinux.org/index.php/Kernel_modules#Blacklisting
blacklistMods ()
{
    block ":: Update /etc/modprobe.d/blacklist.conf"

    # Blacklist Kernel Module(s)
    for module in "$@"
    do
        echo "blacklist $module" >> /etc/modprobe.d/blacklist.conf && cecho ":: Module blacklisted: ${CYAN}$module"
    done
}

# wiki.archlinux.org/index.php/Qt
# wiki.archlinux.org/index.php/Uniform_Look_for_Qt_and_GTK_Applications
setQtStyleOverride ()
{
    block ":: Set GTK+ style for Qt5"

    local file='/etc/profile.d/qt5-style.sh'
    # Force GTK+ style for all Qt5 applications
    echo "export QT_STYLE_OVERRIDE=$1" > $file && chmod 755 $file && cecho ":: File updated: ${CYAN}$file"; pause
}

