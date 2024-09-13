#!/bin/bash

installXorg ()
{
    # Install xorg-* packages
    installPkg 'xorg-server xorg-xset xorg-xinit xorg-xinput xorg-xrandr xorg-xdpyinfo xorg-fonts-type1 gsfonts'
    # Install misc fonts
    installPkg 'ttf-roboto ttf-dejavu ttf-liberation ttf-fira-sans ttf-fira-mono noto-fonts-emoji'
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
    # Create configuration file if available
    case "${XDRIVER}" in
        # Wiki.archlinux.org/title/Xorg#Driver_installation
        intel | radeon | nouveau ) installPkg "mesa vulkan-${XDRIVER}" && xorg_20_modesetting_conf ;;
        # Archlinux.org/groups/x86_64/xorg-drivers
        * ) installPkg "xf86-video-${XDRIVER}" ;;
    esac; pause
}

xorgConfiguration ()
{
    block ":: Configure X.Org Window System"

    # Create pointer configuration file
    [[ ${POINTER} -ne 0 ]] && xorg_10_pointer_conf && cecho ":: Pointer configured: ${CYAN}${PTACCSPEED}"
    # Create touchpad configuration file
    [[ ${TOUCHPAD} -ne 0 ]] && xorg_10_touchpad_conf && cecho ":: Touchpad configured: ${CYAN}${TPACCSPEED}"

    # Create keyboard configuration file
    xorg_10_keyboard_conf && cecho ":: Keyboard configured: ${CYAN}${XKBLAYOUT}, ${XKBVARIANT}"

    # Check video driver configuration file
    [[ -f ${XCONFDIR}/20-${XDRIVER}.conf ]] && cecho ":: Video driver configured: ${CYAN}${XDRIVER}"
}

fontConfiguration ()
{
    split ":: Configure Fontconfig presets"

    for link in "${FCGLINKS[@]}"
    do
        link+='.conf'
        ln -s /usr/share/fontconfig/conf.avail/$link /usr/share/fontconfig/conf.default && cecho ":: Link added: ${CYAN}$link"
    done; pause
}

# Basic configuration files
# Naming convention: xorg_10_<device>_conf ()

xorg_10_pointer_conf ()
{
cat > ${XCONFDIR}/10-pointer.conf << EOF
Section "InputClass"
    MatchIsPointer "on"
    Identifier     "Pointer"
    Driver         "libinput"
    Option         "AccelSpeed" "${PTACCSPEED}"
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
    Option          "AccelSpeed" "${TPACCSPEED}"
    Option          "ClickMethod" "none"
    Option          "DisableWhileTyping" "on"
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
EndSection
EOF
}

# Driver configuration files
# Naming convention: xorg_20_<driver>_conf ()

xorg_20_modesetting_conf ()
{
cat > ${XCONFDIR}/20-${XDRIVER}.conf << EOF
Section "Device"
    Identifier "KMS Graphics"
    Driver     "modesetting"
EndSection
EOF
}

