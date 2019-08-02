#!/bin/bash

UBUNTU_FLAVOR_SUBSTR="Ubuntu"
DEBIAN_FLAVOR_SUBSTR="Debian"
RUNTIME_FLAVOR=$(awk -F= '$1=="NAME" { print $2 ;}' /etc/os-release | sed -e 's/^"//' -e 's/"$//')

#### Install ####
if [[ "$RUNTIME_FLAVOR" =~ "$UBUNTU_FLAVOR_SUBSTR" ]]; then
  # Ubuntu - https://www.wireguard.com/install/#ubuntu-module-tools
  add-apt-repository -y ppa:wireguard/wireguard
  apt-get update
  apt-get install -y wireguard-dkms wireguard-tools
elif [[ "$RUNTIME_FLAVOR" =~ "$DEBIAN_FLAVOR_SUBSTR" ]];then
  # Debian - https://wiki.debian.org/Wireguard#Installation
  echo "deb http://deb.debian.org/debian/ unstable main" > /etc/apt/sources.list.d/unstable-wireguard.list
  printf 'Package: *\nPin: release a=unstable\nPin-Priority: 90\n' > /etc/apt/preferences.d/limit-unstable
  apt update
  apt install -y wireguard
else
  echo "This script should run on Ubuntu or Debian hosts"
  exit 1
fi

# Firewall
ufw allow $SERVER_PORT || :

# Create config file
(umask 077 && printf "[Interface]\nPrivateKey = " | sudo tee /etc/wireguard/wg0.conf > /dev/null)

# Configure private/public key
wg genkey | sudo tee -a /etc/wireguard/wg0.conf | wg pubkey | sudo tee /etc/wireguard/publickey
