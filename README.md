## Container Orchestration

### Run

```sh
docker-compose up -d
```

### Stop

```sh
docker-compose down
```

### Traefik Reverse Proxy

- [ ] Use OAuth [configuration](https://github.com/CVJoint/docker-compose/blob/master/ymlfiles/traefik.yml)

## Bastion Server

- [ ] Handle the server configuration with Ansible instead of scripts

### Terraform

First, install Terraform by pulling the [latest download here](https://www.terraform.io/downloads.html) with `wget`

```sh
apt install unzip

unzip terraform*.zip

mv terraform /usr/local/bin

terraform --version
```

### VPN Server

Next, install [WireGuard](https://www.wireguard.com/) on the VPN client (the homelab server)

```sh
chmod +x scripts/wireguard_install.sh
sudo bash -c ./scripts/wireguard_install.sh
```

Setup bastion server, install WireGuard, copy VPN server configuration to client, run `terraform plan` before `apply` to view changes

```sh
ssh-keygen # if you haven't already

terraform init

do_token=$(grep DO_TOKEN .env | xargs) TF_VAR_do_token=${do_token#*=} TF_VAR_wireguard_client_pub_key=$(sudo cat /etc/wireguard/publickey) terraform apply -auto-approve
```

Append client configuration with fields in `wg0-client.conf` from Terraform `scp` operation

```sh
sudo bash -c "cat wg0-client.conf >> /etc/wireguard/wg0.conf"
```

Use `sed -i.bak -e '3,11d' /etc/wireguard/wg0.conf` to delete the fields added to `/wg0-client.conf` to reset `wg0.conf` and backup your previous config to `wg0.conf.bak`, or use `sed -e '3,$d' file` to remove line 3 through the last line ([source](https://stackoverflow.com/a/2112496/6817437))

Restart client's WireGuard and enable the service
wdw

```sh
systemctl start wg-quick@wg0
systemctl enable wg-quick@wg0
```

#### Other commands

Destroy the bastion server

```sh
do_token=$(grep DO_TOKEN .env | xargs) TF_VAR_do_token=${do_token#*=} terraform destroy -auto-approve
```

#### Resources

- [Interactive WireGuard install script](https://github.com/angristan/wireguard-install)
- [ArchWiki: WireGuard](https://wiki.archlinux.org/index.php/WireGuard)
- [DigitalOcean: WireGuard setup](https://www.digitalocean.com/community/tutorials/how-to-create-a-point-to-point-vpn-with-wireguard-on-ubuntu-16-04)
- [DigitalOcean: Tinc setup](https://www.digitalocean.com/community/tutorials/how-to-install-tinc-and-set-up-a-basic-vpn-on-ubuntu-14-04)
- [Parse .env in Bash](https://gist.github.com/judy2k/7656bfe3b322d669ef75364a46327836)
- Other setup guides - [0](https://wiki.debian.org/Wireguard#Installation), [1](https://git.zx2c4.com/WireGuard/plain/contrib/examples/ncat-client-server/client.sh), [2](https://www.ckn.io/blog/2017/11/14/wireguard-vpn-typical-setup/), [3](https://blog.jessfraz.com/post/installing-and-using-wireguard/), [4](https://angristan.xyz/how-to-setup-vpn-server-wireguard-nat-ipv6/)
- [Unofficial WireGuard docs](https://github.com/pirate/wireguard-docs)

## Todo

- [ ] Install and setup [unbound](https://wiki.archlinux.org/index.php/unbound) ([docker](https://github.com/klutchell/unbound/blob/master/Dockerfile) [discussion](https://www.reddit.com/r/pihole/comments/ah0rx4/awesome_unbound_docker_image_for_an_upstream_dns/))
