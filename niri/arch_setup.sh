#!/bin/bash

# systemupdate and needed tools install
sudo pacman -Syyu --noconfirm
sudo pacman -S --needed git base-devel --noconfirm

# install paru
tempdir=$(mktemp -d)
git clone https://aur.archlinux.org/paru.git "$tempdir/paru"
cd "$tempdir/paru"
makepkg -si

# install other apps
paru -S onlyoffice-bin brave-bin curl ripgrep \
    unzip vlc btop bat eza zed ghostty --noconfirm

# starship install
curl -sS https://starship.rs/install.sh | sh
