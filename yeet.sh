#!/bin/bash
##########################################################
# Name: yeet.sh
# Purpose: One stop shop to setting up an ubuntu system
# Author: Michael Scott (m5cott)
# Created: 2020-11-23
# License: MIT License
##########################################################

# Global Variables
priv="sudo"
file="applications"

# update and upgrade system
$priv apt update && $priv apt upgrade -y

function install {
    which $1 &> /dev/null

    if [ $? -ne 0 ]; then
        echo "Installing: ${1}..."
        $priv apt install $1 -y
    else
        echo "Already installed: ${1}"
    fi
}

# Installing Packages from Main Repo
while IFS= read -r line
do
    install "$line"
done <"$file"

# Basic Firewall setup with ufw
$priv ufw default deny incoming
$priv ufw default allow outgoing
$priv ufw logging on
$priv ufw enable

# Adding VM groups to current user
$priv usermod -aG kvm $USER
$priv usermod -aG libvirt $USER
$priv usermod -aG libvirt-qemu $USER
$priv usermod -aG libvirt-dnsmasq $USER

# Snaps
$priv snap install qemu-virgil --edge
$priv snap connect qemu-virgil:audio-record
$priv snap connect qemu-virgil:kvm
$priv snap connect qemu-virgil:raw-usb
$priv snap connect qemu-virgil:removable-media

# Setting up home dir and dotfiles
mkdir -vp $HOME/.local/bin
./plebrice.sh

# make zshenv read from new .zshrc location
echo 'export ZDOTDIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"' | sudo tee -a /etc/zsh/zshenv

# zsh shell config
mkdir -vp $HOME/.cache/zsh
chsh -s $(which zsh)

# Quickemu
mkdir -vp $HOME/.local/src
cd $HOME/.local/src && git clone https://github.com/wimpysworld/quickemu.git

# Pop Shell
cd $HOME/.local/src && git clone https://github.com/pop-os/shell
cd shell && make local-install

# Gogh Gnome Terminal Color Schemes
cd $HOME/.local/src && git clone https://github.com/Mayccoll/Gogh.git gogh
cd gogh/themes && ./gruvbox-dark.sh

# lf - terminal file manager
curl -L https://github.com/gokcehan/lf/releases/latest/download/lf-linux-amd64.tar.gz | tar xzC ~/.local/bin
mkdir -vp $HOME/.config/lf
curl https://raw.githubusercontent.com/LukeSmithxyz/voidrice/master/.config/lf/lfrc -o $HOME/.config/lf/lfrc
curl https://raw.githubusercontent.com/LukeSmithxyz/voidrice/master/.local/bin/lf-select -o $HOME/.local/bin/lf-select
chmod +x $HOME/.local/bin/lf-select $HOME/.local/bin/rotdir

# TO DO...
# 1. clean up not needed dotfiles and directories in the home folder
# 2. move bash files to .config/bash like directory in case user wanted to revert back to bash
# 3. more to come...

# youtube-dl
#$priv curl -L https://yt-dl.org/downloads/latest/youtube-dl -o /usr/local/bin/youtube-dl
#$priv chmod a+rx /usr/local/bin/youtube-dl
