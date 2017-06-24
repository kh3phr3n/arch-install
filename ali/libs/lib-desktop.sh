#!/bin/bash

installDesktop ()
{
    case "${DESKTOP}" in
        plasma5 ) installPlasma5 ;;
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
    addUnits 'sddm.service' 'NetworkManager.service'; pause
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
    addUnits 'sddm.service' 'connman.service'; pause
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

