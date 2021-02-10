# Homelab

Don't be fooled, having a home server is really just hundreds of hours of [badblocks](https://wiki.archlinux.org/index.php/Badblocks).

![sudo badblocks -wsv -b 4096 /dev/sda output](./screenshots/badblocks.png)

I tried to fit as many buzzwords into this stack as I could: rootless Podman container orchestration with ZFS volumes, behind a Traefik ingress and OAuth, with Ansible deployment to an Arch Linux server, on a WireGuard network. 🏅

This infrastructure as code is written for me because I'm forgetful. But perhaps it'll help you develop your own server architecture.

## Setup

Run setup to create local configuration files and install `requirements.yml` from ansible-galaxy.

```sh
make setup
```

Then, edit `inventory.yml` with the target vars and secrets. See [example.inventory.yml](./example.inventory.yml) for what that looks like.

## Deploy

If you're unfamiliar with [Ansible](https://www.ansible.com/), it's absolutely worth the effort to learn the mechanics and employ it in your own homelab.

### Playbooks

See [Working with playbooks](https://docs.ansible.com/ansible/latest/user_guide/playbooks.html) and [ansible-playbook](https://docs.ansible.com/ansible/latest/cli/ansible-playbook.html)

#### Bastion provision

Provision and setup a bastion server with a Digital Ocean Droplet. The setup creates a WireGuard server on the remote host and creates a client configuration on the home server. DNAT and SNAT traffic to and from the home server is routed through the bastion node with iptables.

#### Server setup and upgrade

- Upgrade pacman and apt cache, packages and the apt distribution.
- Deploy rootless containers in an orchestration behind Traefik's reverse proxy.
- Setup [SnapRAID](https://www.snapraid.it/) for JBOD disk parity and configure cron to run a [snapraid-runner](https://github.com/Chronial/snapraid-runner) script to sync parity and periodically check the data for errors.

#### Container composition

Rootless podman support for container images and deployment within [an ansible role](./roles/compose/tasks).

## Hardware

![book cover: Mommy, Why is There a Server is the House?](./screenshots/stay_at_home_server.jpg)

### Storage

#### Inexpensive PCIe SATA

I purchased a [Dell Perc H310](https://www.ebay.com/sch/i.html?_nkw=Dell+Perc+H310+SATA) a long while back. Mine did come from overseas, but it turned out to be legit. [This video](https://www.youtube.com/watch?v=EOcpp-GdhKo) shows how it can be flashed to an LSI 9211-8i IT (see also [1](https://www.servethehome.com/ibm-serveraid-m1015-part-4/), [2](https://www.truenas.com/community/threads/confused-about-that-lsi-card-join-the-crowd.11901/)).

#### 2.5" drive stackers

[These printable stackers](https://www.thingiverse.com/thing:582781) are great for stacking SSDs in a homelab.

## Software

#### SSH

Here's a nice convenience for setting up `authorized_keys` that both Github and Gitlab offer:

```sh
curl https://github.com/<username>.keys -o authorized_keys
```

You could pipe the output to `sed` to only grab a specific line `sed '4!d'`.

#### Check disks

Use [badblocks](https://wiki.archlinux.org/index.php/Badblocks) to check the status of new disks.

This command will take a long time for larger drives, but it's worth it to be thorough before determining whether to make a return. This is a destructive test, so it's probably best to use `/dev/disk/by-id` to be certain you're targeting the correct drive.

Use `tune2fs -l <partition>` as the root user to identify the block size.

```sh
sudo badblocks -wsv -b 4096 /dev/sda > sda_badblocks.txt
```

Here's some additional advice from [/r/DataHoarders](https://www.reddit.com/r/DataHoarder/comments/7seion/new_drive_first_steps_you_take_before_using/).

#### JBOD

[MergerFS](https://github.com/trapexit/mergerfs) is a union filesystem for pooling drives together. It's a great pair with SnapRAID.

```sh
mkdir /mnt/disk{1,2,3,4}
mkdir /mnt/parity1 # adjust this command based on your parity setup
mkdir /mnt/storage # this will be the main mergerfs mount point (a collection of your drives)
```

Mount drives to these folders, then add `/etc/fstab` entries by ID.

```sh
ls /dev/disk/by-id
```

You must also include an entry for the MergerFS union, such as:

```
/mnt/disk* /mnt/storage fuse.mergerfs allow_other,use_ino,cache.files=partial,dropcacheonclose=true,category.create=mfs,fsname=mergerfs,minfreespace=10G 0 0
```

See also [perfectmediaserver: MergerFS](https://perfectmediaserver.com/installation/manual-install/#mergerfs)

#### mkinitcpio

Be sure to add `zfs` and `resume`

```
HOOKS=(base udev autodetect modconf block filesystems keyboard zfs resume fsck)
```

Then, [regenerate the image](https://wiki.archlinux.org/index.php/Mkinitcpio#Image_creation_and_activation).

#### ZFS

Install `zfs-dkms-git` and `zfs-utils-git`, and be sure to have `linux-headers` installed for dkms to work.

#### OS Installation

[Ventoy](https://www.ventoy.net/en/index.html) seems like an interesting project. Some of my ARM hardware requires Ubuntu, so it'd be nice to have a single USB to manage installations.
