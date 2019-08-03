#!/bin/bash

#### VARS ####
# Args
PORT=$1
CLIENT_PUBLIC_KEY=$2

# Configuration
SERVER_PORT=$PORT
CLIENT_PORT=$PORT
CLIENT2_PORT=$PORT

PORTS_TO_FORWARD=(
  [80]=80
  [443]=443
  # [53]=53
  # [25]=25
  # [143]=143
  # [587]=587
  # [998]=998
  # [4190]=4190
)

get_address () {
  echo "10.0.0.$1"
}

NETWORK_ADDRESS=$(get_address 0)
SERVER_ADDRESS=$(get_address 1)
CLIENT_ADDRESS=$(get_address 2)
CLIENT2_ADDRESS=$(get_address 3)

#### INSTALLATION ####
source /tmp/wireguard_install.sh

SERVER_PUBLIC_IP=$(dig +short myip.opendns.com @resolver1.opendns.com)
CLIENT_PUBLIC_IP=$(printf $SSH_CLIENT | awk '{ print $1}')

SERVER_PUBLIC_KEY=$(</etc/wireguard/publickey)
CLIENT2_PRIVATE_KEY=$(wg genkey)
CLIENT2_PUBLIC_KEY=$(echo $CLIENT2_PRIVATE_KEY | wg pubkey)

# Append additional configuration on server
cat <<EOT >> /etc/wireguard/wg0.conf
ListenPort = $SERVER_PORT
Address = $SERVER_ADDRESS/24

[Peer]
PublicKey = $CLIENT_PUBLIC_KEY
AllowedIPs = $CLIENT_ADDRESS/32

[Peer]
PublicKey = $CLIENT2_PUBLIC_KEY
AllowedIPs = $CLIENT2_ADDRESS/32
EOT

# # Enable IP forwarding
# sysctl net.ipv4.ip_forward=1

# Start/enable service
chown -v root:root /etc/wireguard/wg0.conf
chmod -v 600 /etc/wireguard/wg0.conf
systemctl start wg-quick@wg0 # or `wg-quick up wg0`
systemctl enable wg-quick@wg0.service

#### OUTPUT ####
# Provide configuration appendage for client
# Note: keep the connection alive since hosted content is behind NAT
# source: https://www.wireguard.com/quickstart/#nat-and-firewall-traversal-persistence
cat <<EOT > /tmp/wg0-client.conf
ListenPort = $CLIENT_PORT
Address = $CLIENT_ADDRESS/24
DNS = $SERVER_ADDRESS

[Peer]
PublicKey = $SERVER_PUBLIC_KEY
AllowedIPs = $SERVER_ADDRESS/32
Endpoint = $SERVER_PUBLIC_IP:$SERVER_PORT
PersistentKeepalive = 25
EOT

# Provide configuration appendage for client2
cat <<EOT > /tmp/wg0-client2.conf
[Interface]
PrivateKey = $CLIENT2_PRIVATE_KEY
ListenPort = $CLIENT2_PORT
Address = $CLIENT2_ADDRESS/24
DNS = $SERVER_ADDRESS

[Peer]
PublicKey = $SERVER_PUBLIC_KEY
AllowedIPs = 0.0.0.0/0
Endpoint = $SERVER_PUBLIC_IP:$SERVER_PORT
EOT

# Enable IP forwarding
sysctl net.ipv4.ip_forward=1

# for KEY in "${!PORTS_TO_FORWARD[@]}"; do iptables -t nat -A PREROUTING -p tcp --dport "$KEY" -j DNAT --to-destination $CLIENT_ADDRESS:"${PORTS_TO_FORWARD[$KEY]}"; iptables -t nat -A POSTROUTING -p tcp -o wg0 -j DNAT --to-destination $SERVER_ADDRESS; done; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
# for KEY in "${!PORTS_TO_FORWARD[@]}"; do iptables -t nat -D PREROUTING -p tcp --dport "$KEY" -j DNAT --to-destination $CLIENT_ADDRESS:"${PORTS_TO_FORWARD[$KEY]}"; iptables -t nat -D POSTROUTING -p tcp -o wg0 -j DNAT --to-destination $SERVER_ADDRESS; done; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

for KEY in ${!PORTS_TO_FORWARD[@]}
do
  iptables -t nat -A PREROUTING -p tcp --dport $KEY -j DNAT --to-destination $CLIENT_ADDRESS:${PORTS_TO_FORWARD[$KEY]}
  iptables -t nat -A POSTROUTING -p tcp -o wg0 -j SNAT --to-source $SERVER_ADDRESS
done

iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

# # Configure firewall rules on the server
# # Track VPN connection
# iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
# iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

# # Allow incoming VPN traffic on the listening port
# iptables -A INPUT -p udp -m udp --dport $PORT -m conntrack --ctstate NEW -j ACCEPT

# # Allow both TCP and UDP recursive DNS traffic
# iptables -A INPUT -s $NETWORK_ADDRESS/24 -p tcp -m tcp --dport 53 -m conntrack --ctstate NEW -j ACCEPT
# iptables -A INPUT -s $NETWORK_ADDRESS/24 -p udp -m udp --dport 53 -m conntrack --ctstate NEW -j ACCEPT

# # Allow forwarding of packets that stay in the VPN tunnel
# iptables -A FORWARD -i wg0 -o wg0 -m conntrack --ctstate NEW -j ACCEPT

# # Set up nat 
# iptables -t nat -A POSTROUTING -s $NETWORK_ADDRESS/24 -o eth0 -j MASQUERADE

# next installs won't work without an apt-get update on a droplet!
apt-get update

# for no input installs - source: https://gist.github.com/alonisser/a2c19f5362c2091ac1e7
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections

# Persist iptable routing across reboots
apt-get install -y iptables-persistent
systemctl enable netfilter-persistent
netfilter-persistent save