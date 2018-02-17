#!/bin/bash

# Root privileges required
[[ "${UID}" -ne 0 ]] && exit 0 || clear

# Colors
OFF='\e[0m'
CYAN='\e[0;36m'
BLUE='\e[1;34m'
YELLOW='\e[1;33m'

# Packages url
URL='https://aur.tuxico.com'

# Packages list
PACKAGES=(
    # Aur helper
    'cower/cower-17-2-x86_64.pkg.tar.xz'
    # Extras i3wm
    'i3wm/xcursor-oxygen-5.11.1-1-any.pkg.tar.xz'
    # Extras tools
    'vscode/visual-studio-code-bin-1.20.1-1-x86_64.pkg.tar.xz'
    # Extras fonts
    'ttf-nonfree/ttf-nonfree-1.0-1-any.pkg.tar.xz'
    'ttf-awesome/ttf-font-awesome-4-4.7.0-5-any.pkg.tar.xz'
    'ttf-iosevka/ttf-iosevka-custom-1.14.0-1-any.pkg.tar.xz'
    # Extras utils
    'ttf-iosevka/otfcc-0.9.6-1-x86_64.pkg.tar.xz'
    'ttf-iosevka/ttfautohint-1.8.1-1-x86_64.pkg.tar.xz'
    'ttf-iosevka/premake-git-5.0.alpha2.r1194.g8e02b419-1-x86_64.pkg.tar.xz'
)

# Get/Install packages
for package in "${PACKAGES[@]}"
do
    clear
    echo -e "${BLUE}:: Get package: ${CYAN}${package}${OFF}\n" && curl --progress-bar --remote-name ${URL}/${package}
    echo -e "${BLUE}\n:: Install package: ${CYAN}${package##*/}${OFF}\n" && pacman -U ${package##*/} && rm ${package##*/}
    echo -e "${YELLOW}\n:: Press any key to continue...${OFF}"; read
done

