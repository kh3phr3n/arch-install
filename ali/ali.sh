#!/bin/bash

# Target machine, this variable is used for:
# Hostname -> /etc/hostname
# Optional configuration -> conf/${PC}.conf
PC='msi'

# Configuration files
CONFIGS=('core.conf'); [[ -e "conf/${PC}.conf" ]] && CONFIGS+=(${PC}.conf)
# Arch Linux Installer libraries
MINLIBS=(${CONFIGS[@]} 'lib-core.sh' 'lib-utils.sh' 'lib-install.sh')
# Additional libraries required by Part 4
MAXLIBS=(${MINLIBS[@]} 'apps.conf' 'lib-xorg.sh' 'lib-users.sh' 'lib-desktop.sh')

# Quick help
information ()
{
    echo "Syntax : $(basename $0) [Option]..."
    echo "Option :"
    echo "  -i, --installation       [Part 1] Install base system"
    echo "  -c, --configuration      [Part 2] Configure base system"
    echo "  -e, --end-installation   [Part 3] Unmount and reboot system"
    echo "  -p, --post-installation  [Part 4] Install X.Org, Desktop environment..."
}

# Source ALI's libraries
# $@: MINLIBS / MAXLIBS
loadLibs ()
{
    for library in "$@"
    do
        [[ "$library" == "apps.conf" ]] && title "\n:: Load 3rd libraries:\n"

        if [[ "$library" =~ ".conf" ]]
            then source conf/$library && echo ":: Library loaded: $library" || exit 1
            else source libs/$library && echo ":: Library loaded: $library" || exit 1
        fi
    done; colors; pause
}

# Run Arch Linux Installer
if [ "${UID}" -ne 0 ]
then
    clear; echo "Root privileges are required for running ALI."

elif [ "$#" -eq 0 ]
then
    clear; echo "Try '$(basename $0) -h' for more information."

elif [ $(pwd) != "/root/ali" ]
then
    clear; echo "Run '$(basename $0)' into '/root/ali' directory."

else
    clear

    while getopts ":hicep-:" option
    do
        if [ "$option" == "-" ]
        then
            case ${OPTARG} in
                help              ) option=h ;;
                installation      ) option=i ;;
                configuration     ) option=c ;;
                end-installation  ) option=e ;;
                post-installation ) option=p ;;
            esac
        fi
        case $option in
            h ) information                                       ;;
            i ) loadLibs ${MINLIBS[@]} && installation            ;;
            c ) loadLibs ${MINLIBS[@]} && configuration           ;;
            e ) loadLibs ${MINLIBS[@]} && endInstallation         ;;

            # At this point, no network available yet
            p ) systemctl start dhcpcd.service || exit 1
                loadLibs ${MAXLIBS[@]} && postInstallation        ;;

            ? ) echo "$(basename $0): Invalid Option: -${OPTARG}" ;;
        esac
    done
fi

