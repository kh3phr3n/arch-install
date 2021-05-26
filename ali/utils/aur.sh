#!/bin/bash

# Root privileges required
[[ "${UID}" -ne 0 ]] && exit 0 || clear

# Colors
OFF='\e[0m'
CYAN='\e[0;36m'
BLUE='\e[1;34m'
YELLOW='\e[1;33m'

# Packages url
URL='https://aur.nixsys.fr'

# Packages list
PACKAGES=(
    # Extras apps
    'i3wm/xcursor-oxygen-5.16.1-1-any.pkg.tar.xz'
    'i3wm/postman-bin-7.19.1-1-x86_64.pkg.tar.zst'
    'i3wm/rxvt-unicode-patched-9.22-11-x86_64.pkg.tar.zst'
    'i3wm/qt5-styleplugins-5.0.0.20170311-22-x86_64.pkg.tar.zst'
    # System apps
    'auracle/auracle-git-r313.b5b41d7-1-x86_64.pkg.tar.zst'
    # Extras fonts
    'ttf-nonfree/ttf-nonfree-1.0-1-any.pkg.tar.zst'
    'ttf-pt-public/ttf-pt-public-1.0-1-any.pkg.tar.xz'
    'ttf-awesome/ttf-font-awesome-4-4.7.0-5-any.pkg.tar.xz'
    'ttf-iosevka/ttf-iosevka-custom-2.3.3-1-any.pkg.tar.zst'
    # Extras fonts utils
    'ttf-iosevka/ttfautohint-1.8.3-1-x86_64.pkg.tar.xz'
    'ttf-iosevka/otfcc-0.10.3.alpha-1-x86_64.pkg.tar.xz'
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

