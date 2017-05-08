#!/bin/bash

# +--------------------------------------------+
# | File    : lib-xorg.sh                      |
# | Email   : rc[dot]dev[at]tuxico[dot]com     |
# | Licence : GPLv3 GNU General Public License |
# +--------------------------------------------+

installXorg ()
{
    clear
    title ":: Install X.Org Window System"; pause

    # Install xorg-* packages
    installPkg 'xorg-server xorg-xset xorg-xinit xorg-xinput xorg-xdpyinfo xorg-fonts-type1 gsfonts'
    # Install misc fonts
    installPkg 'ttf-roboto ttf-dejavu ttf-freefont ttf-liberation ttf-fira-sans ttf-fira-mono ttf-bitstream-vera'
    # Install Alsa/PulseAudio utilities
    installPkg 'alsa-utils pulseaudio pulseaudio-alsa'

    # Install X.Org drivers
    installGraphicsDriver
    # Configure X.Org server
    xorgConfiguration
    # Create Fontconfig links
    fontConfiguration
}

installGraphicsDriver ()
{
    # Install graphics drivers
    # Create configuration file if available
    case "${XDRIVER}" in
        # Infos: wiki.archlinux.org/index.php/Intel
        intel   ) installPkg "xf86-video-intel libva-intel-driver" && xorg_20_intel_conf && earlyStart "i915" ;;

        # Infos: wiki.archlinux.org/index.php/Nouveau
        nouveau ) installPkg "xf86-video-nouveau" && xorg_20_nouveau_conf && earlyStart "nouveau" ;;

        # Infos: wiki.archlinux.org/index.php/Nvidia
        nvidia-304xx | nvidia-340xx | nvidia ) installPkg "${XDRIVER}" && xorg_20_nvidia_conf ;;

        # Infos: archlinux.org/groups/x86_64/xorg-drivers
        *       ) installPkg "xf86-video-${XDRIVER}" ;;
    esac; pause
}

xorgConfiguration ()
{
    clear
    title ":: Configure X.Org Window System\n"

    # Create monitor configuration file
    xorg_10_monitor_conf  && cecho ":: Monitor configured: ${CYAN}${RESOLUTION}"
    # Create keyboard configuration file
    xorg_10_keyboard_conf && cecho ":: Keyboard configured: ${CYAN}${XKBLAYOUT}, ${XKBVARIANT}"

    # Create touchpad configuration file
    [[ ${TOUCHPAD} -ne 0 ]] && xorg_10_touchpad_conf && cecho ":: Touchpad configured: ${CYAN}${ACCELSPEED}, ${CLICKMETHOD}"

    # Check graphics drivers configuration file
    [[ -f ${XCONFDIR}/20-${XDRIVER}.conf ]] && cecho ":: Graphic driver configured: ${CYAN}${XDRIVER}"
}

fontConfiguration ()
{
    title "\n:: Configure Fontconfig presets\n"

    for link in "${FCGLINKS[@]}"
    do
        link+='.conf'
        ln -s /etc/fonts/conf.avail/$link /etc/fonts/conf.d && cecho ":: Link added: ${CYAN}$link"
    done; pause
}

# Basic configuration files
# Naming convention: xorg_10_<device>_conf ()

# Monitor : 10-monitor.conf
# Keyboard: 10-keyboard.conf
# Touchpad: 10-touchpad.conf

xorg_10_monitor_conf ()
{
cat > ${XCONFDIR}/10-monitor.conf << EOF
Section "Monitor"
    Identifier "Monitor0"
    Option     "PreferredMode" "${RESOLUTION}"
EndSection
EOF
}

xorg_10_keyboard_conf ()
{
cat > ${XCONFDIR}/10-keyboard.conf << EOF
Section "InputClass"
    MatchIsKeyboard "on"
    Identifier      "Keyboard"
    Option          "XkbLayout"  "${XKBLAYOUT}"
    Option          "XkbVariant" "${XKBVARIANT}"
    Option          "XkbOptions" "compose:menu,terminate:ctrl_alt_bksp"
EndSection
EOF
}

xorg_10_touchpad_conf ()
{
cat > ${XCONFDIR}/10-touchpad.conf << EOF
Section "InputClass"
    MatchIsTouchpad "on"
    Identifier      "Touchpad"
    Driver          "libinput"
    Option          "Tapping" "on"
    Option          "AccelSpeed" "${ACCELSPEED}"
    Option          "DisableWhileTyping" "on"
    Option          "ClickMethod" "${CLICKMETHOD}"
EndSection
EOF
}

# Driver configuration files
# Naming convention: xorg_20_<driver>_conf ()

# Intel   : 20-intel.conf
# Nvidia  : 20-nvidia.conf
# Nouveau : 20-nouveau.conf

xorg_20_intel_conf ()
{
cat > ${XCONFDIR}/20-intel.conf << EOF
Section "Device"
    Identifier "Intel Graphics"
    Driver     "intel"
    Option     "TearFree" "true"
    Option     "AccelMethod" "uxa"
EndSection
EOF
}

xorg_20_nvidia_conf ()
{
cat > ${XCONFDIR}/20-nvidia.conf << EOF
Section "Device"
    Identifier "Nvidia Card"
    VendorName "NVIDIA Corporation"
    Driver     "nvidia"
    Option     "NoLogo" "true"
    Option     "RegistryDwords" "EnableBrightnessControl=1"
EndSection
EOF
}

xorg_20_nouveau_conf ()
{
cat > ${XCONFDIR}/20-nouveau.conf << EOF
Section "Device"
    Identifier "Nvidia Card"
    Driver     "nouveau"
    Option     "SwapLimit" "2"
    Option     "GLXVBlank" "true"
EndSection
EOF
}

