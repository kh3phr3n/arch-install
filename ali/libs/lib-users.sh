#!/bin/bash

# +--------------------------------------------+
# | File    : lib-users.sh                     |
# | Email   : rcs[dot]devel[at]gmail[dot]com   |
# | Licence : GPLv3 GNU General Public License |
# +--------------------------------------------+

setupUsers ()
{
    title -c ":: Create new user account"

    # Define home location
    local homeUser="/home/${USERNAME}"
    local homeRoot="/root"

    # Create user account and assign groups
    createNewUser
    # Allow group wheel to execute cmds
    configureSudo
    # Create user's directories
    directories
    # Get user's dotfiles
    dotfiles
}

# Create new user and assign groups
createNewUser ()
{
    cecho ":: User  : ${CYAN}${USERNAME}"
    cecho ":: Groups: ${CYAN}${USERGROUPS}"

    title -j ":: Set user password"
    # Create user/groups and define password
    useradd -m -s ${USERSHELL} ${USERNAME} && usermod -G ${USERGROUPS} ${USERNAME} && passwd ${USERNAME}
}

# Allow group wheel to execute any commands
configureSudo ()
{
    title -j ":: Configure sudo"

    if [ -f "/etc/sudoers" ]
    then
        # Create backup
        cp /etc/sudoers /etc/sudoers.backup
        # Allow only group wheel
        sed -i "/%wheel ALL=(ALL) ALL/s/^# //" /etc/sudoers && cecho ":: File updated: ${CYAN}/etc/sudoers"
        # Sudoers default file permissions
        chown -c root:root /etc/sudoers && chmod -c 0440 /etc/sudoers && cecho ":: Permissions updated: ${CYAN}(0440)(root)"
    fi; pause
}

# User's directories
directories ()
{
    title -c ":: Create user's directories"

    for directory in "${HOMEDIRS[@]}"
    do
        mkdir -p $homeUser/$directory && cecho ":: Directory created: ${CYAN}$directory/"
    done
    chown -R ${USERNAME}:${USERNAME} $homeUser
}

# User's dotfiles
dotfiles ()
{
    title -j ":: Get user's dotfiles"

    for dotfile in "${DOTFILES[@]}"
    do
        # Copy and move dotfile to $homeRoot/$homeUser
        cp conf/dot/$dotfile $homeRoot/.$dotfile && cecho ":: File added: ${CYAN}$homeRoot/.$dotfile"
        mv conf/dot/$dotfile $homeUser/.$dotfile && cecho ":: File added: ${CYAN}$homeUser/.$dotfile\n"

        # Change owner/group to $USERNAME:$USERNAME
        chown ${USERNAME}:${USERNAME} $homeUser/.$dotfile
    done; pause
}

