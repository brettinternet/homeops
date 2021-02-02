#!/bin/bash

# Reverse proxy - forward traffic on defined ports to a peer IP
# TODO: for rootless bind to higher ports and forward to them from bastion

IPTABLES_ARG=""

if [ "$1" = "up" ]; then
    IPTABLES_ARG="A"

    # Enable forwarding
    # https://wiki.archlinux.org/index.php/Internet_sharing#Enable_packet_forwarding
    sysctl net.ipv4.ip_forward=1
    sysctl net.ipv6.conf.all.forwarding=1
elif [ "$1" = "down" ]; then
    IPTABLES_ARG="D"

    sysctl net.ipv4.ip_forward=0
    sysctl net.ipv6.conf.all.forwarding=0
else
    echo "Pass 'up' or 'down' as an argument to either append or delete forwarding rules"
    exit 1
fi

# Detect public interface
SERVER_PUB_NIC="$(ip -4 route ls | grep default | grep -Po '(?<=dev )(\S+)' | head -1)"
SERVER_WG_NIC="wg0"

iptables -t nat -$IPTABLES_ARG POSTROUTING -o $SERVER_PUB_NIC -j MASQUERADE
ip6tables -t nat -$IPTABLES_ARG POSTROUTING -o $SERVER_PUB_NIC -j MASQUERADE

: ${PEER_IPV4:=""} # required variables
: ${PEER_IPV6:=""}
: ${HOST_IPV4:=""} # required variables
: ${HOST_IPV6:=""}

if [[ -z "$PEER_IPV4" || -z "$HOST_IPV4" ]]; then
  echo "Error: Vars PEER_IPV4 and HOST_IPV4 have not been defined."
  exit 1
fi

#### TCP ####

# Port mapping to forward ([external/source]: internal/destination)
TCP_PORTS_TO_FORWARD=(
  # HTTP/S
  [80]=80
  [443]=443
  # SSH
#   [2222]=22
  # DNS
  [53]=53
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
    --to-destination $PEER_IPV4:${TCP_PORTS_TO_FORWARD[$KEY]}

  [[ -n "$PEER_IPV6" ]] && \
    ip6tables -t nat -$IPTABLES_ARG PREROUTING \
    -p tcp \
    -i $SERVER_PUB_NIC \
    --dport $KEY \
    -j DNAT \
    --to-destination $PEER_IPV6:${TCP_PORTS_TO_FORWARD[$KEY]}

done

# SNAT
iptables -t nat -$IPTABLES_ARG POSTROUTING \
  -p tcp \
  -o $SERVER_WG_NIC \
  -j SNAT \
  --to-source $HOST_IPV4

[[ -n "$HOST_IPV6" ]] && \
  ip6tables -t nat -$IPTABLES_ARG POSTROUTING \
  -p tcp \
  -o $SERVER_WG_NIC \
  -j SNAT \
  --to-source $HOST_IPV6

#### UDP ####

UDP_PORTS_TO_FORWARD=(
  # DNS
  [53]=53
)

# Forward each port to VPN client via DNAT
# configure response to bastion via SNAT
for KEY in ${!UDP_PORTS_TO_FORWARD[@]}
do
  # DNAT
  iptables -t nat -$IPTABLES_ARG PREROUTING \
    -p udp \
    -i $SERVER_PUB_NIC \
    --dport $KEY \
    -j DNAT \
    --to-destination $PEER_IPV4:${UDP_PORTS_TO_FORWARD[$KEY]}

  [[ -n "$PEER_IPV6" ]] && \
    ip6tables -t nat -$IPTABLES_ARG PREROUTING \
    -p udp \
    -i $SERVER_PUB_NIC \
    --dport $KEY \
    -j DNAT \
    --to-destination $PEER_IPV6:${UDP_PORTS_TO_FORWARD[$KEY]}

done

# SNAT
iptables -t nat -$IPTABLES_ARG POSTROUTING \
  -p udp \
  -o $SERVER_WG_NIC \
  -j SNAT \
  --to-source $HOST_IPV4

[[ -n "$HOST_IPV6" ]] && \
  ip6tables -t nat -$IPTABLES_ARG POSTROUTING \
  -p udp \
  -o $SERVER_WG_NIC \
  -j SNAT \
  --to-source $HOST_IPV6
