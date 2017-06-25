#!/bin/bash

installDesktop ()
{
    case "${DESKTOP}" in
        plasma5 ) installPlasma5 ;;
        i3wm    ) installI3wm    ;;
    esac; pause
}

installPlasma5 ()
{
    # Install KDE minimal
    installPkg 'sddm plasma phonon-qt5-gstreamer'
    # Install Additional Applications
    [[ "${#KDEPKGS[@]}" -gt 0 ]] && installPkg "${KDEPKGS[@]}"

    # Enable systemd units
    addUnits 'sddm.service' 'NetworkManager.service'
}

installI3wm ()
{
    # Install i3wm environment
    installPkg 'i3 sddm connman sysstat rxvt-unicode'
    # Install Additional Applications
    [[ "${#I3WMPKGS[@]}" -gt 0 ]] && installPkg "${I3WMPKGS[@]}"

    # Enable systemd units
    addUnits 'sddm.service' 'connman.service'
    # Force style for Qt5
    setQtStyleOverride 'gtk2'
}

install3rdParty ()
{
    # Install additional applications
    [[ "${#ADDPKGS[@]}" -gt 0 ]] && installPkg "${ADDPKGS[@]}"
    # Install development applications
    [[ "${#DEVPKGS[@]}" -gt 0 ]] && installPkg "${DEVPKGS[@]}"
}

