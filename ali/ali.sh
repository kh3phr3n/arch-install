#!/bin/bash

# +--------------------------------------------+
# | File    : ali.sh                           |
# | Email   : rcs[dot]devel[at]gmail[dot]com   |
# | Licence : GPLv3 GNU General Public License |
# +--------------------------------------------+

# Main settings
# -------------

# Current pc
PC='msi'
# DHCP interface
NET='dhcpcd'
# Proc architecture
ARCH=$(uname -m)

# Arch Linux Installer libraries
MINLIBS=(${PC}.conf 'lib-core.sh' 'lib-utils.sh' 'lib-install.sh')
# Additional libraries required by Part 4
MAXLIBS=(${MINLIBS[@]} 'apps.conf' 'lib-xorg.sh' 'lib-users.sh' 'lib-desktop.sh')

# Main program
# ------------

# Display a quick help
information ()
{
    echo "Syntax : $(basename $0) [Option]..."
    echo "Option :"
    echo "  -i, --installation       [Part 1] Install the base system"
    echo "  -c, --configuration      [Part 2] Configure the base system"
    echo "  -e, --end-installation   [Part 3] Unmount and reboot the system"
    echo "  -p, --post-installation  [Part 4] Install X.Org, KDE environment..."
}

# Download and source ALI's libraries
# $@: MINLIBS / MAXLIBS
loadLibs ()
{
    for library in "$@"
    do
        [[ "$library" == "apps.conf" ]] && title -j ":: Load 3rd libraries:"

        if [ "$library" == "${PC}.conf" ] || [ "$library" == "apps.conf" ]
            then source conf/$library && echo ":: Library loaded: $library" || exit 1
            else source libs/$library && echo ":: Library loaded: $library" || exit 1
        fi
    done; colors; pause
}

# Run Arch Linux Installer as root
if [ "${UID}" -ne 0 ]
then
    clear; echo "You must have root privileges to run ALI."

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

            # Start network dhcpcd unit
            p ) systemctl start ${NET}.service || exit 1
                loadLibs ${MAXLIBS[@]} && postInstallation        ;;

            ? ) echo "$(basename $0): Invalid Option: -${OPTARG}" ;;
        esac
    done
fi

