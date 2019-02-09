#!/usr/bin/env bash

############
##INSTALLS##
############
# vim
# qbittorrent
# fish
# i3
# mysql (mariadb)
# mysql-workbench
# chromium


type pacman > /dev/null
if [[ $? -eq 0 ]]; then
    install="sudo pacman -S "
else
    echo "[-] No pacman, no installs..."
    exit 1
fi

type vim > /dev/null
if [[ $? -ne 0 ]]; then
    $install "vim"
    echo "[+] Vim installed"
fi

type qbittorrent > /dev/null
if [[ $? -ne 0 ]]; then
    $install "qbittorrent"
    echo "[+] Qbittorrent installed"
fi

type fish > /dev/null
if [[ $? -ne 0 ]]; then
    $install "fish"
    echo "[+] Fish installed"
fi

read -p "[?] Set fish as default for $USER [y/n]: " choice
if [[ $choice == "y" ]]; then
    sudo usermod -s /usr/bin/fish $USER
fi

type i3 i3status > /dev/null
if [[ $? -ne 0 ]]; then
    $install "i3-wm"
    $install "i3status"
    $install "dmenu-manjaro"
    $install "i3lock"
    echo "[+] i3 installed"
fi

type mysql > /dev/null
if [[ $? -ne 0 ]]; then
    echo
    read -p "[?] Install mysql [y/n]: " choice
    if [[ $choice == 'y' ]]; then
        $install "mariadb"
        echo "[+] Mariadb (mysql) installed"
    fi
fi

type mysql-workbench > /dev/null
if [[ $? -ne 0 ]]; then
    echo
    read -p "[?] Install mysql-workbench [y/n]: " choice
    if [[ $choice == 'y' ]]; then
        $install "mysql-workbench"
        echo "[+] Mysql-workbench installed"
    fi
fi

type chromium > /dev/null
if [[ $? -ne 0 ]]; then
    read -p "[?] Install chromium [y/n]: " choice
    if [[ $choice == 'y' ]]; then
        $install "chromium"
        echo "[+] Chromium installed"
    fi
fi

type firefox > /dev/null
if [[ $? -eq 0 ]]; then
    read -p "[?] Remove firefox [y/n]: " choice
    if [[ $choice == 'y' ]]; then
        sudo pacman -Rs firefox
        echo "[+] Firefox removed"
    fi
fi

type java javac > /dev/null
if [[ $? -ne 0 ]]; then
    echo "[?] Enter java version to install: "
    printf "\t[%d] %s\n" 1 "java8" 2 "java10" 3 "Exit"
    read -p "[?] Enter number of choice: " choice
    if [[ $choice -eq 1 ]]; then
        $install "jdk8-openjdk"
        echo "[+] Java8 installed "
    elif [[ $choice -eq 2 ]]; then
        $install "jdk10-openjdk"
        echo "[+] Java10 installed"
    fi
fi

read -p "[?] Install javaFX [y/n]: " choice
if [[ $choice == 'y' ]]; then
    $install "java-openjfx"
fi

echo
read -p "[?] Setup vim [y/n]: " choice
if [[ $choice == 'y' ]]; then
    git clone https://github.com/banebo/vim $HOME/vim
    bash $HOME/vim/setup.sh
    if [[ $? -eq 0 ]]; then
        rm -rf $HOME/vim
        printf "\t[+] Done\n"
    fi
fi

echo
read -p "[?] Setup i3 [y/n]: " choice
if [[ $choice == 'y' ]]; then
    git clone https://github.com/banebo/i3 $HOME/i3
    cd $HOME/i3/
    bash setup.sh
    cd ..
    rm -rf i3
    echo "    [+] Done"
fi

type libinput >> /dev/null
if [[ $? -ne 0 ]]; then
    $install "libinput"
fi

type xinput >> /dev/null
if [[ $? -ne 0 ]]; then
    $install "xorg-xinput"
fi
