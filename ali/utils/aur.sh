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
    # Extras utils
    'utils/otfcc-0.10.4-2-x86_64.pkg.tar.zst'
    'utils/ttfautohint-1.8.3-1-x86_64.pkg.tar.zst'

    # Extras fonts
    'fonts/ttf-nonfree-1.0-1-any.pkg.tar.zst'
    'fonts/ttf-pt-public-1.0-1-any.pkg.tar.zst'
    'fonts/ttf-font-awesome-4-4.7.0-5-any.pkg.tar.zst'
    'fonts/ttf-iosevka-custom-2.3.3-1-any.pkg.tar.zst'

    # Extras apps
    'apps/postman-bin-8.5.1-2-x86_64.pkg.tar.zst'
    'apps/auracle-git-r313.b5b41d7-1-x86_64.pkg.tar.zst'

    # Theme goodies
    'goodies/xcursor-oxygen-5.21.1-1-any.pkg.tar.zst'
    'goodies/qt5-styleplugins-5.0.0.20170311-26-x86_64.pkg.tar.zst'
)

# Get/Install packages
for package in "${PACKAGES[@]}"
do
    clear
    echo -e "${BLUE}:: Get package: ${CYAN}${package}${OFF}\n" && curl --progress-bar --remote-name ${URL}/${package}
    echo -e "${BLUE}\n:: Install package: ${CYAN}${package##*/}${OFF}\n" && pacman -U ${package##*/} && rm ${package##*/}
    echo -e "${YELLOW}\n:: Press any key to continue...${OFF}"; read
done

