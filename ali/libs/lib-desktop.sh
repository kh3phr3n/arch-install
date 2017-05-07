#!/bin/bash

# +--------------------------------------------+
# | File    : lib-desktop.sh                   |
# | Email   : rc[dot]dev[at]tuxico[dot]com     |
# | Licence : GPLv3 GNU General Public License |
# +--------------------------------------------+

installDesktop ()
{
    case "${DESKTOP}" in
        plasma5 ) installPlasma5 ;;
        gnome3  ) installGnome3  ;;
        i3      ) installI3      ;;
    esac
}

installPlasma5 ()
{
    clear
    title ":: Install Plasma environment"; pause

    # Install KDE minimal
    installPkg 'sddm plasma phonon-qt5-gstreamer'
    # Install Additional Applications
    [[ "${#KDEPKGS[@]}" -gt 0 ]] && installPkg "${KDEPKGS[@]}"

    # Enable systemd units
    addUnits 'sddm.service' 'NetworkManager.service'
}

installGnome3 ()
{
    clear
    title ":: Install GNOME environment"; pause

    # Install GNOME minimal
    installPkg 'gnome zeitgeist gnome-tweak-tool'
    # Install Additional Applications
    [[ "${#GNOMEPKGS[@]}" -gt 0 ]] && installPkg "${GNOMEPKGS[@]}"

    # Enable systemd units
    addUnits 'gdm.service' 'NetworkManager.service'
}

installI3 ()
{
    clear
    title ":: Install i3 environment"; pause

    # Install i3 environment
    installPkg 'i3 sddm connman sysstat rxvt-unicode'
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
    title ":: Install additional applications"; pause
    [[ "${#ADDPKGS[@]}" -gt 0 ]] && installPkg "${ADDPKGS[@]}"

    clear
    title ":: Install development applications"; pause
    [[ "${#DEVPKGS[@]}" -gt 0 ]] && installPkg "${DEVPKGS[@]}"
}

