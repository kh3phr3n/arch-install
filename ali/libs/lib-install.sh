#!/bin/bash

# [Part 1]
kbLayout ()
{
    block ":: Change keyboard layout"
    loadkeys ${KEYMAP} && cecho ":: Layout updated: ${CYAN}${KEYMAP}"
}

prepareDisk ()
{
    split ":: Prepare hard disk drive partitions"
    cecho ":: HardDisk: ${CYAN}${HARDDISK}"
    cecho ":: BootDisk: ${CYAN}${BOOTFS}"
    cecho ":: RootDisk: ${CYAN}${ROOTFS}"

    split ":: Launch hard disk drive tool"
    ${HARDDISKTOOL} ${HARDDISK}; pause
}

encryptDisk ()
{
    block ":: Format Linux Unified Key Setup: ${CYAN}${ROOTFS}"
    printf "${LUKSPASS}" | cryptsetup --verbose --key-file=- --key-size=${BITS} --hash=sha${BITS} luksFormat ${ROOTFS}

    split ":: Open Linux Unified Key Setup: ${CYAN}${LUKSFS}"
    printf "${LUKSPASS}" | cryptsetup --verbose --key-file=- luksOpen ${ROOTFS} ${LUKSFS##*/}; pause
}

buildFileSystems ()
{
    for partition in ${BOOTFS} ${LUKSFS}
    do
        block ":: Build Linux filesystem: ${CYAN}$partition"
        mkfs.ext4 $partition && cecho ":: Linux filesystem formated\n"
        fsck.ext4 $partition && cecho "\n:: Linux filesystem verified"; pause
    done
}

mountFileSystems ()
{
    block ":: Mount Linux filesystems"
    # Root partition
    mount ${LUKSFS} /mnt && cecho ":: Linux filesystem mounted: ${CYAN}${LUKSFS}"
    # Boot partition
    mkdir /mnt/boot && mount ${BOOTFS} /mnt/boot && cecho ":: Linux filesystem mounted: ${CYAN}${BOOTFS}"; pause
}

installBaseSystem ()
{
    block ":: Install minimal system"
    pacstrap /mnt ${BASESYSTEM} ${BOOTLOADER}; pause
}

generateFstabAndChroot ()
{
    block ":: Generate new /etc/fstab"
    genfstab -U -p /mnt >> /mnt/etc/fstab && cecho ":: File updated: ${CYAN}/etc/fstab"

    split ":: Prepare Chroot environment"
    cp -r /root/ali /mnt/root && cecho ":: ALI updated: ${CYAN}/mnt/root/ali/"

    # chroot into our newly system
    nextPart 2; arch-chroot /mnt
}

# [Part 2]
configureMirrors ()
{
    block ":: Generate new Pacman mirrorlist"

    # Enable Pacman colors
    sed -i "/Color/s/^#//" /etc/pacman.conf

    # Pacman Mirrorlist Generator
    local file=$(mktemp --suffix=-mirrorlist)
    local url="https://www.archlinux.org/mirrorlist"
    local arg="?country=${MIRRORS}&protocol=https&ip_version=4&ip_version=6&use_mirror_status=on"

    # Get new mirrorlist
    curl --silent "$url/$arg" | sed "s/^#Server/Server/g" > $file && chmod 644 $file
    # Replace current mirrorlist
    mv $file /etc/pacman.d/mirrorlist && cecho ":: File updated: ${CYAN}/etc/pacman.d/mirrorlist\n" && updatePkg
}

configureEtcFiles ()
{
    block ":: Update /etc/* configuration files"

    for file in vconsole.conf locale.conf locale.gen localtime hostname adjtime hosts
    do
        case "$file" in
            # Wiki.archlinux.org/index.php/Time
            adjtime       ) hwclock --systohc --utc                                          ;;
            localtime     ) ln -sf /usr/share/zoneinfo/${ZONE}/${SUBZONE} /etc/localtime     ;;

            # Wiki.archlinux.org/index.php/Network
            hostname      ) echo ${PC} > /etc/hostname                                       ;;
            hosts         ) sed -i "/^127.0.0.1/s/$/ ${PC}/;/^::1/s/$/ ${PC}/" /etc/hosts    ;;

            # Wiki.archlinux.org/index.php/Locale
            locale.gen    ) sed  -i "2,22d;/${LOCALE}/s/^#//" /etc/locale.gen                ;;
            locale.conf   ) echo -e "LANG=${LOCALE}.UTF-8\nLC_COLLATE=C" > /etc/locale.conf  ;;

            # Wiki.archlinux.org/index.php/Fonts#Console_fonts
            vconsole.conf ) echo -e "KEYMAP=${KEYMAP}\nFONT=${TTYFONT}" > /etc/vconsole.conf ;;
        esac
        [[ -f "/etc/$file" ]] && cecho ":: File updated: ${CYAN}/etc/$file"
    done; pause
}

configureBaseSystem ()
{
    # Blacklist Kernel Modules
    [[ "${#BLKMODS[@]}" -gt 0 ]] && blacklistMods ${BLKMODS[@]}

    # Configure LUKS hooks and Zram swap
    updateHooks && setupZramSwap; pause

    block ":: Generate locales system"
    locale-gen && initramfs; pause

    block ":: Set root password"
    password root ${ROOTPASS}
}

configureBootloader ()
{
    title ":: Configure bootloader"

    if [ "${BOOTLOADER}" == "grub" ]
    then
        # Grub2 installation
        grub-install --target=i386-pc --recheck ${HARDDISK}

        # Fix error messages at boot
        cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo

        # Cryptdevice arguments
        local dmname=${LUKSFS##*/}
        local device="\/dev\/mapper\/${LUKSFS##*/}"
        local dsuuid=$(blkid -o value -s UUID ${ROOTFS})

        # Edit /etc/default/grub
        sed -i "/^GRUB_CMDLINE_LINUX_DEFAULT=/s/quiet//" /etc/default/grub
        sed -i "/^GRUB_CMDLINE_LINUX=/s/\"$/cryptdevice=UUID=$dsuuid:$dmname root=$device&/" /etc/default/grub

        split ":: Generate new /boot/grub/grub.cfg"
        grub-mkconfig -o /boot/grub/grub.cfg
    fi
    nextPart 3
}

# [Part 3]
unmountFileSystems ()
{
    block ":: Unmount Linux filesystems: ${CYAN}/mnt/*"
    umount --verbose --recursive /mnt

    split ":: Close Linux Unified Key Setup: ${CYAN}${LUKSFS}"
    cryptsetup --verbose luksClose ${LUKSFS##*/}; nextPart 4
}

restartLinuxSystem ()
{
    title ":: Reboot ArchLinux system"

    for (( i=10 ; i>0 ; i-- ))
    do
        echo -n "$i " && sleep 1
    done; reboot
}

# Third-party functions
nextPart ()
{
    case "$1" in
        2 )
            split ":: Next Part: Configuration"
            cecho ":: Change directory to /root/ali"
            cecho ":: Run $(basename $0) -c or --configuration\n" ;;
        3 )
            split ":: Next Part: End-Installation"
            cecho ":: Quit Chroot environment with Ctrl-D"
            cecho ":: Run $(basename $0) -e or --end-installation\n" ;;
        4 )
            split ":: Next Part: Post-Installation"
            cecho ":: After reboot, Run $(basename $0) -p or --post-installation\n" ;;
    esac
}

