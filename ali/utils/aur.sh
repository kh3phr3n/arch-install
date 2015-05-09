#!/bin/bash

# +--------------------------------------------+
# | File    : aur.sh                           |
# | Email   : rcs[dot]devel[at]gmail[dot]com   |
# | Licence : GPLv3 GNU General Public License |
# +--------------------------------------------+

# Root privileges required
[[ "${UID}" -ne 0 ]] && exit 0

# Packages url
url='arch.tuxico.com/aur'

# Packages list
packages=(
    # Aur helper
    'cower/cower-12-2-x86_64.pkg.tar.xz'
    # Extras fonts
    'ttf-apple/ttf-apple-1.0-1-any.pkg.tar.xz'
    'ttf-seven/ttf-seven-1.0-1-any.pkg.tar.xz'
    'ttf-awesome/ttf-font-awesome-4.3.0-2-any.pkg.tar.xz'
    # i3wm 3rd party
    'i3wm/i3blocks-1.3-2-any.pkg.tar.xz'
    'i3wm/dmenu-xft-4.5-4-x86_64.pkg.tar.xz'
    'i3wm/compton-git-0.1_beta2.59.g23d1dd1-1-x86_64.pkg.tar.xz'
)

# Get/Install packages
for package in "${packages[@]}"
do
    clear
    echo ":: Get ${package}" && curl -O -# ${url}/${package} && echo -e "\n:: Install ${package##*/}" && pacman -U ${package##*/} && rm ${package##*/}
    echo -e "\n:: Press any key to continue..."; read
done

