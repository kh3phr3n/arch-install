#!/bin/bash

# [Part 1]
kbLayout ()
{
    block ":: Change keyboard layout"
    loadkeys ${KEYMAP} && cecho ":: Layout updated: ${CYAN}${KEYMAP}"; pause
}

prepareDisk ()
{
    block ":: Prepare Hard Disk Drive partitions"
    cecho ":: Boot partition: ${CYAN}${BOOTFS}"
    cecho ":: Root partition: ${CYAN}${ROOTFS}"

    split ":: Launch Hard Disk Drive tool"
    ${HARDDISKTOOL} ${HARDDISK}; pause
}

encryptDisk ()
{
    block ":: Prepare Linux Unified Key Setup (LUKS)"
    cecho ":: Root partition: ${CYAN}${ROOTFS}"
    cecho ":: Luks partition: ${CYAN}${LUKSFS}"

    split ":: Format Linux Unified Key Setup"
    printf "${LUKSPASS}" | cryptsetup --verbose --key-file=- --key-size=${BITS} --hash=sha${BITS} luksFormat ${ROOTFS} |& ofmt
    split ":: Open Linux Unified Key Setup"
    printf "${LUKSPASS}" | cryptsetup --verbose --key-file=- luksOpen ${ROOTFS} ${LUKSFS##*/} |& ofmt; pause
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
    mount --verbose ${LUKSFS} /mnt |& ofmt
    # Boot partition
    mkdir /mnt/boot && mount --verbose ${BOOTFS} /mnt/boot |& ofmt; pause
}

setupEfiPartition ()
{
    if [ "${UEFI}" -ne 0 ]
    then
        block ":: Build EFI system partition: ${CYAN}${UEFIFS}"
        mkfs.vfat -F32 ${UEFIFS} |& ofmt && fsck.vfat ${UEFIFS} |& ofmt

        split ":: Mount EFI system partition"
        mkdir /mnt/boot/efi && mount --verbose ${UEFIFS} /mnt/boot/efi |& ofmt; pause
    fi
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
    block ":: Create /etc/* configuration files"

    # Wiki.archlinux.org/index.php/Network
    echo ${PC} > /etc/hostname
    # Wiki.archlinux.org/index.php/Fonts
    echo KEYMAP=${KEYMAP} > /etc/vconsole.conf
    # Wiki.archlinux.org/index.php/Locale
    echo LANG=${LOCALE}.UTF-8 > /etc/locale.conf
    # Wiki.archlinux.org/index.php/Time
    hwclock --systohc --utc && ln -sf /usr/share/zoneinfo/${ZONE}/${SUBZONE} /etc/localtime

    local files=('vconsole.conf' 'locale.conf' 'localtime' 'hostname' 'adjtime')
    # Check if files have been created
    for file in ${files[@]}; do test -e "/etc/$file" && cecho ":: File created: ${CYAN}/etc/$file"; done
}

configureBaseSystem ()
{
    # Update /etc/locale.gen, /etc/*/{swap.conf,blacklist.conf}
    updateLocales && setupZramSwap && blacklistMods; pause
    # Update /etc/mkinitcpio.conf
    updateHooks && mkInit; pause

    block ":: Set root password"
    password root ${ROOTPASS}; pause
}

configureBootloader ()
{
    block ":: Configure bootloader"

    if [ "${UEFI}" -ne 0 ]
        then grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB |& ofmt
        else grub-install --target=i386-pc --recheck ${HARDDISK} |& ofmt
    fi

    # Fix error messages at boot
    cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo

    # Cryptdevice arguments
    local dmname=${LUKSFS##*/}
    local dsname=${HARDDISK##*/}
    local device="\/dev\/mapper\/${LUKSFS##*/}"
    local dsuuid=$(blkid -o value -s UUID ${ROOTFS})

    # Edit /etc/default/grub
    sed -i "/^GRUB_CMDLINE_LINUX_DEFAULT=/s/quiet//" /etc/default/grub
    sed -i "/^GRUB_CMDLINE_LINUX=/s/\"$/cryptdevice=UUID=$dsuuid:$dmname root=$device&/" /etc/default/grub
    # Enable TRIM support for SSD
    [[ $(cat /sys/block/$dsname/queue/rotational) -eq 0 ]] && sed -i "/^GRUB_CMDLINE_LINUX=/s/:$dmname/&:allow-discards/" /etc/default/grub

    split ":: Generate new /boot/grub/grub.cfg"
    grub-mkconfig -o /boot/grub/grub.cfg |& ofmt

    # Let's go!
    nextPart 3
}

# [Part 3]
unmountFileSystems ()
{
    block ":: Unmount Linux filesystems"
    umount --verbose --recursive /mnt |& ofmt

    split ":: Close Linux Unified Key Setup"
    cryptsetup --verbose luksClose ${LUKSFS##*/} |& ofmt; nextPart 4
}

restartLinuxSystem ()
{
    split ":: Reboot ArchLinux system"

    for (( i=10 ; i>0 ; i-- ))
    do
        echo -n "$i " && sleep 1
    done; reboot
}

# Third-party functions
nextPart ()
{
    pause
    # Whats next
    case "$1" in
        2 )
            block ":: Next Part: Configuration"
            cecho ":: Change directory to /root/ali"
            cecho ":: Run $(basename $0) -c or --configuration\n" ;;
        3 )
            block ":: Next Part: End-Installation"
            cecho ":: Quit Chroot environment with Ctrl-D"
            cecho ":: Run $(basename $0) -e or --end-installation\n" ;;
        4 )
            block ":: Next Part: Post-Installation"
            cecho ":: After reboot, Run $(basename $0) -p or --post-installation" ;;
    esac
}

