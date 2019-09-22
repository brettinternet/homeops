#!/bin/bash
##### NOT USED WITH CURRENT TERRAFORM DEPLOYMENT #####

# Could be used instead of `PostUp` and `PostDown` at setup
# https://wiki.archlinux.org/index.php/Iptables

if [ "$EUID" -ne 0 ]; then
    echo "Error: You need to run this script as root"
    exit 1
fi

# Detect public interface
SERVER_PUB_NIC="$(ip -4 route ls | grep default | grep -Po '(?<=dev )(\S+)' | head -1)"
SERVER_WG_NIC="wg0"

iptables -t nat -A POSTROUTING -o $SERVER_PUB_NIC -j MASQUERADE
ip6tables -t nat -A POSTROUTING -o $SERVER_PUB_NIC -j MASQUERADE

# ufw allow $SERVER_PORT || :

# Enable IP forwarding
# See https://wiki.archlinux.org/index.php/Internet_sharing#Enable_packet_forwarding
# sysctl net.ipv4.ip_forward=1 net.ipv6.conf.all.forwarding=1
cat <<EOT > /etc/sysctl.d/wg.conf
net.ipv4.ip_forward=1
net.ipv6.conf.default.forwarding=1
net.ipv6.conf.all.forwarding=1
EOT

: ${CLIENT_WG_IPV4:=""} # required variables
: ${CLIENT_WG_IPV6:=""}
: ${SERVER_WG_IPV4:=""} # required variables  
: ${SERVER_WG_IPV6:=""}

if [[ -z "$CLIENT_WG_IPV4" || -z "$SERVER_WG_IPV4" ]]; then
  echo "Error: Some variables have not been defined."
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
  # Mailserver
  [25]=25
  [143]=143
  [587]=587
  [993]=993
  [4190]=4190
)

# Forward each port to VPN client via DNAT
# configure response to bastion via SNAT
for KEY in ${!TCP_PORTS_TO_FORWARD[@]}
do
  # DNAT
  iptables -t nat $IPTABLES_ARG PREROUTING \
    -p tcp \
    -i $SERVER_PUB_NIC \
    --dport $KEY \
    -j DNAT \
    --to-destination $CLIENT_WG_IPV4:${TCP_PORTS_TO_FORWARD[$KEY]}
  
  [[ -n "$CLIENT_WG_IPV6" ]] && \
    ip6tables -t nat $IPTABLES_ARG PREROUTING \
    -p tcp \
    -i $SERVER_PUB_NIC \
    --dport $KEY \
    -j DNAT \
    --to-destination $CLIENT_WG_IPV6:${TCP_PORTS_TO_FORWARD[$KEY]}

done

# SNAT
iptables -t nat $IPTABLES_ARG POSTROUTING \
  -p tcp \
  -o $SERVER_WG_NIC \
  -j SNAT \
  --to-source $SERVER_WG_IPV4

[[ -n "$SERVER_WG_IPV6" ]] && \
  ip6tables -t nat $IPTABLES_ARG POSTROUTING \
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
  iptables -t nat $IPTABLES_ARG PREROUTING \
    -p udp \
    -i $SERVER_PUB_NIC \
    --dport $KEY \
    -j DNAT \
    --to-destination $CLIENT_WG_IPV4:${UDP_PORTS_TO_FORWAR[$KEY]}
  
  [[ -n "$CLIENT_WG_IPV6" ]] && \
    ip6tables -t nat $IPTABLES_ARG PREROUTING \
    -p udp \
    -i $SERVER_PUB_NIC \
    --dport $KEY \
    -j DNAT \
    --to-destination $CLIENT_WG_IPV6:${UDP_PORTS_TO_FORWAR[$KEY]}

done

# SNAT
iptables -t nat $IPTABLES_ARG POSTROUTING \
  -p udp \
  -o $SERVER_WG_NIC \
  -j SNAT \
  --to-source $SERVER_WG_IPV4

[[ -n "$SERVER_WG_IPV6" ]] && \
  ip6tables -t nat $IPTABLES_ARG POSTROUTING \
  -p udp \
  -o $SERVER_WG_NIC \
  -j SNAT \
  --to-source $SERVER_WG_IPV6

# ###############
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
# ###############

##### MAKE IPTABLE CHANGES PERSISTENT #####

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

# Some packages provide convenience for making iptable changes persistent
# however, iptables does come with two utilies to help with thi already
# iptables-save > /some/iptables/file # i.e. iptables-save > /etc/iptables/rules.v4
# ip6tables-save > /some/ip6tables/file # filepath depends on your distro
# iptables-restore < /saved/rules

# Install qrencode
if [[ "$OS" = 'ubuntu' ]]; then
    apt-get update
    # for non-interactive installs
    # source: https://gist.github.com/alonisser/a2c19f5362c2091ac1e7
    echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
    echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections
    apt-get install -y iptables-persistent
    systemctl enable netfilter-persistent
    netfilter-persistent save
elif [[ "$OS" = 'debian' ]]; then
    apt update
    echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
    echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections
    apt install -y iptables-persistent
    systemctl enable netfilter-persistent
    netfilter-persistent save
elif [[ "$OS" = 'fedora' ]]; then
    echo "iptables-save is the best method on fedora:
https://fedoraproject.org/wiki/How_to_edit_iptables_rules#Making_changes_persistent"
elif [[ "$OS" = 'centos' ]]; then
    # I don't use centos so this could be wrong! 😬
    yum update
    yum install -y iptables-services
    service iptables save
elif [[ "$OS" = 'arch' ]]; then
    echo "Make your iptable changes persistent:
https://wiki.archlinux.org/index.php/Simple_stateful_firewall#Saving_the_rules"
fi