# HomeOps

[![Lint](https://github.com/brettinternet/homeops/actions/workflows/lint.yaml/badge.svg)](https://github.com/brettinternet/homeops/actions/workflows/lint.yaml)

## Features

- [Talos](https://www.talos.dev) bare-metal K8s OS
- Lots of [self-hosted services](./kubernetes/main/apps)
- [Flux](https://toolkit.fluxcd.io/) GitOps with this repository ([kubernetes directory](./kubernetes))
- [Cilium](https://cilium.io/) container networking interface (CNI) and [layer 4 loadbalancing](https://cilium.io/use-cases/load-balancer/)
- [go-task](https://taskfile.dev) shorthand for useful commands ([Taskfile](./Taskfile.yaml) and [taskfiles](./.taskfiles)) for multiple clusters
- [SOPS](https://github.com/mozilla/sops) secrets stored in Git
- [Renovate bot](https://github.com/renovatebot/renovate) dependency updates
- [Cloudflared HTTP tunnel](https://github.com/cloudflare/cloudflared)
- [K8s gateway](https://github.com/ori-edge/k8s_gateway) for local DNS resolution to the cluster and [NGINX ingress controller](https://kubernetes.github.io/ingress-nginx/)
- Both internal & external services with a service [gateway](https://github.com/ori-edge/k8s_gateway/)
- OIDC [authentication](https://www.authelia.com/configuration/identity-providers/open-id-connect/) with [LDAP](https://github.com/glauth/glauth)
- Automatic Cloudflare DNS updates with [external-dns](./kubernetes/main/apps/network/external-dns/app/helmrelease.yaml)
- [CloudNative-PG](https://cloudnative-pg.io/) with automatic failover
- [kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack) with various Grafana dashboards
- [Rook Ceph](https://rook.io/) cluster storage

This setup is inspired by [this homelab gitops template](https://github.com/onedr0p/flux-cluster-template). You can find similar setups with the [k8s at home search](https://nanne.dev/k8s-at-home-search/).

See also my [homelab repo](https://github.com/brettinternet/homelab) for how I provision machines in my home.

## Usage

### Setup

[Install go-task](https://taskfile.dev/installation/)

```sh
task init
```

Provision the Talos nodes.

```sh
task talos:bootstrap
```

Install flux.

```sh
task flux:{verify,bootstrap}
```

Verify the installation.

```sh
kubectl -n flux-system get pods -o wide
```

```sh
task kubernetes:resources
```

#### DNS and Tunnel

Setup a Cloudflare Tunnel.

```sh
cloudflared tunnel login
cloudflared tunnel create cluster
```

Add the tunnel's `credentials.json` to the value in [`cloudflared-secret`](kubernetes/apps/network/cloudflared/app/secret.sops.yaml) and tunnel ID to `cluster-secrets.sops.yaml`.

Add a Cloudflare API token with these permissions to the value in [`external-dns-secret`](kubernetes/apps/network/external-dns/app/secret.sops.yaml).

- `Zone - DNS - Edit`
- `Account - Cloudflare Tunnel - Read`

#### Github Webhook

Setup a webook to reconcile flux when changes are pushed to Github. Note: this only works with Let's Encrypt Production certificates.

Get webook path:

```sh
kubectl -n flux-system get receiver github-receiver -o jsonpath='{.status.webhookPath}'
```

Append to self-hosted domain:

```text
https://flux-webhook.${DOMAIN}/hook/12ebd1e363c641dc3c2e430ecf3cee2b3c7a5ac9e1234506f6f5f3ce1230e123
```

Generate a webook token `openssl rand -hex 16` and add to secret: `kubernetes/<cluster>/apps/flux-system/webhooks/app/github/secret.sops.yaml`.

Add the webook to the repository's "Settings/Webhooks" > "Add webhook" button. Add the URL and token.

### Directories

This Git repository contains the following directories under [Kubernetes](./kubernetes/). Check out [cluster-template](https://github.com/onedr0p/flux-cluster-template) for more details on how this FluxCD setup works.

```sh
📁 kubernetes
├── 📁 main # main cluster
│   ├── 📁 apps # applications
│   ├── 📁 bootstrap # bootstrap procedures
│   ├── 📁 flux # core flux configuration
│   └── 📁 templates # re-useable components
└── 📁 ...
```

### Deployments

Most helm deployments in this repo utilize this useful [`app-template` chart](https://github.com/bjw-s/helm-charts).

## Hardware

![book cover: Mommy, Why is There a Server is the House?](./docs/stay_at_home_server.jpg)

### Resources

- [DataHoarder Wiki: Hardware](https://www.reddit.com/r/DataHoarder/wiki/hardware)
- [2020 DIY NAS](https://blog.briancmoses.com/2020/11/diy-nas-2020-edition.html)
- [2020 Economy DIY NAS](https://blog.briancmoses.com/2020/12/diy-nas-econonas-2020.html)
- [Home server case recommendations](https://perfectmediaserver.com/hardware/cases/)

### Memory

- [Why use ECC](https://danluu.com/why-ecc/) ([discussion](https://news.ycombinator.com/item?id=14206635))
- [If you love your data, use ECC RAM.](https://arstechnica.com/civis/viewtopic.php?f=2&t=1235679&p=26303271#p26303271)
- [Error rates increase rapidly with rising altitude.](https://en.wikipedia.org/wiki/ECC_memory#Description)

### Storage

#### Controller

I used a widely-known and inexpensive method to add additional SATA storage via a Host Bus Adapter (HBA). I purchased a [Dell Perc H310](https://www.ebay.com/sch/i.html?_nkw=Dell+Perc+H310+SATA) a long while back. Mine did come from overseas, but it turned out to be legit. [This video](https://www.youtube.com/watch?v=EOcpp-GdhKo) shows how it can be flashed to an LSI 9211-8i IT (see also [1](https://www.servethehome.com/ibm-serveraid-m1015-part-4/), [2](https://www.truenas.com/community/threads/confused-about-that-lsi-card-join-the-crowd.11901/)).

Here are other recommended [controllers](https://www.reddit.com/r/DataHoarder/wiki/hardware#wiki_controllers).

#### 2.5" drive stackers

[These printable stackers](https://www.thingiverse.com/thing:582781) are great for stacking SSDs in a homelab.

![5 raspberry pis each with a SSD over USB, stacked in a custom case with a network switch](./docs/pi-cluster.png)

#### Raspberry Pi cluster

One cluster uses Raspberry Pi 4B (x 5) but the 4 GB RAM models are hungry for more memory. [Micro SD cards are insufficient](https://gist.github.com/brettinternet/94d6d8a1e01f4a90b6dfdc70d6b4a5e5) for etcd's demanding read/writes, so I recommend SATA over USB 3.0. Check out [this guide](https://jamesachambers.com/new-raspberry-pi-4-bootloader-usb-network-boot-guide/) for compatible SSD interfaces. I use a [PicoCluster case](https://www.picocluster.com/collections/pico-5).

### Home automation

#### IoT

- [USB Zigbee/Z-Wave receiver](https://www.amazon.com/dp/B01GJ826F8) and [upgrade Zigbee firmware](https://github.com/walthowd/husbzb-firmware) for compatibility with Home Assistant ([notice this issue](https://github.com/walthowd/husbzb-firmware/issues/33))
- [Zigbee/Matter receiver](https://www.home-assistant.io/skyconnect/)

## Software

See my [homelab repo](https://github.com/brettinternet/homelab) for how I provision proxmox, SSH keys, dotfiles and other tasks in my home.

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

For data that's irreplaceable [RAID is _not_ a backup](https://www.raidisnotabackup.com/).

#### ZFS

Install `zfs-dkms` and `zfs-utils`, and be sure to have `linux-headers` installed for dkms to work. [Update the ZFS libraries together](https://gist.github.com/brettinternet/311c0ff31164d3cab4a38ea71cb4b01f) using a AUR helper.

#### OS Installation

Use [Ventoy](https://www.ventoy.net) to bundle bootable ISO and IMG images on a single USB.

Setup Proxmox on the hosts with Arch Linux guests. [Post setup for Proxmox](https://tteck.github.io/Proxmox/).

### Media

For a media server, it's a good idea to [understand digital video](https://github.com/leandromoreira/digital_video_introduction).
