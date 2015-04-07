#!/usr/bin/env python
# -*- coding: Utf-8 -*-

# +--------------------------------------------+
# | File    : hdd.py                           |
# | Email   : rcs[dot]devel[at]gmail[dot]com   |
# | Licence : GPLv3 GNU General Public License |
# +--------------------------------------------+

# Modules
import os, sys

# Terminal Colors
colors = { 'None' : '\033[0m', 'Blue' : '\033[1;34m', 'Red' : '\033[1;31m' }

# Function definitions
def cprint(text, color='None'):
    if color in colors:
        print "{0}{1}{2}".format(colors[color], text, colors['None'])

def pause():
    raw_input('\n:: Press any key to continue\n')

def eraseDiskMenu():
    cprint(':: Running EraseDiskMenu Utility...', 'Blue')
    cprint(':: /!\  Please wait disk erasing...', 'Red')
    os.system('pmagic_erase_menu &>/dev/null')
    pause()

def smartControl():
    cprint(':: Running GSmartControl Utility...', 'Blue')
    os.system('gsmartcontrol &>/dev/null')
    pause()

def newDisk():
    cprint(':: Insert ArchLinux ISO...', 'Blue')
    pause()

def restart():
    cprint(':: Restart System...', 'Blue')
    os.system('sleep 3 && reboot')

# Main program
if __name__ == '__main__':
    os.system('clear')
    eraseDiskMenu()
    smartControl()
    newDisk()
    restart()

