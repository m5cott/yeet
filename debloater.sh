#!/bin/sh

distro=`lsb_release -is`

if [ $distro = "Debian" ]; then
    echo "Removing some bloat..."
    echo "let's start with some games."
    sleep 1.5

    sudo apt remove --purge gnome-2048 aisleriot atomix gnome-chess \
    five-or-more hitori iagno gnome-klotski lightsoff gnome-mahjongg \
    gnome-mines gnome-nibbles quadrapassel four-in-a-row gnome-robots \
    gnome-sudoku swell-foop tali gnome-taquin gnome-tetravex \
    gnome-games -y

    echo "Gnome is starting to feel lighter..."
    echo "let's get rid of some more."
    sleep 1.5

    sudo apt remove --purge cheese libreoffice-gnome libreoffice-impress \
    libreoffice-writer gnome-clocks gnome-documents gnome-maps gnome-music \
    gnome-sound-recorder gnome-todo shotwell polari gnome-remote-desktop \
    empathy vino vinagre libreoffice-calc libreoffice-common \
    libreoffice-core evolution -y

    echo "WOW that feels better."
    echo "...gonna clean up the rest."
    sleep 1.5

    sudo apt autoremove -y && sudo apt autoclean
else
    echo "Sorry, this application is only for Debian with a standard Gnome \
    install."
fi
