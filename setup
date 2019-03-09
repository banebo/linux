#!/usr/bin/env bash

###############
# LINUX SETUP #
###############

# install required packages
echo "[+] Starting install..."
sudo pacman -S $( < requirements.txt )

# add $HOME/.bin to $PATH
if [[ ! -d $HOME/.bin ]]; then
    mkdir $HOME/.bin
fi
echo "export PATH=$PATH:$HOME/.bin" >> $HOME/.profile

# setup vim
printf "\n[?] Setup vim? [y/n]: "
read choice
if [[ $choice == 'y' ]]; then
    git clone -q https://github.com/banebo/vim $HOME/vim
    ./$HOME/vim/setup
    rm -rf $HOME/vim
fi
printf "\t[+] Done.\n"

# setup i3
printf "[?] Setup i3? [y/n]: "
read $choice
if [[ $choice == 'y' ]]; then
    git clone -q https://github.com/banebo/i3 $HOME/i3
    ./$HOME/i3/setup
    rm -rf $HOME/i3
fi
printf "\t[+] Done."

# set fish as deffault shell
read -p "[?] Set fish as deffault shell? [y/n]: " $choice
if [[ $choice == 'y' ]]; then
    usermod -s /usr/bin/fish $USER
fi
printf "\t[+] Done."

# copy scripts -> $HOME/.bin
cp -r scripts/* $HOME/.bin

# copy fish functions
cp -r fish_functions/* $HOME/.config/fish/functions/

printf "[+] All done."
exit 0
