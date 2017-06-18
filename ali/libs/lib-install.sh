#!/bin/bash

# [Part 1]
kbLayout ()
{
    clear
    title ":: Change keyboard layout\n"
    loadkeys ${KEYBOARD} && cecho ":: Layout updated: ${CYAN}${KEYBOARD}"
}

prepareDisk ()
{
    title "\n:: Prepare disk partitions\n"

    partitioningTools=('fdisk' 'gdisk' 'cgdisk' 'parted')
    PS3=":: Enter your option: "

    select partitioningTool in "${partitioningTools[@]}"
    do
        if contains "$partitioningTool" "${partitioningTools[@]}"
        then
            $partitioningTool ${HARDDISK}
            break
        fi
    done; pause
}

encryptDisk ()
{
    title "\n:: Prepare LUKS partition\n"
    cryptsetup --verbose --verify-passphrase --hash sha256 --key-size 256 --iter-time 5000 luksFormat ${ROOTFS}
    cryptsetup luksOpen ${ROOTFS} ${LUKSFS##*/}
}

buildFileSystems ()
{
    title "\n:: Build Linux filesystems\n"
    for partition in ${BOOTFS} ${LUKSFS}
    do
        mkfs.ext4 $partition && fsck $partition && cecho "\n:: $partition formated and verified"
    done; pause; clear
}

mountFileSystems ()
{
    title "\n:: Mount Linux filesystems\n"
    mkdir /mnt/boot
    mount ${LUKSFS} /mnt      && cecho ":: Linux filesystem mounted: ${CYAN}${LUKSFS}"
    mount ${BOOTFS} /mnt/boot && cecho ":: Linux filesystem mounted: ${CYAN}${BOOTFS}"; pause
}

installBaseSystem ()
{
    clear
    title ":: Install minimal system\n"
    pacstrap /mnt ${BASESYSTEM} ${BOOTLOADER}; pause
}

generateFstabAndChroot ()
{
    clear
    title ":: Generate new /etc/fstab\n"
    genfstab -U -p /mnt >> /mnt/etc/fstab && cecho ":: File updated: ${CYAN}/etc/fstab"

    title "\n:: Prepare Chroot environment\n"
    cp -r /root/ali /mnt/root && cecho ":: ALI updated: ${CYAN}/mnt/root/ali/"

    # chroot into our newly system
    nextPart 2; arch-chroot /mnt
}

# [Part 2]
configureMirrors ()
{
    clear
    title ":: Generate new Pacman mirrorlist\n"

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
    clear
    title ":: Update /etc/* configuration files\n"

    for file in vconsole.conf locale.conf locale.gen localtime hostname adjtime hosts
    do
        case "$file" in
            adjtime       ) hwclock --systohc --utc                                                   ;;
            hostname      ) echo ${PC} > /etc/hostname                                                ;;
            localtime     ) ln -sf /usr/share/zoneinfo/${ZONE}/${SUBZONE} /etc/localtime              ;;
            hosts         ) sed -i "/^127.0.0.1/s/$/ ${PC}/;/^::1/s/$/ ${PC}/" /etc/hosts             ;;

            # Locales
            locale.gen    ) sed  -i "2,22d;/${LOCALE}/s/^#//" /etc/locale.gen                         ;;
            locale.conf   ) echo -e "LANG=${LOCALE}.UTF-8\nLC_COLLATE=C" > /etc/locale.conf           ;;
            vconsole.conf ) echo -e "KEYMAP=${KEYBOARD}\nFONT=Lat2-Terminus16" > /etc/vconsole.conf   ;;

            # File not found
            *             ) cecho ":: File not found, check your ETCFILES variable in conf/<pc>.conf" ;;
        esac

        [[ -f "/etc/$file" ]] && cecho ":: File updated: ${CYAN}/etc/$file"
    done
}

configureBaseSystem ()
{
    # Blacklist Kernel Modules
    [[ "${#BLKMODS[@]}" -gt 0 ]] && blacklistMods ${BLKMODS[@]}

    # Add hooks for LUKS support
    updateHooks; pause

    clear
    title ":: Generate locales system\n"
    locale-gen && initramfs; pause

    clear
    title ":: Set root password\n"
    password root ${ROOTPASS}
}

configureBootloader ()
{
    title ":: Configure bootloader\n"

    if [ "${BOOTLOADER}" == "grub" ]
    then
        # Grub2 installation
        grub-install --target=i386-pc --recheck ${HARDDISK}

        # Fix error messages at boot
        cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo

        # Edit /etc/default/grub
        sed -i "s/\<quiet\>//g" /etc/default/grub
        sed -i "/^GRUB_CMDLINE_LINUX=/s/\"$/cryptdevice=UUID=$(lsblk -no UUID ${ROOTFS}):${LUKSFS##*/} root=\/dev\/mapper\/${LUKSFS##*/}&/g" /etc/default/grub

        title "\n:: Generate new /boot/grub/grub.cfg\n"
        grub-mkconfig -o /boot/grub/grub.cfg
    fi
    nextPart 3
}

# [Part 3]
unmountFileSystems ()
{
    clear
    title "::Unmount Linux filesystems\n"
    umount --verbose --recursive /mnt && cecho ":: Linux filesystems unmounted: ${CYAN}/mnt/*"; nextPart 4
}

restartLinuxSystem ()
{
    title "\n:: Reboot ArchLinux system\n"

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
            title "\n:: Next Part: Configuration\n"
            cecho ":: Change directory to /root/ali"
            cecho ":: Run $(basename $0) -c or --configuration" ;;
        3 )
            title "\n:: Next Part: End-Installation\n"
            cecho ":: Quit Chroot environment with Ctrl-D"
            cecho ":: Run $(basename $0) -e or --end-installation" ;;
        4 )
            title "\n:: Next Part: Post-Installation\n"
            cecho ":: After reboot, Run $(basename $0) -p or --post-installation" ;;
    esac
}

