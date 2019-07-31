## Bastion Server

### Terraform

First, install Terraform by pulling the [latest download here](https://www.terraform.io/downloads.html) with `wget`

```sh
apt install unzip

unzip terraform*.zip

mv terraform /usr/local/bin

terraform --version
```

### VPN Server

Next, install [WireGuard](https://www.wireguard.com/) on the VPN client (the homelab server) and start the WireGuard service to confirm it runs, and to query the public-key for the next step

```sh
chmod +x scripts/wireguard_install.sh
./scripts/wireguard_install.sh

systemctl start wg-quick@wg0
```

Setup bastion server, install WireGuard, copy VPN server configuration to client, run `terraform plan` before `apply` to view changes

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

#### Resources

- [DigitalOcean: WireGuard setup](https://www.digitalocean.com/community/tutorials/how-to-create-a-point-to-point-vpn-with-wireguard-on-ubuntu-16-04)
- [DigitalOcean: Tinc setup](https://www.digitalocean.com/community/tutorials/how-to-install-tinc-and-set-up-a-basic-vpn-on-ubuntu-14-04)
- [Parse .env in Bash](https://gist.github.com/judy2k/7656bfe3b322d669ef75364a46327836)
