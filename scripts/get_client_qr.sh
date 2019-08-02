#!/bin/bash

UBUNTU_FLAVOR_SUBSTR="Ubuntu"
DEBIAN_FLAVOR_SUBSTR="Debian"
RUNTIME_FLAVOR=$(awk -F= '$1=="NAME" { print $2 ;}' /etc/os-release | sed -e 's/^"//' -e 's/"$//')

#### Install ####
if [[ "$RUNTIME_FLAVOR" =~ "$UBUNTU_FLAVOR_SUBSTR" ]]; then
  apt-get update
  apt-get install -y qrencode
elif [[ "$RUNTIME_FLAVOR" =~ "$DEBIAN_FLAVOR_SUBSTR" ]];then
  apt update
  apt install -y qrencode
else
  echo "This script should run on Ubuntu or Debian hosts"
  exit 1
fi

# source: https://wiki.debian.org/Wireguard#A3._Import_by_reading_a_QR_code_.28most_secure_method.29
qrencode -t ansiutf8 < ./wg0-client.conf