#!/bin/bash

UBUNTU_FLAVOR_SUBSTR="Ubuntu"
DEBIAN_FLAVOR_SUBSTR="Debian"
RUNTIME_FLAVOR=$(awk -F= '$1=="NAME" { print $2 ;}' /etc/os-release | sed -e 's/^"//' -e 's/"$//')

#### Install ####
if [[ "$RUNTIME_FLAVOR" =~ "$UBUNTU_FLAVOR_SUBSTR" ]]; then
  add-apt-repository -y ppa:wireguard/wireguard
  apt-get update
  apt-get install -y wireguard-dkms wireguard-tools
elif [[ "$RUNTIME_FLAVOR" =~ "$DEBIAN_FLAVOR_SUBSTR" ]];then
  echo "deb http://deb.debian.org/debian/ unstable main" > /etc/apt/sources.list.d/unstable-wireguard.list
  printf 'Package: *\nPin: release a=unstable\nPin-Priority: 90\n' > /etc/apt/preferences.d/limit-unstable
  apt update
  apt install -y wireguard
else
  printf "This script should run on Ubuntu or Debian hosts"
  exit 1
fi

# Firewall
ufw allow $SERVER_PORT

# Configure private/public key
(umask 077 && printf "[Interface]\nPrivateKey = " | sudo tee /etc/wireguard/wg0.conf > /dev/null)

SERVER_PUBLIC_KEY=$(wg genkey | sudo tee -a /etc/wireguard/wg0.conf | wg pubkey | sudo tee /etc/wireguard/publickey)
