#! /bin/bash

## Updating the system

sleep 3

sudo dnf update -y && sudo dnf install figlet fish fastfetch -y

sleep 1

## Installing Starship
figlet "Installing Starship" | sed 's/^/\x1b[36m/' ; echo -e "\x1b[0m"

sleep 4
curl -sS https://starship.rs/install.sh | sh

sleep 1

## Installing Terminal config

figlet "Installing shell configuration" | sed 's/^/\x1b[36m/' ; echo -e "\x1b[0m"

sleep 3

mkdir -p ~/.config

cp -r * ~/.config

sudo mkdir -p /root/.config/
sudo cp -r * /root/.config/

chsh -s /bin/fish

sleep 3

sudo chsh -s /bin/fish
sleep 1


## Installing Fonts

figlet "Installing Fonts" | sed 's/^/\x1b[36m/' ; echo -e "\x1b[0m"
echo "Do you want to install the fonts, Sir ?? [Y/n]: "
read fontans

if [[ $fontans == "y" || $fontans == "Y" ]]; then
  sudo cp -r ~/laxmikant-terminal/fonts/* /usr/share/fonts
  sleep 2
  sudo fc-cache -fv
  sleep 2
  cd ~
  
else
  echo "Skipping font installation..."
fi

## Theming the bootloader
cd ~
figlet "Themeing Bootloader" | sed 's/^/\x1b[36m/' ; echo -e "\x1b[0m"



echo "Do you want to change the Bootloader theme, Sir ?? [Y/n]: "
read grubans

if [[ $grubans == "y" || $grubans == "Y" ]]; then
  cd ~
  git clone https://github.com/ChrisTitusTech/Top-5-Bootloader-Themes
  cd Top-5-Bootloader-Themes
  sudo ./install.sh
  sleep 5
  sudo grub2-mkconfig -o /boot/grub2/grub.cfg
  sleep 2
  cd ~
else
  echo "Okkayy, skipping the Bootloader configuration :-)..."
fi

## Rebooting the System

figlet "Rebooting" | sed 's/^/\x1b[36m/' ; echo -e "\x1b[0m"

#Permission
echo "Would you like the system to reboot, Sir ?? [Y/n]:"
read rebans

if [[ $rebans == "y" || $rebans == "Y" ]]; then
  echo "Noted Sir, the system will reboot in 5 seconds..."
  sleep 5
  sudo reboot
else
  echo "Got it, falling back to prompt..."
fi
