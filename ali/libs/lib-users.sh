#!/bin/bash

setupUsers ()
{
    clear
    title ":: Create new user account\n"

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

createNewUser ()
{
    cecho ":: User  : ${CYAN}${USERNAME}"
    cecho ":: Groups: ${CYAN}${USERGROUPS}"

    title "\n:: Set user password\n"
    # Create user/groups and define password
    useradd -m -s ${USERSHELL} ${USERNAME} && usermod -G ${USERGROUPS} ${USERNAME} && passwd ${USERNAME}
}

configureSudo ()
{
    title "\n:: Configure sudo\n"

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

directories ()
{
    clear
    title ":: Create user's directories\n"

    for directory in "${HOMEDIRS[@]}"
    do
        mkdir -p $homeUser/$directory && cecho ":: Directory created: ${CYAN}$directory/"
    done
    chown -R ${USERNAME}:${USERNAME} $homeUser
}

dotfiles ()
{
    title "\n:: Get user's dotfiles\n"

    for dotfile in bashrc bash_profile bash_aliases
    do
        # Download kh3phr3n's dotfile
        curl --silent --remote-name https://raw.githubusercontent.com/kh3phr3n/dotfiles/master/$dotfile
        # Copy and move dotfile to $homeRoot/$homeUser
        cp $dotfile $homeRoot/.$dotfile && mv $dotfile $homeUser/.$dotfile && cecho ":: File added: ${CYAN}*/.$dotfile"
        # Change owner/group to $USERNAME:$USERNAME
        chown ${USERNAME}:${USERNAME} $homeUser/.$dotfile
    done; pause
}

