#!/bin/bash

# Display blue message
label () { cecho "$1" blue; }
# Variants of label function
title () { label "$1\n"; }
split () { label "\n$1\n"; }
block () { clear; label "$1\n"; }

# Std* output format
ofmt () { sed "s/^/:: /"; }
# Pause installation
pause () { cecho "\n:: Press any key to continue..." yellow; read; }
# Update user's password -- $1: Username, $2: Password
password () { printf "$1:$2" | chpasswd --crypt-method=SHA${BITS} --sha-rounds=5000 && cecho ":: Password updated successfully"; }

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

mkInit ()
{
    split ":: Generate new initial ramdisk"
    # Wiki.archlinux.org/index.php/Initramfs
    mkinitcpio -p linux
}

# $@: Units list: 'kdm.service' 'cronie.service'
addUnits ()
{
    block ":: Enable new systemd unit(s) on bootup"

    # Enable *.service, *.target, ...
    for unit in "$@"
    do
        systemctl --quiet enable $unit > /dev/null 2>&1 && cecho ":: Unit enabled: ${CYAN}$unit"
    done
}

# Wiki.archlinux.org/index.php/Mkinitcpio
updateHooks ()
{
    block ":: Update /etc/mkinitcpio.conf"

    # Hooks required by LUKS
    for hook in encrypt
    do
        sed -i "/^HOOKS=/s/block/& $hook/" /etc/mkinitcpio.conf && cecho ":: Hook added: ${CYAN}$hook"
    done
}

# Wiki.archlinux.org/index.php/Locale
updateLocales ()
{
    split ":: Update /etc/locale.gen"
    # Enable UTF-8/ISO-8859-1 locales
    sed -i "2,22d;/${LOCALE}/s/^#//" /etc/locale.gen && locale-gen |& ofmt; pause
}

# Wiki.archlinux.org/index.php/Systemd-timesyncd
setupClock ()
{
    block ":: Configure Network Time Protocol"
    # Enable systemd-timesyncd daemon for synchronizing the system clock across the network
    timedatectl set-ntp true && cecho ":: Service enabled: ${CYAN}systemd-timesyncd"; pause
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

# Clean *PASS variables
# Wiki.archlinux.org/index.php/Securely_wipe_disk#shred
secureEraseData ()
{
    block ":: Secure Erase /root/ali/ali.sh"
    # Overwrite a file to hide its contents and delete it
    shred --zero --verbose --iterations=10 --remove=wipesync /root/ali/ali.sh |& ofmt
}

# Kernel.org/doc/Documentation/blockdev/zram.txt
setupZramSwap ()
{
    block ":: Create /etc/systemd/zram-generator.conf"
    # Generate pre-configured file
    zram_generator_conf && cecho ":: Generator enabled: ${CYAN}swap-create@.service"
}

# Wiki.archlinux.org/index.php/Kernel_modules#Blacklisting
blacklistMods ()
{
    split ":: Update /etc/modprobe.d/blacklist.conf"

    # Blacklist Kernel Module(s)
    for module in "${BLKMODS[@]}"
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
    echo "export QT_QPA_PLATFORMTHEME=$1" > $file && cecho ":: File updated: ${CYAN}$file"; pause
}

# Extras configuration files
# Naming convention: *_conf ()

zram_generator_conf ()
{
cat > /etc/systemd/zram-generator.conf << EOF
[zram0]
zram-fraction=0.10
max-zram-size=2048
host-memory-limit=none
compression-algorithm=zstd
EOF
}

