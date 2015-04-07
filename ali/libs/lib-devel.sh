#!/bin/bash

# +--------------------------------------------+
# | File    : lib-devel.sh                     |
# | Email   : rcs[dot]devel[at]gmail[dot]com   |
# | Licence : GPLv3 GNU General Public License |
# +--------------------------------------------+

installDevParty ()
{
    title -c ":: Install development tools"

    # Sync and upgrade system
    updatePkg

    # Install Development Tools
    [[ "${#DEVPKGS[@]}" -gt 0 ]] && installPkg "${DEVPKGS[@]}"
}

