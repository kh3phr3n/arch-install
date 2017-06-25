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
    block ":: Install Plasma environment"

    # Install KDE minimal
    installPkg 'sddm plasma phonon-qt5-gstreamer'
    # Install Additional Applications
    [[ "${#KDEPKGS[@]}" -gt 0 ]] && installPkg "${KDEPKGS[@]}"

    # Enable systemd units
    addUnits 'sddm.service' 'NetworkManager.service'; pause
}

installI3 ()
{
    block ":: Install i3 environment"

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
    block ":: Install additional applications"
    cecho ":: Packages available: ${#ADDPKGS[@]}"; pause
    [[ "${#ADDPKGS[@]}" -gt 0 ]] && installPkg "${ADDPKGS[@]}"

    block ":: Install development applications"
    cecho ":: Packages available: ${#DEVPKGS[@]}"; pause
    [[ "${#DEVPKGS[@]}" -gt 0 ]] && installPkg "${DEVPKGS[@]}"
}

