#!/bin/bash
# Requires `sudo`, run with `sudo bash -c "./bastion_setup.sh"`

if [ "$EUID" -ne 0 ]; then
  echo "Running script unelevated"
fi

source ./scripts/wireguard_install.sh

systemctl start wg-quick@wg0

do_token=$(grep DO_TOKEN .env | xargs) TF_VAR_do_token=${do_token#*=} TF_VAR_wireguard_client_pub_key=$(sudo wg show wg0 public-key) terraform apply -var-file=".env" -auto-approve

cat wg0-client.conf >> /etc/wireguard/wg0.conf
rm wg0-client.conf

systemctl restart wg-quick@wg0
systemctl enable wg-quick@wg0.service