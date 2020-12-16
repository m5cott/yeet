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
distro=`lsb_release -is`
ufw=`$priv ufw status | cut -d ' ' -f 2`

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
if [ $ufw != "active" ]; then
    $priv ufw default deny incoming
    $priv ufw default allow outgoing
    $priv ufw logging on
    $priv ufw enable
fi

# Adding VM groups to current user
$priv usermod -aG kvm $USER
$priv usermod -aG libvirt $USER
$priv usermod -aG libvirt-qemu $USER
$priv usermod -aG libvirt-dnsmasq $USER

# Setting up home dir and dotfiles
mkdir -vp $HOME/.local/bin
./plebrice.sh

# make zshenv read from new .zshrc location
echo 'export ZDOTDIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"' | sudo tee -a /etc/zsh/zshenv

# zsh shell config
mkdir -vp $HOME/.cache/zsh
chsh -s $(which zsh)

# Qemu Virgil, Quickemu && Pop Shell setup on Ubuntu 20.04+
if [ $distro = "Ubuntu" ]; then

    # Qemu Virgil Snap
    $priv snap install qemu-virgil --edge
    $priv snap connect qemu-virgil:audio-record
    $priv snap connect qemu-virgil:kvm
    $priv snap connect qemu-virgil:raw-usb
    $priv snap connect qemu-virgil:removable-media

    # Pop Shell
    cd $HOME/.local/src && git clone https://github.com/pop-os/shell
    cd shell && make local-install

    # Quickemu
    mkdir -vp $HOME/.local/src
    cd $HOME/.local/src && git clone https://github.com/wimpysworld/quickemu.git
    ln -s $HOME/.local/src/quickemu/quickemu $HOME/.local/bin/

fi

# Gogh Gnome Terminal Color Schemes
cd $HOME/.local/src && git clone https://github.com/Mayccoll/Gogh.git gogh
cd gogh/themes && ./gruvbox-dark.sh

# lf - terminal file manager
curl -L https://github.com/gokcehan/lf/releases/latest/download/lf-linux-amd64.tar.gz | tar xzC ~/.local/bin
mkdir -vp $HOME/.config/lf
curl https://raw.githubusercontent.com/LukeSmithxyz/voidrice/master/.config/lf/lfrc -o $HOME/.config/lf/lfrc
curl https://raw.githubusercontent.com/LukeSmithxyz/voidrice/master/.local/bin/lf-select -o $HOME/.local/bin/lf-select
chmod +x $HOME/.local/bin/lf-select $HOME/.local/bin/rotdir

# youtube-dl
$priv curl -L https://yt-dl.org/downloads/latest/youtube-dl -o /usr/local/bin/youtube-dl
$priv chmod a+rx /usr/local/bin/youtube-dl
if [ $distro = "Ubuntu" ]; then
    $priv ln -s /usr/bin/python3 /usr/bin/python
fi

# clean up
## bash
mkdir -vp $HOME/.config/bash
mv -v $HOME/.bash* $HOME/.config/bash/

## wget
mv $HOME/.wget-hsts $HOME/.cache/wget/wget-hsts

## remove downloaded yeet repo
cd $HOME
rm -rf yeet-main && rm main.zip

# TO DO...
