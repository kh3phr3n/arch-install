#!/bin/bash

# +--------------------------------------------+
# | File    : lib-utils.sh                     |
# | Email   : rc[dot]dev[at]tuxico[dot]com     |
# | Licence : GPLv3 GNU General Public License |
# +--------------------------------------------+

# Pause installation
pause () { cecho "\n:: Press any key to continue..." Yellow; read; }
# Check if an element exist in a string -- $1: Choice, $2: List of Choices
contains () { for e in "${@:2}"; do [[ $e == $1 ]] && break; done; }

# Initialize terminal colors
colors ()
{
    # Regular Colors
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
        Purple ) echo -e "${PURPLE}$1 ${OFF}" ;;
        Yellow ) echo -e "${YELLOW}$1 ${OFF}" ;;
        Green  ) echo -e "${GREEN}$1  ${OFF}" ;;
        Cyan   ) echo -e "${CYAN}$1   ${OFF}" ;;
        Blue   ) echo -e "${BLUE}$1   ${OFF}" ;;
        Red    ) echo -e "${RED}$1    ${OFF}" ;;
        *      ) echo -e "${OFF}$1    ${OFF}" ;;
    esac
}

# Display message with pause
# $1: Option
# $2: Message
title ()
{
    local option="$1" && local message="$2"

    case "$option" in
        -t ) cecho "$message" Blue            ;;
        -n ) cecho "$message\n" Blue          ;;
        -j ) cecho "\n$message\n" Blue        ;;
        -c ) clear && cecho "$message\n" Blue ;;
    esac
}

# Pacman utils
# ------------

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

# System utils
# ------------

# Create an initial ramdisk environment
initramfs ()
{
    title -j ":: Generate new initial ramdisk"

    # wiki.archlinux.org/index.php/Initramfs
    mkinitcpio -p linux
}

# Add units to systemd
# $@: Units list: 'kdm.service' 'cronie.service'
addUnits ()
{
    title -c ":: Enable Unit(s) to systemd"

    # Enable *.service, *.target, ...
    for unit in "$@"
    do
        systemctl --quiet enable $unit && cecho ":: Unit enabled: ${CYAN}$unit"
    done; pause
}

# Add hooks in /etc/mkinitcpio.conf
# $@: Hooks list: 'consolefont' 'keymap'
addHooks ()
{
    title -j ":: Add Hook(s) in /etc/mkinitcpio.conf"

    # Append hook(s) in HOOKS="" string
    for hook in "$@"
    do
        sed -i "/^HOOKS=*/s/\"$/ $hook&/" /etc/mkinitcpio.conf && cecho ":: Hook added: ${CYAN}$hook"
    done
}

# Enable Time synchronization
# wiki.archlinux.org/index.php/Systemd-timesyncd
setupClock ()
{
    title -c ":: Configure Network Time Protocol"

    # Enable systemd-timesyncd daemon for synchronizing the system clock across the network
    timedatectl set-ntp true && cecho ":: Service enabled: ${CYAN}systemd-timesyncd"; pause
}

# Add driver to mkinitcpio.conf
# $1: Module: 'i915', 'nouveau'
earlyStart ()
{
    title -c ":: Add Module in /etc/mkinitcpio.conf"

    # Kernel Mode Setting: wiki.archlinux.org/index.php/KMS
    sed -i "/^MODULES=*/s/\"$/$1&/" /etc/mkinitcpio.conf && cecho ":: Module added: ${CYAN}$1" && initramfs
}

# Secure MySQL installation
# -> Define root password
# -> Delete 'test' table
secureMySQL ()
{
    if [ -x /usr/bin/mysql_secure_installation ]
    then
        title -n ":: Secure MySQL installation"

        # Start MySQL server, securize and reload
        systemctl start mysqld && mysql_secure_installation && systemctl restart mysqld; pause
    fi
}

# wiki.archlinux.org/index.php/Qt
# wiki.archlinux.org/index.php/Uniform_Look_for_Qt_and_GTK_Applications
setQtStyleOverride ()
{
    title -c ":: Set GTK+ style for Qt5"

    local file='/etc/profile.d/qt5-style.sh'
    # Force GTK+ style for all Qt5 applications
    echo "export QT_STYLE_OVERRIDE=$1" > $file && chmod 755 $file && cecho ":: File updated: ${CYAN}$file"
}

# wiki.archlinux.org/index.php/Disable_PC_speaker_beep
disableSpeakerBeep ()
{
    title -j ":: Disable PC speaker beep"

    local file='/etc/modprobe.d/nobeep.conf'
    # Blacklist pcspkr kernel module globally
    echo "blacklist pcspkr" > $file && cecho ":: File updated: ${CYAN}$file"; pause
}

