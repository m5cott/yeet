#!/bin/bash
##########################################################
# Name: yeet-neon.sh
# Purpose: One stop shop to setting up an KDE Neon system
# Author: Michael Scott (m5cott)
# Created: 2021-01-10
# License: MIT License
##########################################################

# Global Variables
priv="sudo"
file="neonapps"
distro=`lsb_release -is`

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
ufw=`sudo ufw status | cut -d ' ' -f 2`
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
mkdir -vp $HOME/.local/bin $HOME/.local/src
$HOME/yeet-main/./plebrice.sh

# make zshenv read from new .zshrc location
echo 'export ZDOTDIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"' | sudo tee -a /etc/zsh/zshenv

# zsh shell config
mkdir -vp $HOME/.cache/zsh
chsh -s $(which zsh)

if [ $distro = "Neon" ]; then
    $priv snap install qemu-virgil --edge
    $priv snap connect qemu-virgil:audio-record
    $priv snap connect qemu-virgil:kvm
    $priv snap connect qemu-virgil:raw-usb
    $priv snap connect qemu-virgil:removable-media

    # Quickemu
    mkdir -vp $HOME/.local/src
    cd $HOME/.local/src && git clone https://github.com/wimpysworld/quickemu.git
    ln -s $HOME/.local/src/quickemu/quickemu $HOME/.local/bin/
fi

# lf - terminal file manager
curl -L https://github.com/gokcehan/lf/releases/latest/download/lf-linux-amd64.tar.gz | tar xzC ~/.local/bin
mkdir -vp $HOME/.config/lf
curl https://raw.githubusercontent.com/LukeSmithxyz/voidrice/master/.config/lf/lfrc -o $HOME/.config/lf/lfrc
curl https://raw.githubusercontent.com/LukeSmithxyz/voidrice/master/.local/bin/lf-select -o $HOME/.local/bin/lf-select
chmod +x $HOME/.local/bin/lf-select $HOME/.local/bin/rotdir

# youtube-dl
$priv curl -L https://yt-dl.org/downloads/latest/youtube-dl -o /usr/local/bin/youtube-dl
$priv chmod a+rx /usr/local/bin/youtube-dl

if [ $distro = "Neon" ]; then
    $priv ln -s /usr/bin/python3 /usr/bin/python
fi

read -p "Install minecraft (y/n)?" decide
case $decide in
    [yY])   wget "https://launcher.mojang.com/download/Minecraft.deb" && \
            $priv dpkg -i Minecraft.deb ; $priv apt install -f -y && \
            $priv apt install openjdk-8-jdk -y && rm Minecraft.deb exit;;
    [nN])   exit;;
    * )     echo "Invalid input." && exit;;
esac

# VS Code
read -p "Install VS code (y/n)? " vscode
case $vscode in
    [yY])   wget -O code.deb --referer https://code.visualstudio.com 'https://go.microsoft.com/fwlink/?LinkID=760868' && $priv dpkg -i code.deb && rm code.deb exit;;
    [nN])   exit;;
    * )     echo "Invalid input." && exit;;
esac

# clean up
## bash
mkdir -vp $HOME/.config/bash
mv -v $HOME/.bash* $HOME/.config/bash/

## wget
mv $HOME/.wget-hsts $HOME/.cache/wget/wget-hsts