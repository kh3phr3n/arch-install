#!/bin/bash

# +--------------------------------------------+
# | File    : lib-desktop.sh                   |
# | Email   : rc[dot]dev[at]tuxico[dot]com     |
# | Licence : GPLv3 GNU General Public License |
# +--------------------------------------------+

installDesktop ()
{
    # Install Desktop Environment
    case "${DESKTOP}" in
        plasma5 ) installPlasma5 ;;
        gnome3  ) installGnome3  ;;
        i3      ) installI3      ;;
    esac
}

installPlasma5 ()
{
    clear
    title ":: Install KDE Plasma Environment\n"

    # Install KDE minimal
    updatePkg && installPkg 'sddm plasma phonon-qt5-gstreamer'
    # Install Additional Applications
    [[ "${#KDEPKGS[@]}" -gt 0 ]] && installPkg "${KDEPKGS[@]}"

    # Enable systemd units
    addUnits 'sddm.service' 'NetworkManager.service'
}

installGnome3 ()
{
    clear
    title ":: Install GNOME Environment\n"

    # Install GNOME minimal
    updatePkg && installPkg 'gnome zeitgeist gnome-tweak-tool'
    # Install Additional Applications
    [[ "${#GNOMEPKGS[@]}" -gt 0 ]] && installPkg "${GNOMEPKGS[@]}"

    # Enable systemd units
    addUnits 'gdm.service' 'NetworkManager.service'
}

installI3 ()
{
    clear
    title ":: Install i3 Environment\n"

    # Install i3 environment
    updatePkg && installPkg 'i3 sddm connman sysstat rxvt-unicode'
    # Install Additional Applications
    [[ "${#I3PKGS[@]}" -gt 0 ]] && installPkg "${I3PKGS[@]}"

    # Enable systemd units
    addUnits 'sddm.service' 'connman.service'
    # Force style for Qt5
    setQtStyleOverride 'gtk2'
}

install3rdParty ()
{
    clear
    title ":: Install Third-party applications\n"
    updatePkg && [[ "${#ADDPKGS[@]}" -gt 0 ]] && installPkg "${ADDPKGS[@]}"

    clear
    title ":: Install development tools\n"
    updatePkg && [[ "${#DEVPKGS[@]}" -gt 0 ]] && installPkg "${DEVPKGS[@]}"
}

