#!/bin/bash

# +--------------------------------------------+
# | File    : aur.sh                           |
# | Email   : rcs[dot]devel[at]gmail[dot]com   |
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
    # i3wm 3rd party
    'i3wm/i3blocks-1.4-2-x86_64.pkg.tar.xz'
    'i3wm/xcursor-oxygen-5.6.0-2-any.pkg.tar.xz'
    # Extras fonts
    'ttf-apple/ttf-apple-1.0-1-any.pkg.tar.xz'
    'ttf-seven/ttf-seven-1.0-1-any.pkg.tar.xz'
    'ttf-awesome/ttf-font-awesome-4.5.0-2-any.pkg.tar.xz'
)

# Get/Install packages
for package in "${PACKAGES[@]}"
do
    clear
    echo -e "${BLUE}:: Get package: ${CYAN}${package}${OFF}\n" && curl -O -# ${URL}/${package} && echo -e "${BLUE}\n:: Install package: ${CYAN}${package##*/}${OFF}\n" && pacman -U ${package##*/} && rm ${package##*/}
    echo -e "${YELLOW}\n:: Press any key to continue...${OFF}"; read
done

