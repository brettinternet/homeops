## Container Orchestration

Don't be fooled, having a home server is really just hundreds of hours of [badblocks](https://wiki.archlinux.org/index.php/Badblocks):

![sudo badblocks -wsv -b 4096 /dev/sda output](./screenshots/badblocks.png)

## Setup

Run setup to create local configuration files.

```sh
make setup
```

Then, edit `inventory` with the server target and `vars/secret.yml` with secrets.

For localhost, use:

```
[server]
myserver  ansible_connection=local
```

## Playbooks

See [Working with playbooks](https://docs.ansible.com/ansible/latest/user_guide/playbooks.html) and [ansible-playbook](https://docs.ansible.com/ansible/latest/cli/ansible-playbook.html)

### Bastion provision

Provision and setup a bastion server with a Digital Ocean Droplet. The setup creates a WireGuard server on the bastion host and creates a client configuration on the home server. DNAT and SNAT traffic to and from the home server is routed through the bastion host with iptables.

### Upgrade

Upgrade Arch Linux and Ubuntu cache, packages and distribution.

### Server setup

Deploy docker compose configuration files and run the rootless container orchestration.

Setup [SnapRAID](https://www.snapraid.it/) for JBOD disk backup and configure cron to run a [snapraid-runner](https://github.com/Chronial/snapraid-runner) script to run a parity sync and periodically check the data and parity for errors.

## Docker orchestration

### Traefik Reverse Proxy

-   [x] Use OAuth [configuration](https://github.com/CVJoint/docker-compose/blob/master/ymlfiles/traefik.yml)
-   [ ] Switch to [KeyCloak](https://www.keycloak.org/index.html) or [Authelia](https://github.com/clems4ever/authelia)
-   [ ] Update to Traefik v2

### Debug

You may consider debugging your homelab and VPN traffic forwarding with [this simple container](https://github.com/containous/whoami).

```sh
docker run --rm -it -p 10.0.0.2:80:80 --name iamfoo containous/whoami
```
