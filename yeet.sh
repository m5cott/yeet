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

echo "Thank you for using my script!"
echo "Loading script..."
sleep 1.5

# Gogh themes won't install unless a custom profile has been made.
# The profile can have any name.
read -p "Have you created a custom terminal profile? (y/n) " begin
case $begin in
    [yY])   echo "Awesome! Starting script" ; sleep 1.5;;    
    [nN])   echo "Exiting script..." ; sleep 1.5; exit 1;;
    * )     echo "Invalid input"; sleep 1.5; exit 1;
esac

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
echo 'export ZDOTDIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"' | \
sudo tee -a /etc/zsh/zshenv

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

    if [ "$(ls -A "/sys/class/power_supply")" ]; then
        $priv snap install auto-cpufreq
        $priv auto-cpufreq --install
    fi

    # Quickemu
    mkdir -vp $HOME/.local/src
    cd $HOME/.local/src && git clone https://github.com/wimpysworld/quickemu.git
    ln -s $HOME/.local/src/quickemu/quickemu $HOME/.local/bin/

    if [ $XDG_CURRENT_DESKTOP = "ubuntu:GNOME" ]; then
        $priv apt install gnome-tweaks node-typescript -y
        # Pop Shell
        cd $HOME/.local/src && git clone https://github.com/pop-os/shell
        cd shell && make local-install
    fi
fi

# Debian Gnome Snapd and Pop Shell extension install
if [ $distro = "Debian" ]; then  
    if [ $XDG_CURRENT_DESKTOP = "GNOME" ]; then
        $priv apt install gnome-tweaks node-typescript snapd -y
        
        # Snaps
        $priv snap install core
        $priv snap install qemu-virgil --edge
        $priv snap connect qemu-virgil:audio-record
        $priv snap connect qemu-virgil:kvm
        $priv snap connect qemu-virgil:raw-usb
        $priv snap connect qemu-virgil:removable-media
        
        # Pop Shell
        cd $HOME/.local/src && git clone https://github.com/pop-os/shell
        cd shell && make local-install
    fi
fi

# Gogh Gnome Terminal Color Schemes
if [ `echo $(which gnome-terminal) | cut -d '/' -f 4` = "gnome-terminal" ]; then
    cd $HOME/.local/src && git clone https://github.com/Mayccoll/Gogh.git gogh
    cd gogh/themes && ./gruvbox-dark.sh
fi

# youtube-dl
$priv curl -L https://yt-dl.org/downloads/latest/youtube-dl -o \
/usr/local/bin/youtube-dl
$priv chmod a+rx /usr/local/bin/youtube-dl
if [ $distro = "Ubuntu" ]; then
    $priv ln -s /usr/bin/python3 /usr/bin/python
fi
if [ $distro = "Debian" ]; then
    $priv ln -s /usr/bin/python3 /usr/bin/python
fi

# Debian Debloater
if [ $distro = "Debian" ]; then
    $HOME/yeet-main/./debloater.sh
fi

# Minecraft
read -p "Install minecraft (y/n)? " decide
case $decide in
    [yY])   wget "https://launcher.mojang.com/download/Minecraft.deb" && \
            $priv dpkg -i Minecraft.deb ; $priv apt install -f -y && \
            $priv apt install openjdk-8-jdk -y && rm Minecraft.deb;;
    [nN])   exit;;
    * )     echo "Invalid input." && exit;;
esac

# Telegram
read -p "Install Telegram Desktop (y/n)? " tgram
case $tgram in
    [yY])   wget -O telegram.tar.xz --referer https://desktop.telegram.org \
            'https://telegram.org/dl/desktop/linux' && tar -xf telegram.tar.xz \
            && $priv mv Telegram /opt/ ;;
    [nN])   exit;;
    * )     echo "Invalid input." && exit;;

# VS Code
read -p "Install VS code (y/n)? " vscode
case $vscode in
    [yY])   wget -O code.deb --referer https://code.visualstudio.com \
            'https://go.microsoft.com/fwlink/?LinkID=760868' \
            && $priv dpkg -i code.deb && rm code.deb;;
    [nN])   exit;;
    * )     echo "Invalid input." && exit;;
esac

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
