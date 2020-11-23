#!/bin/sh
##########################################################
# Name: plebrice.sh
# Purpose: One stop shop to setting up pleb's dotfiles
# Author: Michael Scott (m5cott)
# Created: 2020-11-23
# License: MIT License
##########################################################

gitcf=`ls .config`
gitlf=`ls .local`
localcf="$HOME/.config/"
locallf="$HOME/.local/"

# Clone dotfiles
git clone https://github.com/m5cott/plebrice && cd plebrice

mv -v .profile ~/ && mv -v .zprofile ~/

for cfitem in $gitcf; do
    mv cfitem $localcf
done

for lfitem in $gitlf; do
    mv lfitem $locallf
done
