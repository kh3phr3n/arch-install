#!/bin/bash

# +--------------------------------------------+
# | File    : lib-sys.sh                       |
# | Email   : rcs[dot]devel[at]gmail[dot]com   |
# | Licence : GPLv3 GNU General Public License |
# +--------------------------------------------+

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
# $1: 'GTK+', 'Fusion', 'Windows'
setQtStyleOverride ()
{
    title -c ":: Set GTK+ style for Qt5"

    local file='/etc/profile.d/qt5-style.sh'
    # Force GTK+ style for all Qt5 applications
    echo "export QT_STYLE_OVERRIDE=$1" > $file && chmod 755 $file && cecho ":: File updated: ${CYAN}$file"
}

# wiki.archlinux.org/index.php/Font_configuration#Subpixel_rendering
setFt2SubpixelHinting ()
{
    title -j ":: Set FT2_SUBPIXEL_HINTING"

    local file='/etc/environment'
    # Freetype2 subpixel hinting
    echo "FT2_SUBPIXEL_HINTING=1" > $file && cecho ":: File updated: ${CYAN}$file"
}

# wiki.archlinux.org/index.php/Disable_PC_speaker_beep
disableSpeakerBeep ()
{
    title -j ":: Disable PC speaker beep"

    local file='/etc/modprobe.d/nobeep.conf'
    # Blacklist pcspkr kernel module globally
    echo "blacklist pcspkr" > $file && cecho ":: File updated: ${CYAN}$file"; pause
}

