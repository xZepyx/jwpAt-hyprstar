#!/bin/sh

# install yay
sudo pacman -S --needed git base-devel
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd ..
rm -rf yay

# install packages
yay -S --needed - < ~/hyprstar/packages

# install theme
mkdir -p ~/.themes
unzip -o ~/hyprstar/Catppuccin-Mocha-Standard-Blue-Dark.zip -d ~/hyprstar
cp -r ~/hyprstar/Catppuccin-Mocha-Standard-Blue-Dark ~/.themes/

# enable services
sudo systemctl disable getty@tty2.service
sudo systemctl enable ly@tty2.service

# move configs
cp -r ~/hyprstar/{hypr,kitty,quickshell,scripts,electron-flags.conf} ~/.config/

# make scripts executable
chmod +x ~/.config/scripts/*.sh

# echo complete
echo "install complete! Would you like to reboot? (y/n)"
read -r answer
if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
    reboot
fi
