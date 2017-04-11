#!/bin/bash

# +--------------------------------------------+
# | File    : aur.sh                           |
# | Email   : rc[dot]dev[at]tuxico[dot]com     |
# | Licence : GPLv3 GNU General Public License |
# +--------------------------------------------+

# Root privileges required
[[ "${UID}" -ne 0 ]] && exit 0 || clear

# Colors
OFF='\e[0m'
CYAN='\e[0;36m'
BLUE='\e[1;34m'
YELLOW='\e[1;33m'

# Packages url
URL='arch.tuxico.com/aur'

# Packages list
PACKAGES=(
    # Aur helper
    'cower/cower-16-1-x86_64.pkg.tar.xz'
    # Extras i3wm
    'i3wm/xcursor-oxygen-5.9.1-1-any.pkg.tar.xz'
    'i3wm/qt5-styleplugins-5.0.0-7-x86_64.pkg.tar.xz'
    # Extras fonts
    'ttf-nonfree/ttf-nonfree-1.0-1-any.pkg.tar.xz'
    'ttf-awesome/ttf-font-awesome-4.7.0-1-any.pkg.tar.xz'
    'ttf-iosevka/ttf-iosevka-custom-1.12.4-1-any.pkg.tar.xz'
    # Extras utils
    'ttf-iosevka/otfcc-0.6.3-1-x86_64.pkg.tar.xz'
    'ttf-iosevka/ttfautohint-1.6-1-x86_64.pkg.tar.xz'
    'ttf-iosevka/premake-git-5.0.alpha2.r898.gad6e49c1-1-x86_64.pkg.tar.xz'
)

# Get/Install packages
for package in "${PACKAGES[@]}"
do
    clear
    echo -e "${BLUE}:: Get package: ${CYAN}${package}${OFF}\n" && curl -O -# ${URL}/${package} && echo -e "${BLUE}\n:: Install package: ${CYAN}${package##*/}${OFF}\n" && pacman -U ${package##*/} && rm ${package##*/}
    echo -e "${YELLOW}\n:: Press any key to continue...${OFF}"; read
done

