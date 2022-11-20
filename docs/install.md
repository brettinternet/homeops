# [Installation](https://wiki.archlinux.org/index.php/Installation_guide)

[RTFM](https://wiki.archlinux.org/). Seriously, the Arch Wiki is an excellent resource. Here are some of my quick notes. This is _not_ a guide.

### Boot to USB installation media

1. `fdisk -l` to view drives/partitions (`/dev/sda` in this walkthrough)
1. cfdisk `/dev/sda` to modify drive partitions - See example [partition layouts](https://wiki.archlinux.org/index.php/Installation_guide#Partition_the_disks)
1. Make EFI filesystem `mkfs.fat -F32 /dev/sda1`, make linux filesystem ext4 `mkfs.ext4 /dev/sda3`, make swap `mkswap /dev/sda2`
1. Mount filesystem `mount /dev/sda3 /mnt` and enable swap `swapon /dev/sda2`
1. Rearrange mirrorlist `vim /etc/pacman.d/mirrorlist` (use [reflector](https://wiki.archlinux.org/index.php/Reflector) later to rearrange this list) and `vim /etc/pacman.conf` (enabled `#Color`)
1. Confirm internet connection
   1. If not connected via Ethernet cable, use `wifi-menu`; don't use hyphens when creating a profile name
1. `pacstrap /mnt base base-devel linux linux-firmware vim dhcpcd sudo`
1. Generate fstab file `genfstab -U -p /mnt >> /mnt/etc/fstab`
1. `arch-chroot /mnt`

### `/mnt`

1. `echo "myhostname" > /etc/hostname`
1. edit `/etc/locale.gen`, uncomment `en_US.UTF-8 UTF-8` and `en_US ISO-8859-1`
1. exec `locale-gen && echo LANG=en_US.UTF-8 > /etc/locale.conf && export LANG=en_US.UTF-8`
1. `ln -s /usr/share/zoneinfo/America/Denver /etc/localtime`
1. Use UTC for hwclock `hwclock --systohc --utc`
1. `pacman -Syu`
1. `passwd`
1. `pacman -S grub efibootmgr dosfstools os-prober mtools` ([grub](https://wiki.archlinux.org/index.php/GRUB#Installation_2), [EFI](https://wiki.archlinux.org/index.php/EFI_system_partition))
1. `mkdir /efi` and `mount /dev/sda1 /efi` and `grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory=/efi`
1. `grub-mkconfig -o /boot/grub/grub.cfg`
1. `exit` and `umount -a` then `reboot`

### New OS

1. start/enable `dhcpcd`
1. `groupadd -r sudo` and `groupadd -r ssh`
1. `echo 'AllowGroups ssh' >> /etc/ssh/sshd_config`
1. install `openssh` and start/enable `sshd`
1. `useradd -m -G wheel,storage,sudo,ssh -s /bin/bash myuser` ([user mgmt](https://wiki.archlinux.org/index.php/Users_and_groups#User_management))
   - Other groups to consider: `input,video,docker,libvirt`
1. `passwd myuser`
1. edit sudoers config with `EDITOR=vim visudo /etc/sudoers` to allow wheel group access to [sudo](https://wiki.archlinux.org/index.php/Sudo#Configuration)
1. Login as user
