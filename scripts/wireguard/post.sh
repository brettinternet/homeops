#!/bin/bash
# This is a specific configuration for my
# WireGuard server to function as a bastion
# server that routes public traffic to a Traefik
# reverse proxy

IPTABLES_ARG=""

if [ "$1" = "up" ]; then
  IPTABLES_ARG="A"
elif [ "$1" = "down" ]; then
  IPTABLES_ARG="D"
fi

# Detect public interface
SERVER_PUB_NIC="$(ip -4 route ls | grep default | grep -Po '(?<=dev )(\S+)' | head -1)"
SERVER_WG_NIC="wg0"

iptables -t nat -$IPTABLES_ARG POSTROUTING -o $SERVER_PUB_NIC -j MASQUERADE
ip6tables -t nat -$IPTABLES_ARG POSTROUTING -o $SERVER_PUB_NIC -j MASQUERADE

: ${CLIENT_WG_IPV4:=""} # required variables
: ${CLIENT_WG_IPV6:=""}
: ${SERVER_WG_IPV4:=""} # required variables  
: ${SERVER_WG_IPV6:=""}

if [[ -z "$CLIENT_WG_IPV4" || -z "$SERVER_WG_IPV4" ]]; then
  echo "Error: Vars CLIENT_WG_IPV4 and SERVER_WG_IPV4 have not been defined."
  exit 1
fi

# Port mapping to forward ([external/source]: internal/destination)
### TCP
TCP_PORTS_TO_FORWARD=(
  # HTTP/S
  [80]=80
  [443]=443
  # SSH
  [2222]=22
  # DNS
  [53]=53
  # MAILCOW
  # https://mailcow.github.io/mailcow-dockerized-docs/prerequisite-system/#default-ports
  [25]=25
  [465]=465
  [587]=587
  [143]=143
  [993]=993
  [110]=110
  [995]=995
  [4190]=4190
)

# Forward each port to VPN client via DNAT
# configure response to bastion via SNAT
for KEY in ${!TCP_PORTS_TO_FORWARD[@]}
do
  # DNAT
  iptables -t nat -$IPTABLES_ARG PREROUTING \
    -p tcp \
    -i $SERVER_PUB_NIC \
    --dport $KEY \
    -j DNAT \
    --to-destination $CLIENT_WG_IPV4:${TCP_PORTS_TO_FORWARD[$KEY]}
  
  [[ -n "$CLIENT_WG_IPV6" ]] && \
    ip6tables -t nat -$IPTABLES_ARG PREROUTING \
    -p tcp \
    -i $SERVER_PUB_NIC \
    --dport $KEY \
    -j DNAT \
    --to-destination $CLIENT_WG_IPV6:${TCP_PORTS_TO_FORWARD[$KEY]}

done

# SNAT
iptables -t nat -$IPTABLES_ARG POSTROUTING \
  -p tcp \
  -o $SERVER_WG_NIC \
  -j SNAT \
  --to-source $SERVER_WG_IPV4

[[ -n "$SERVER_WG_IPV6" ]] && \
  ip6tables -t nat -$IPTABLES_ARG POSTROUTING \
  -p tcp \
  -o $SERVER_WG_NIC \
  -j SNAT \
  --to-source $SERVER_WG_IPV6

### UDP
UDP_PORTS_TO_FORWAR=(
  # DNS
  [53]=53
)

# Forward each port to VPN client via DNAT
# configure response to bastion via SNAT
for KEY in ${!UDP_PORTS_TO_FORWAR[@]}
do
  # DNAT
  iptables -t nat -$IPTABLES_ARG PREROUTING \
    -p udp \
    -i $SERVER_PUB_NIC \
    --dport $KEY \
    -j DNAT \
    --to-destination $CLIENT_WG_IPV4:${UDP_PORTS_TO_FORWAR[$KEY]}
  
  [[ -n "$CLIENT_WG_IPV6" ]] && \
    ip6tables -t nat -$IPTABLES_ARG PREROUTING \
    -p udp \
    -i $SERVER_PUB_NIC \
    --dport $KEY \
    -j DNAT \
    --to-destination $CLIENT_WG_IPV6:${UDP_PORTS_TO_FORWAR[$KEY]}

done

# SNAT
iptables -t nat -$IPTABLES_ARG POSTROUTING \
  -p udp \
  -o $SERVER_WG_NIC \
  -j SNAT \
  --to-source $SERVER_WG_IPV4

[[ -n "$SERVER_WG_IPV6" ]] && \
  ip6tables -t nat -$IPTABLES_ARG POSTROUTING \
  -p udp \
  -o $SERVER_WG_NIC \
  -j SNAT \
  --to-source $SERVER_WG_IPV6