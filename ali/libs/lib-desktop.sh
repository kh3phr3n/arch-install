#!/bin/bash

# +--------------------------------------------+
# | File    : lib-desktop.sh                   |
# | Email   : rcs[dot]devel[at]gmail[dot]com   |
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
    title -c ":: Install KDE Plasma Environment"

    # Sync and upgrade system
    updatePkg
    # Install KDE minimal
    installPkg 'sddm plasma phonon-qt5-gstreamer'

    # Install Additional Applications
    [[ "${#KDEPKGS[@]}" -gt 0 ]] && installPkg "${KDEPKGS[@]}"

    # Enable systemd bootup units
    addUnits 'sddm.service' 'NetworkManager.service'
}

installGnome3 ()
{
    title -c ":: Install GNOME Environment"

    # Sync and upgrade system
    updatePkg
    # Install GNOME minimal
    installPkg 'gnome zeitgeist gnome-tweak-tool'

    # Install Additional Applications
    [[ "${#GNOMEPKGS[@]}" -gt 0 ]] && installPkg "${GNOMEPKGS[@]}"

    # Enable systemd bootup units
    addUnits 'gdm.service' 'NetworkManager.service'
}

installI3 ()
{
    title -c ":: Install i3 Environment"

    # Sync and upgrade system
    updatePkg
    # Install full i3 environment
    installPkg 'i3 sddm connman sysstat rxvt-unicode'

    # Install Additional Applications
    [[ "${#I3PKGS[@]}" -gt 0 ]] && installPkg "${I3PKGS[@]}"

    # Enable systemd bootup units
    addUnits 'sddm.service' 'connman.service'

    # Force GTK+ style for Qt5
    setQtStyleOverride 'gtk'
    # Disable PC speaker
    disableSpeakerBeep
}

install3rdParty ()
{
    title -c ":: Install Third-party applications"

    # Sync and upgrade system
    updatePkg

    # Install Additional Applications
    [[ "${#ADDPKGS[@]}" -gt 0 ]] && installPkg "${ADDPKGS[@]}"
}

