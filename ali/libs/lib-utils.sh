#!/bin/bash

# +--------------------------------------------+
# | File    : lib-io.sh                        |
# | Email   : rcs[dot]devel[at]gmail[dot]com   |
# | Licence : GPLv3 GNU General Public License |
# +--------------------------------------------+

# Initialize terminal colors
colors ()
{
    # Regular Colors
    PURPLE='\e[0;35m'
    YELLOW='\e[1;33m'
    GREEN='\e[0;32m'
    CYAN='\e[0;36m'
    BLUE='\e[1;34m'
    RED='\e[0;31m'
    OFF='\e[0m'
}

# Display colored message
# $1: Message
# $2: Color
cecho ()
{
    case "$2" in
        Purple ) echo -e "${PURPLE}$1 ${OFF}" ;;
        Yellow ) echo -e "${YELLOW}$1 ${OFF}" ;;
        Green  ) echo -e "${GREEN}$1  ${OFF}" ;;
        Cyan   ) echo -e "${CYAN}$1   ${OFF}" ;;
        Blue   ) echo -e "${BLUE}$1   ${OFF}" ;;
        Red    ) echo -e "${RED}$1    ${OFF}" ;;
        *      ) echo -e "${OFF}$1    ${OFF}" ;;
    esac
}

# Display message with pause
# $1: Option
# $2: Message
title ()
{
    local option="$1" && local message="$2"

    case "$option" in
        -t ) cecho "$message" Blue            ;;
        -n ) cecho "$message\n" Blue          ;;
        -j ) cecho "\n$message\n" Blue        ;;
        -c ) clear && cecho "$message\n" Blue ;;
    esac
}

# Used by 'select' instruction
# $1: Choice
# $2: List of Choices
contains ()
{
    #check if an element exist in a string
    for e in "${@:2}"; do [[ $e == $1 ]] && break; done
}

pause ()
{
    cecho "\n:: Press any key to continue..." Yellow; read
}

