# Homelab

Don't be fooled, having a home server is really just hundreds of hours of [badblocks](https://wiki.archlinux.org/index.php/Badblocks).

![sudo badblocks -wsv -b 4096 /dev/sda output](./screenshots/badblocks.png)

I tried to fit as many buzzwords into this stack as I could: rootless Podman container orchestration with ZFS volumes, behind a Traefik ingress and OAuth, with Ansible deployment to an Arch Linux server, on a WireGuard network. 🏅

## Setup

Run setup to create local configuration files and install `requirements.yml` from ansible-galaxy.

```sh
make setup
```

Then, edit `inventory` with the server target and `vars/secret.yml` with secrets.

## Deploy

If you're unfamiliar with [Ansible](https://www.ansible.com/), it's absolutely worth the effort to learn the mechanics and employ it in your own homelab.

![book cover: Mommy, Why is There a Server is the House?](./screenshots/stay_at_home_server.jpg)

### Playbooks

See [Working with playbooks](https://docs.ansible.com/ansible/latest/user_guide/playbooks.html) and [ansible-playbook](https://docs.ansible.com/ansible/latest/cli/ansible-playbook.html)

#### Bastion provision

Provision and setup a bastion server with a Digital Ocean Droplet. The setup creates a WireGuard server on the remote host and creates a client configuration on the home server. DNAT and SNAT traffic to and from the home server is routed through the bastion node with iptables.

#### Server setup and upgrade

-   Upgrade pacman and apt cache, packages and the apt distribution.
-   Deploy rootless containers in an orchestration behind Traefik's reverse proxy.
-   Setup [SnapRAID](https://www.snapraid.it/) for JBOD disk parity and configure cron to run a [snapraid-runner](https://github.com/Chronial/snapraid-runner) script to sync parity and periodically check the data for errors.

#### Container composition

Rootless podman support for container images and deployment within [an ansible role](./roles/compose/tasks).

### Traefik Reverse Proxy

-   [x] Use [Traefik OAuth](https://github.com/thomseddon/traefik-forward-auth)
-   [ ] Switch to [KeyCloak](https://www.keycloak.org/index.html) or [Authelia](https://github.com/clems4ever/authelia)
-   [ ] Update to Traefik v2
