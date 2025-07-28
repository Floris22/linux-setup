#!/bin/bash

echo "Updating system..."
echo

sudo pacman -Syy --noconfirm
sudo pacman -S archlinux-keyring --noconfirm
sudo pacman -Syu --noconfirm

echo "System updated"
echo
echo "Downloading Yay"

sudo pacman -S --needed git base-devel --noconfirm

tempdir=$(mktemp -d)
git clone https://aur.archlinux.org/yay.git "$tempdir/yay"
cd "$tempdir/yay"
makepkg -si

echo "Install succesfull, cleaning up"
echo

rm -rf "$tempdir"


echo "Installing packages"

yay -S cursor-bin onlyoffice-bin hoppscotch-bin clipse brave-bin --noconfirm

sudo pacman -S neovim fuse2 unzip curl wget vlc ufw btop \
  docker docker-compose docker-buildx firefox udiskie \
  waybar libpulse libappindicator-gtk3 libdbusmenu-gtk3 upower \
  hyprsunset hyprpaper --noconfirm

sudo usermod -aG docker $USER

echo "Adding config files"

mkdir -p ~/.config/hypr/
rm ~/.config/hypr/*

mv ./hypr/* ~/.config/hypr/

