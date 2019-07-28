## Bastion Server

### VPN Server

First, install Terraform

Install [WireGuard](https://www.wireguard.com/) on the VPN client (the homelab server) and start the WireGuard service to confirm it runs, and to query the public-key in the next step

```sh
chmod +x scripts/wireguard_install.sh
./scripts/wireguard_install.sh

systemctl start wg-quick@wg0
```

Setup bastion server, install WireGuard, copy VPN server configuration to client ([1](https://gist.github.com/judy2k/7656bfe3b322d669ef75364a46327836)), run `terraform plan` before `apply` to view changes

```sh
do_token=$(grep DO_TOKEN .env | xargs) TF_VAR_do_token=${do_token#*=} TF_VAR_wireguard_client_pub_key=$(sudo wg show wg0 public-key) terraform apply -var-file=".env" -auto-approve
```

Append client configuration with fields in `wg0.conf.client` from Terraform `scp` operation

```sh
sudo bash -c "cat wg0.conf.client >> /etc/wireguard/wg0.conf"
```

Restart client's WireGuard and enable the service

```sh
systemctl restart wg-quick@wg0
systemctl enable wg-quick@wg0
```
