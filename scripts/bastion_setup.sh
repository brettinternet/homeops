#!/bin/bash

#### VARS ####
# Args
PORT=$1
CLIENT_PUBLIC_KEY=$2

# Configuration
SERVER_PORT=$PORT
CLIENT_PORT=$PORT

#### INSTALLATION ####
source ./wireguard_install.sh

SERVER_PUBLIC_IP=$(dig +short myip.opendns.com @resolver1.opendns.com)
CLIENT_PUBLIC_IP=$(printf $SSH_CLIENT | awk '{ print $1}')

# Append additional configuration
cat <<EOT >> /etc/wireguard/wg0.conf
ListenPort = $SERVER_PORT
Address = 10.0.0.1/24

[Peer]
PublicKey = $CLIENT_PUBLIC_KEY
AllowedIPs = 10.0.0.2/32
Endpoint = $CLIENT_PUBLIC_IP:$CLIENT_PORT
EOT

# Start/enable service
systemctl start wg-quick@wg0
systemctl enable wg-quick@wg0

#### OUTPUT ####
# Provide configuration appendage for client
cat <<EOT >> /tmp/wg0.conf.client
ListenPort = $CLIENT_PORT
Address = 10.0.0.2/24

[Peer]
PublicKey = $SERVER_PUBLIC_KEY
AllowedIPs = 10.0.0.1/32
Endpoint = $SERVER_PUBLIC_IP:$SERVER_PORT
EOT