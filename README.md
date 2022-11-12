# Homelab

[![Lint](https://github.com/brettinternet/homelab/actions/workflows/lint.yaml/badge.svg)](https://github.com/brettinternet/homelab/actions/workflows/lint.yaml)

Don't be fooled, having a home server is really just hundreds of hours of [badblocks](https://wiki.archlinux.org/index.php/Badblocks).

![sudo badblocks -wsv -b 4096 /dev/sda output](./files/badblocks.png)

## Features

- Lots of [self-hosted services](./cluster/apps)
- [Flux](https://toolkit.fluxcd.io/) GitOps with this repository ([cluster directory](./cluster))
- Ansible node provisioning and [K3s setup](https://github.com/PyratLabs/ansible-role-k3s) (Ansible [roles](./provision/ansible/roles) and [playbooks](./provision/ansible))
- Terraform DNS records ([terraform](./provision/terraform))
- [SOPS](https://github.com/mozilla/sops) secrets stored in Git
- [Renovate bot](https://github.com/renovatebot/renovate) dependency updates
- WireGuard VPN pod gateway via paid service
- WireGuard VPN proxy hosted on VPS
- [Cloudflared HTTP tunnel](https://github.com/cloudflare/cloudflared)
- [K8s gateway](https://github.com/ori-edge/k8s_gateway) for local DNS resolution to cluster and [NGINX ingress controller](https://kubernetes.github.io/ingress-nginx/)
- Both internal & external services with a service [gateway](https://github.com/ori-edge/k8s_gateway/)
- OIDC [authentication](https://www.authelia.com/configuration/identity-providers/open-id-connect/) with [LDAP](https://github.com/nitnelave/lldap)
- Automatic Cloudflare DNS updates ([ddns cronjob](./cluster/apps/networking/cloudflare-ddns))
- [MetalLB](https://metallb.universe.tf/) bare metal K8s network loadbalancing
- [Calico](https://www.tigera.io/project-calico/) CNI
- [ZFS](https://wiki.archlinux.org/index.php/ZFS)
- JBOD [mergerfs](https://github.com/trapexit/mergerfs) union NFS with [SnapRAID](https://www.snapraid.it) backup for low-touch media files ([snapraid-runner cluster cronjob](./cluster/apps/media/snapraid-runner))
- [Restic](https://restic.net) backups to remote and local buckets ([backup namespace](./cluster/apps/backup))
- [go-task](https://taskfile.dev) shorthand for useful commands ([Taskfile](./Taskfile.yaml) and [taskfiles](./.taskfiles))

## Usage

Setup and usage is inspired heavily by [this homelab gitops template](https://github.com/onedr0p/flux-cluster-template) and the [k8s-at-home](https://github.com/k8s-at-home) community. You can find similar setups with the [k8s at home search](https://nanne.dev/k8s-at-home-search/). Historical revisions of this repository had rootless Podman containers deployed with ansible as systemd units.

### Setup

[Install go-task](https://taskfile.dev/installation/)

```sh
task init
```

Then, provision your infrastructure.

```sh
task ansible:{list,setup,kubernetes,status}
```

Edit `provision/terraform/cloudflare/secret.sops.yaml` with your own values and encrypt with `task sops:encrypt -- <filepath>`.

Setup Cloudflare DNS.

```sh
task terraform:{init,cloudflare-plan,cloudflare-apply}
```

### Deploy

#### Kubernetes

Verify flux can be installed. Then, push changes to remote repo and install.

```sh
task cluster:{verify,install}
```

Push latest to repo - you can use the [wip.sh](./scripts/wip.sh) script for that with `task wip`.

```sh
task cluster:{reconcile,resources}
```

#### Bastion server

Edit `provision/terraform/bastion/secret.sops.yaml` with your own values. [Generate WireGuard keys](https://www.wireguard.com/quickstart/).

Deploy the remote bastion VPN server.

```sh
task terraform:{init,plan,apply}
```

Then, setup VPN services.

```sh
task ansible:bastion
```

### Deployments

Most deployments in this repo use an `app-template` chart with [these configuration options](https://github.com/bjw-s/helm-charts/tree/main/charts/library/common).

### Update

The Renovate bot will help find updates for charts and images. [Install Renovate Bot](https://github.com/apps/renovate), add to your repository and [view Renovate bot activity](https://app.renovatebot.com/dashboard), or use the self-hosted option.

## Hardware

![book cover: Mommy, Why is There a Server is the House?](./files/stay_at_home_server.jpg)

### Resources

- [DataHoarder Wiki: Hardware](https://www.reddit.com/r/DataHoarder/wiki/hardware)
- [2020 DIY NAS](https://blog.briancmoses.com/2020/11/diy-nas-2020-edition.html)
- [2020 Economy DIY NAS](https://blog.briancmoses.com/2020/12/diy-nas-econonas-2020.html)
- [Home server case recommendations](https://perfectmediaserver.com/hardware/cases/)

### Memory

- [Why use ECC](https://danluu.com/why-ecc/) ([discussion](https://news.ycombinator.com/item?id=14206635))
- > [If you love your data, use ECC RAM.](https://arstechnica.com/civis/viewtopic.php?f=2&t=1235679&p=26303271#p26303271)
- > [Error rates increase rapidly with rising altitude.](https://en.wikipedia.org/wiki/ECC_memory#Description)

### Storage

#### Controller

I used a widely-known and inexpensive method to add additional SATA storage via a Host Bus Adapter (HBA). I purchased a [Dell Perc H310](https://www.ebay.com/sch/i.html?_nkw=Dell+Perc+H310+SATA) a long while back. Mine did come from overseas, but it turned out to be legit. [This video](https://www.youtube.com/watch?v=EOcpp-GdhKo) shows how it can be flashed to an LSI 9211-8i IT (see also [1](https://www.servethehome.com/ibm-serveraid-m1015-part-4/), [2](https://www.truenas.com/community/threads/confused-about-that-lsi-card-join-the-crowd.11901/)).

Here are other recommended [controllers](https://www.reddit.com/r/DataHoarder/wiki/hardware#wiki_controllers).

#### 2.5" drive stackers

[These printable stackers](https://www.thingiverse.com/thing:582781) are great for stacking SSDs in a homelab.

### Home automation

#### Zigbee/Z-Wave

- [USB Zigbee/Z-Wave receiver](https://www.amazon.com/dp/B01GJ826F8) and [upgrade Zigbee firmware](https://github.com/walthowd/husbzb-firmware) for compatibility with Home Assistant ([notice this issue](https://github.com/walthowd/husbzb-firmware/issues/33))

## Software

### Linux

- [Arch Linux](https://archlinux.org)
- [Raspberry Pi Debian](https://wiki.debian.org/RaspberryPiImages)

#### SSH

Here's a nice convenience for setting up `authorized_keys` stored on Github or Gitlab:

```sh
curl https://github.com/<username>.keys -o authorized_keys
```

You could pipe the output to `sed` to only grab a specific line `sed '4!d'`.

#### Check disks

Here's a handy script to automatically test disks with [badblocks](https://wiki.archlinux.org/index.php/Badblocks) and SMART: [Spearfoot/disk-burnin-and-testing](https://github.com/Spearfoot/disk-burnin-and-testing).

Testing disks takes a long time for larger drives, but it's worth it to be thorough before determining whether to make a return. This is a destructive test, so it's probably best to use `/dev/disk/by-id` to be certain you're targeting the correct drive.

Use `tune2fs -l <partition>` to identify the block size.

```sh
sudo badblocks -wsv -b 4096 /dev/sda > sda_badblocks.txt
```

Here's some additional advice from [/r/DataHoarders](https://www.reddit.com/r/DataHoarder/comments/7seion/new_drive_first_steps_you_take_before_using/).

#### JBOD

[MergerFS](https://github.com/trapexit/mergerfs) is a union filesystem for pooling drives together. It's a great pair with SnapRAID. An alternative is [SnapRAID-BTRFS](https://wiki.selfhosted.show/tools/snapraid-btrfs/).

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

Remember, for data that's irreplaceable [RAID is _not_ a backup](https://www.raidisnotabackup.com/).

#### mkinitcpio

Be sure to add `zfs` and `resume`.

```
HOOKS=(base udev autodetect modconf block filesystems keyboard zfs resume fsck)
```

Then, [regenerate the image](https://wiki.archlinux.org/index.php/Mkinitcpio#Image_creation_and_activation).

#### ZFS

Install `zfs-dkms` and `zfs-utils`, and be sure to have `linux-headers` installed for dkms to work. [Update the ZFS libraries together](https://gist.github.com/brettinternet/311c0ff31164d3cab4a38ea71cb4b01f) using a AUR helper.

#### OS Installation

Use [Ventoy](https://www.ventoy.net) to bundle bootable ISO and IMG images on a single USB.

### Media

For a media server, it's a good idea to [understand digital video](https://github.com/leandromoreira/digital_video_introduction).

### Troubleshooting

#### Network

Debug DNS issues

```sh
kubectl run curl --rm=true --stdin=true --tty=true --restart=Never --image=docker.io/curlimages/curl --command -- /bin/sh -

curl -k https://kubernetes:443; echo
```

[Ensure you're using iptables-legacy](https://github.com/k3s-io/k3s/issues/703#issuecomment-522355829). See also [nftables](https://wiki.nftables.org/wiki-nftables/index.php/Adoption).

```sh
iptables --version
# iptables v1.8.7 (legacy)
```

Flush the iptables in between installs. Also check the CNI installation for issues (such as configuration for hardware with multiple NICs).

#### Services

- [Determine the Reason for Pod Failure](https://kubernetes.io/docs/tasks/debug/debug-application/determine-reason-pod-failure/)
