#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    echo "Error: You need to run this script as root"
    exit 1
fi

SERVER_WG_NIC="wg0"
: ${MOBILE_CONFIG_PATH:=$HOME/$SERVER_WG_NIC-mobile.conf}

# Check OS version
if [[ -e /etc/debian_version ]]; then
    source /etc/os-release
    OS=$ID # debian or ubuntu
elif [[ -e /etc/fedora-release ]]; then
    OS=fedora
elif [[ -e /etc/centos-release ]]; then
    OS=centos
elif [[ -e /etc/arch-release ]]; then
    OS=arch
else
    echo "Error: Looks like you aren't running this installer on a Debian, Ubuntu, Fedora, CentOS or Arch Linux system"
    exit 1
fi

# Install qrencode
if [[ "$OS" = 'ubuntu' ]]; then
    apt-get update
    apt-get install -y qrencode
elif [[ "$OS" = 'debian' ]]; then
    apt update
    apt install -y qrencode
elif [[ "$OS" = 'fedora' ]]; then
    dnf upgrade
    dnf install -y qrencode
elif [[ "$OS" = 'centos' ]]; then
    yum update
    yum install -y qrencode
elif [[ "$OS" = 'arch' ]]; then
    pacmany -Syu
    pacman -S --noconfirm qrencode
fi

echo "qrencode installed successfully!"

# source: https://wiki.debian.org/Wireguard#A3._Import_by_reading_a_QR_code_.28most_secure_method.29
qrencode -t ansiutf8 < $MOBILE_CONFIG_PATH