# HomeOps

[![Lint](https://github.com/brettinternet/homeops/actions/workflows/lint.yaml/badge.svg)](https://github.com/brettinternet/homeops/actions/workflows/lint.yaml)

## Features

- [SOPS](https://github.com/mozilla/sops) secrets stored in Git
- [Renovate bot](https://github.com/renovatebot/renovate) dependency updates
- [Cloudflared HTTP tunnel](https://github.com/cloudflare/cloudflared)
- OIDC [authentication](https://www.authelia.com/configuration/identity-providers/open-id-connect/) with [LDAP](https://github.com/nitnelave/lldap)
- Automatic Cloudflare DNS updates
- [go-task](https://taskfile.dev) shorthand for useful commands ([Taskfile](./Taskfile.yaml) and [taskfiles](./.taskfiles))

Historical revisions of this repository went from a single-node compose orchestration, then Podman rootless containers deployed with Ansible as systemd units, then a kubernetes cluster extended from [this template](https://github.com/onedr0p/flux-cluster-template). With other responsibilities, I've had to take on a much more minimal approach to my homelab and I strive for simplicity over high availability at this time.

## Usage

### Setup

[Install go-task](https://taskfile.dev/installation/)

```sh
task init
```

Then, provision your infrastructure.

```sh
task ansible:{list,setup,status}
```

Edit `provision/terraform/cloudflare/secret.sops.yaml` with your own values and encrypt with `task sops:encrypt -- <filepath>`.

Setup Cloudflare DNS.

```sh
task terraform:{init,cloudflare-plan,cloudflare-apply}
```

### Deployments

Most deployments in this repo use an `app-template` chart with [these configuration options](https://github.com/bjw-s/helm-charts/tree/main/charts/library/common).

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

### Home automation

#### IoT

- [USB Zigbee/Z-Wave receiver](https://www.amazon.com/dp/B01GJ826F8) and [upgrade Zigbee firmware](https://github.com/walthowd/husbzb-firmware) for compatibility with Home Assistant ([notice this issue](https://github.com/walthowd/husbzb-firmware/issues/33))
- [Zigbee/Matter receiver](https://www.home-assistant.io/skyconnect/)

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

For data that's irreplaceable [RAID is _not_ a backup](https://www.raidisnotabackup.com/).

#### ZFS

Install `zfs-dkms` and `zfs-utils`, and be sure to have `linux-headers` installed for dkms to work. [Update the ZFS libraries together](https://gist.github.com/brettinternet/311c0ff31164d3cab4a38ea71cb4b01f) using a AUR helper.

#### OS Installation

Use [Ventoy](https://www.ventoy.net) to bundle bootable ISO and IMG images on a single USB.

Setup Proxmox on the hosts with Arch Linux guests. [Post setup for Proxmox](https://tteck.github.io/Proxmox/).

### Media

For a media server, it's a good idea to [understand digital video](https://github.com/leandromoreira/digital_video_introduction).
