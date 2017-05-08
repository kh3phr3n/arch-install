#!/bin/bash

# +--------------------------------------------+
# | File    : lib-install.sh                   |
# | Email   : rc[dot]dev[at]tuxico[dot]com     |
# | Licence : GPLv3 GNU General Public License |
# +--------------------------------------------+

# [Part 1] Install the base system
keyboardLayout ()
{
    clear
    title ":: Change keyboard layout\n"
    loadkeys ${KEYBOARD}
}

diskPartitions ()
{
    title "\n:: Create disk partitions\n"

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

diskFilesystems ()
{
    clear
    title ":: Format disk partitions\n"

    for partition in "${PARTITIONS[@]}"
    do
        local hdd=$(echo $partition | cut -d":" -f1)
        local lfs=$(echo $partition | cut -d":" -f3)

        title ":: Format partition: ${CYAN}$hdd => $lfs\n"

        if [ "$lfs" == "swap" ]
            then mkswap $hdd && cecho "\n:: $hdd formated"
            else mkfs.$lfs $hdd && cecho ":: $hdd formated\n"; fsck $hdd && cecho "\n:: $hdd verified"
        fi; pause; clear
    done
}

mountPartitions ()
{
    clear
    title ":: Mount disk partitions\n"

    for partition in "${PARTITIONS[@]}"
    do
        local hdd=$(echo $partition | cut -d":" -f1)
        local mnt=$(echo $partition | cut -d":" -f2)

        case "$mnt" in
            swap ) swapon $hdd && cecho ":: Swap mounted: ${CYAN}$hdd => $mnt"                    ;;
            /mnt ) mount  $hdd $mnt && cecho ":: Disk mounted: ${CYAN}$hdd => $mnt"               ;;
            *    ) mkdir  $mnt && mount $hdd $mnt && cecho ":: Disk mounted: ${CYAN}$hdd => $mnt" ;;
        esac
    done; pause
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

# [Part 2] Configure the base system
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
    title ":: Update configuration files\n"

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
    # Append additionals hooks
    [[ "${#NEWHOOKS[@]}" -gt 0 ]] && addHooks ${NEWHOOKS[@]}

    # Blacklist Kernel Modules
    [[ "${#BLKMODS[@]}" -gt 0 ]] && blacklistMods ${BLKMODS[@]}; pause

    clear
    title ":: Generate locales system\n"
    locale-gen && initramfs; pause

    clear
    title ":: Set root password\n"
    passwd; pause
}

configureBootloader ()
{
    title ":: Configure bootloader\n"

    if [ "${BOOTLOADER}" == "grub" ]
    then
        # Grub2 installation
        grub-install --target=i386-pc --recheck ${HARDDISK}

        # Enable Grub2 logs
        sed -i "s/\<quiet\>//g" /etc/default/grub
        # Fix error messages at boot
        cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo

        title "\n:: Generate new /boot/grub/grub.cfg\n"
        grub-mkconfig -o /boot/grub/grub.cfg
    fi
    nextPart 3
}

# [Part 3] Unmount and reboot the system
unmountPartitions ()
{
    clear
    title ":: Unmount disk partitions\n"

    for (( i=${#PARTITIONS[@]}-1 ; i>=0 ; i-- ))
    do
        local hdd=$(echo ${PARTITIONS[$i]} | cut -d":" -f1)
        local mnt=$(echo ${PARTITIONS[$i]} | cut -d":" -f2)

        [[ "$mnt" != "swap" ]] && umount $mnt && cecho ":: Disk unmounted: ${CYAN}$mnt => $hdd"
    done; nextPart 4
}

restartArchSystem ()
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

