#!/bin/bash

# +--------------------------------------------+
# | File    : lib-install.sh                   |
# | Email   : rcs[dot]devel[at]gmail[dot]com   |
# | Licence : GPLv3 GNU General Public License |
# +--------------------------------------------+

# [Part 1] Install the base system
keyboardLayout ()
{
    title -c ":: Change keyboard layout"
    loadkeys ${KEYBOARD}
}

diskPartitions ()
{
    title -j ":: Create disk partitions"

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
    title -c ":: Format disk partitions"

    for partition in "${PARTITIONS[@]}"
    do
        local hdd=$(echo $partition | cut -d":" -f1)
        local lfs=$(echo $partition | cut -d":" -f3)

        title -n ":: Format partition: ${CYAN}$hdd => $lfs"

        if [ "$lfs" == "swap" ]
            then mkswap $hdd && cecho "\n:: $hdd formated"
            else mkfs.$lfs $hdd && cecho ":: $hdd formated\n"; fsck $hdd && cecho "\n:: $hdd verified"
        fi; pause; clear
    done
}

mountPartitions ()
{
    title -c ":: Mount disk partitions"

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
    title -c ":: Install minimal ArchLinux"
    pacstrap /mnt ${BASESYSTEM} ${BOOTLOADER}; pause
}

generateFstabAndChroot ()
{
    title -c ":: Generate new /etc/fstab"
    genfstab -U -p /mnt >> /mnt/etc/fstab && cecho ":: File updated: ${CYAN}/etc/fstab"

    title -j ":: Prepare Chroot environment"
    cp -r /root/ali /mnt/root && cecho ":: ALI updated: ${CYAN}/mnt/root/ali/"

    # chroot into our newly system
    nextPart 2; arch-chroot /mnt
}

# [Part 2] Configure the base system
configureMirrors ()
{
    title -c ":: Generate new Pacman mirrorlist"

    # Enable Pacman colors
    sed -i "/Color/s/^#//" /etc/pacman.conf

    # Pacman Mirrorlist Generator
    local file=$(mktemp --suffix=-mirrorlist)
    local url="https://www.archlinux.org/mirrorlist"
    local arg="?country=${MIRRORS}&protocol=http&ip_version=4&ip_version=6&use_mirror_status=on"

    # Get new mirrorlist
    curl --silent "$url/$arg" | sed "s/^#Server/Server/g" > $file && chmod 644 $file
    # Replace current mirrorlist
    mv $file /etc/pacman.d/mirrorlist && cecho ":: File updated: ${CYAN}/etc/pacman.d/mirrorlist\n" && updatePkg
}

configureEtcFiles ()
{
    title -c ":: Update configuration files"

    for file in "${ETCFILES[@]}"
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
    [[ "${#NEWHOOKS[@]}" -gt 0 ]] && addHooks ${NEWHOOKS[@]}; pause

    title -c ":: Generate locales system"
    locale-gen && initramfs; pause

    title -c ":: Set root password"
    passwd; pause
}

configureBootloader ()
{
    title -n ":: Configure bootloader"

    if [ "${BOOTLOADER}" == "grub" ]
    then
        # Grub2 installation
        modprobe dm-mod; grub-install --recheck ${HARDDISK}

        # Enable Grub2 logs
        sed -i "s/\<quiet\>//g" /etc/default/grub
        # Fix error messages at boot
        cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo

        title -j ":: Generate new /boot/grub/grub.cfg"
        grub-mkconfig -o /boot/grub/grub.cfg

    elif [ "${BOOTLOADER}" == "syslinux" ]
    then
        # Syslinux installation
        syslinux-install_update -iam

        title -j ":: Configure syslinux.cfg to point to the root partition"
        read  -p ":: Edit syslinux.cfg ? [Y/n]: " reply

        [[ "$reply" != ["nN"] ]] && nano /boot/syslinux/syslinux.cfg
    fi
    nextPart 3
}

# [Part 3] Unmount and reboot the system
unmountPartitions ()
{
    title -c ":: Unmount disk partitions"

    for (( i=${#PARTITIONS[@]}-1 ; i>=0 ; i-- ))
    do
        local hdd=$(echo ${PARTITIONS[$i]} | cut -d":" -f1)
        local mnt=$(echo ${PARTITIONS[$i]} | cut -d":" -f2)

        [[ "$mnt" != "swap" ]] && umount $mnt && cecho ":: Disk unmounted: ${CYAN}$mnt => $hdd"
    done; nextPart 4
}

restartArchSystem ()
{
    title -j ":: Reboot ArchLinux system"

    for (( i=${TIMEOUT} ; i>0 ; i-- ))
    do
        echo -n "$i " && sleep 1
    done; reboot
}

# Third-party functions
nextPart ()
{
    case "$1" in
        2 )
            title -j ":: Next Part: Configuration"
            cecho    ":: Change directory to /root/ali"
            cecho    ":: Run $(basename $0) -c or --configuration" ;;
        3 )
            title -j ":: Next Part: End-Installation"
            cecho    ":: Quit Chroot environment with Ctrl-D"
            cecho    ":: Run $(basename $0) -e or --end-installation" ;;
        4 )
            title -j ":: Next Part: Post-Installation"
            cecho    ":: After reboot, Run $(basename $0) -p or --post-installation" ;;
    esac
}

