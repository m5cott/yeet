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

lscf=`ls .config`
lslf=`ls .local`
gitcf=".config"
gitlf=".local"
localcf="$HOME/.config"
locallf="$HOME/.local"

mv -v .profile ~/ && mv -v .zprofile ~/

for cfitem in $lscf; do
    [ ! -d $localcf/$cfitem ] && mkdir -vp $localcf/$cfitem || echo "$localcf/$cfitem already exists."
    cp -Rn $gitcf/$cfitem $localcf/
done

for lfitem in $lslf; do
    [ ! -d $locallf/$lfitem ] && mkdir -vp $locallf/$lfitem || echo "$locallf/$lfitem already exists."
    cp -Rn $gitlf/$lfitem $locallf/
done

# misc folder setup
mkdir -vp $HOME/.cache/wget
