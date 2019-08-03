#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    echo "You need to run this script as root"
    exit 1
fi

if [ "$(systemd-detect-virt)" == "openvz" ]; then
    echo "OpenVZ is not supported"
    exit
fi

if [ "$(systemd-detect-virt)" == "lxc" ]; then
    echo "LXC is not supported (yet)."
    echo "WireGuard can technically run in an LXC container,"
    echo "but the kernel module has to be installed on the host,"
    echo "the container has to be run with some specific parameters"
    echo "and only the tools need to be installed in the container."
    exit
fi

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
    echo "Looks like you aren't running this installer on a Debian, Ubuntu, Fedora, CentOS or Arch Linux system"
    exit 1
fi

# Install WireGuard tools and module
if [[ "$OS" = 'ubuntu' ]]; then
    add-apt-repository -y ppa:wireguard/wireguard
    apt-get update
    apt-get install -y wireguard
elif [[ "$OS" = 'debian' ]]; then
    echo "deb http://deb.debian.org/debian/ unstable main" > /etc/apt/sources.list.d/unstable.list
    printf 'Package: *\nPin: release a=unstable\nPin-Priority: 90\n' > /etc/apt/preferences.d/limit-unstable
    apt update
    apt install -y wireguard
elif [[ "$OS" = 'fedora' ]]; then
    dnf copr enable jdoss/wireguard
    dnf upgrade
    dnf install -y wireguard-dkms wireguard-tools
elif [[ "$OS" = 'centos' ]]; then
    curl -Lo /etc/yum.repos.d/wireguard.repo https://copr.fedorainfracloud.org/coprs/jdoss/wireguard/repo/epel-7/jdoss-wireguard-epel-7.repo
    yum update
    yum install -y epel-release
    yum install -y wireguard-dkms wireguard-tools
elif [[ "$OS" = 'arch' ]]; then
    pacmany -Syu
    pacman -S --noconfirm wireguard-tools
fi

echo "WireGuard installed successfully!"