#!/bin/bash

# To completely reset the iptables rules - https://wiki.archlinux.org/index.php/Iptables#Resetting_rules

# Detect public interface
SERVER_PUB_NIC="$(ip -4 route ls | grep default | grep -Po '(?<=dev )(\S+)' | head -1)"
SERVER_WG_NIC="wg0"

iptables -t nat -D POSTROUTING -o $SERVER_PUB_NIC -j MASQUERADE
ip6tables -t nat -D POSTROUTING -o $SERVER_PUB_NIC -j MASQUERADE

: ${CLIENT_WG_IPV4:=""} # required variables
: ${CLIENT_WG_IPV6:=""}
: ${SERVER_WG_IPV4:=""} # required variables  
: ${SERVER_WG_IPV6:=""}

if [[ -z "$CLIENT_WG_IPV4" || -z "$SERVER_WG_IPV4" ]]; then
  echo "Error: Vars CLIENT_WG_IPV4 and SERVER_WG_IPV4 have not been defined."
  exit 1
fi

# Port mapping to forward ([external/source]: internal/destination)
PORTS_TO_FORWARD=(
  [80]=80
  [443]=443
)

# Forward each port to VPN client via DNAT
# configure response to bastion via SNAT
for KEY in ${!PORTS_TO_FORWARD[@]}
do
  # DNAT
  iptables -t nat -D PREROUTING -p tcp --dport $KEY -j DNAT --to-destination $CLIENT_WG_IPV4:${PORTS_TO_FORWARD[$KEY]}
  [[ -n "$CLIENT_WG_IPV6" ]] && ip6tables -t nat -D PREROUTING -p tcp --dport $KEY -j DNAT --to-destination $CLIENT_WG_IPV6:${PORTS_TO_FORWARD[$KEY]}

done

# SNAT
iptables -t nat -D POSTROUTING -p tcp -o $SERVER_WG_NIC -j SNAT --to-source $SERVER_WG_IPV4
[[ -n "$SERVER_WG_IPV6" ]] && ip6tables -t nat -D POSTROUTING -p tcp -o $SERVER_WG_NIC -j SNAT --to-source $SERVER_WG_IPV6