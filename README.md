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

### Builds

#### Current

| Type             | Item                                                                                                                                                             |
| :--------------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **CPU**          | [Intel Core i7-7700 3.6 GHz Quad-Core Processor](https://pcpartpicker.com/product/9mRFf7/intel-core-i7-7700-36ghz-quad-core-processor-bx80677i77700)             |
| **CPU Cooler**   | [Noctua NH-L9i 33.84 CFM CPU Cooler](https://pcpartpicker.com/product/xxphP6/noctua-nh-l9i-3384-cfm-cpu-cooler-nh-l9i)                                           |
| **Motherboard**  | [Gigabyte GA-H270N-WIFI Mini ITX LGA1151 Motherboard](https://pcpartpicker.com/product/gVZ2FT/gigabyte-ga-h270n-wifi-mini-itx-lga1151-motherboard-ga-h270n-wifi) |
| **Memory**       | [Corsair Vengeance LPX 16 GB (2 x 8 GB) DDR4-3000 CL15 Memory](https://pcpartpicker.com/product/MYH48d/corsair-memory-cmk16gx4m2b3000c15)                        |
| **Case**         | [Fractal Design Node 804 MicroATX Mid Tower Case](https://pcpartpicker.com/product/yTdqqs/fractal-design-case-fdcanode804blw)                                    |
| **Power Supply** | [EVGA G2 550 W 80+ Gold Certified Fully Modular ATX Power Supply](https://pcpartpicker.com/product/qYTrxr/evga-power-supply-220g20550y1)                         |

<!-- | **Storage**      | [Hitachi Deskstar NAS 3 TB 3.5" 7200RPM Internal Hard Drive](https://pcpartpicker.com/product/TP2kcf/hitachi-internal-hard-drive-0s03660)                        | -->

[PCPartPicker](https://pcpartpicker.com/list/PKJqfP)

#### Other

- [2020 DIY NAS](https://blog.briancmoses.com/2020/11/diy-nas-2020-edition.html)
- [2020 Economy DIY NAS](https://blog.briancmoses.com/2020/12/diy-nas-econonas-2020.html)
- [Home server case recommendations](https://perfectmediaserver.com/hardware/cases/)

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

Be sure to add `zfs` and `resume`

```
HOOKS=(base udev autodetect modconf block filesystems keyboard zfs resume fsck)
```

Then, [regenerate the image](https://wiki.archlinux.org/index.php/Mkinitcpio#Image_creation_and_activation).

#### ZFS

Install `zfs-dkms-git` and `zfs-utils-git`, and be sure to have `linux-headers` installed for dkms to work.

#### OS Installation

[Ventoy](https://www.ventoy.net/en/index.html) seems like an interesting project. Some of my ARM hardware requires Ubuntu, so it'd be nice to have a single USB to manage installations.
