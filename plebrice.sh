#!/bin/sh
##########################################################
# Name: plebrice.sh
# Purpose: One stop shop to setting up pleb's dotfiles
# Author: Michael Scott (m5cott)
# Created: 2020-11-23
# License: MIT License
##########################################################

# Clone dotfiles
git clone https://github.com/m5cott/plebrice && cd plebrice

gitcf=`ls .config`
gitlf=`ls .local`
localcf="$HOME/.config"
locallf="$HOME/.local"

mv -v .profile ~/ && mv -v .zprofile ~/

for cfitem in $gitcf; do
    [ ! -d $localcf/$cfitem ] && mkdir -vp $localcf/$cfitem || echo "$localcf/$cfitem already exists."
    cp -Rn $cfitem $localcf/
done

for lfitem in $gitlf; do
    [ ! -d $locallf/$lfitem ] && mkdir -vp $locallf/$lfitem || echo "$locallf/$lfitem already exists."
    cp -Rn $lfitem $locallf/
done
