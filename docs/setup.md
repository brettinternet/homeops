# Setup

## Packages

[Install from a list](https://wiki.archlinux.org/index.php/Pacman/Tips_and_tricks#List_of_installed_packages):

```sh
pacman -S --needed - < packages/base.txt
```

exclude `#` if any:

```sh
grep -v "^#" pkg-list.txt | pacman -S --needed -

sed -e "/^#/d" -e "s/#.*//" packages.txt | pacman -S --needed -
```

### AUR

Install [yay](https://github.com/Jguer/yay) (or you may consider using aurutils with [aurto](https://github.com/alexheretic/aurto) instead)

```sh
git clone https://aur.archlinux.org/yay.git
cd yay && makepkg -si
```

### Other

- [zinit](https://github.com/zdharma/zinit); afterwards, run `zsh` once to setup plugins before logging out/in
- [Modern unix tools](https://github.com/ibraheemdev/modern-unix)

## Configuration

### Services

- Setup [OpenSSH](https://wiki.archlinux.org/index.php/OpenSSH)
- Install packages
- Setup [etckeeper](https://wiki.archlinux.org/index.php/Etckeeper)
- Mount drives/modify fstab

### Workspaces

Since I use the same dotfiles across multiple workspaces, local environment variables specific to a workspace and not added to source control are add to `$HOME/.env` and imported into the environment. See [example.env](../user/example.env) for details.

### Power Management

#### Console

Since I don't use a display manager, it may be practical to implement power settings for the console login screen. `cat /sys/module/kernel/parameters/consoleblank` with an output of `0` suggests no `consoleblank`ing is occurring and the login screen will not timeout. Add a [kernel parameter](https://wiki.archlinux.org/index.php/Kernel_parameters#GRUB) of `consoleblank=600` to timeout after 10 minutes with a console screensaver.

#### Laptops

- [TLP](https://wiki.archlinux.org/index.php/TLP)
- [NVIDIA Optimus](https://wiki.archlinux.org/title/NVIDIA_Optimus#Use_NVIDIA_graphics_only)

#### Hibernation

[Setup hibernation](https://wiki.archlinux.org/index.php/Power_management/Suspend_and_hibernate#Hibernation) - don't forget to re-generate the grub.cfg (`grub-mkconfig -o /boot/grub/grub.cfg`) and initramfs (`mkinitcpio -p linux`)

#### [Laptops](https://wiki.archlinux.org/index.php/Laptop_Mode_Tools)

### Input

- [Logitech MX Master](https://wiki.archlinux.org/index.php/Logitech_MX_Master)
- [Mouse Acceleration](https://wiki.archlinux.org/index.php/Mouse_acceleration)

#### Laptops

- [TouchPad Synaptics](https://wiki.archlinux.org/index.php/Touchpad_Synaptics)
  - [TouchPad remapping note](https://wiki.archlinux.org/index.php/Libinput#Manual_button_re-mapping)

### Display

#### Laptops

- [Backlight](https://wiki.archlinux.org/index.php/Backlight#xbacklight)

## Security

- [ArchWiki: Security](https://wiki.archlinux.org/index.php/Security)
- [IBM Developer: Harden Desktop](https://developer.ibm.com/articles/l-harden-desktop/)
- [CentOS Wiki: OS Protection](https://wiki.centos.org/HowTos/OS_Protection)
- [Linux Foundation IT: Workstation security checklist](https://github.com/lfit/itpol/blob/master/linux-workstation-security.md)
- [Securing Debian Manual](https://www.debian.org/doc/manuals/securing-debian-manual/index.en.html)

### Xorg Rootless

[When using proprietary display drivers (such as nvidia)](https://wiki.archlinux.org/index.php/Xorg#Rootless_Xorg), add to `/etc/X11/Xwrapper.config`

```
needs_root_rights = no
```

And then confirm Xorg is running under user

```
ps -o user $(pgrep Xorg)
```

See also [Gentoo: Non root Xorg](https://wiki.gentoo.org/wiki/Non_root_Xorg)

### Login

Add to `/etc/pam.d/system-login` in order to [enforce a delay after failed login attempts](https://wiki.archlinux.org/index.php/Security#Enforce_a_delay_after_a_failed_login_attempt)

```
auth optional pam_faildelay.so delay=4000000
```

[Allow only local access to root](https://wiki.archlinux.org/index.php/Security#Specify_acceptable_login_combinations_with_access.conf) by appending `/etc/security/access.conf`

```
+:root:LOCAL
-:root:ALL
```

### Hardware

Run to [view hardware vulnerabilities](https://wiki.archlinux.org/index.php/Security#Hardware_vulnerabilities)

```
grep -r . /sys/devices/system/cpu/vulnerabilities/
```

[Setup usbguard rules](https://wiki.archlinux.org/index.php/USBGuard). Use [lsusb](https://wiki.debian.org/HowToIdentifyADevice/USB) to view USB devices and `usbguard generate-policy` to view a rule snapshot of current devices.

### Applications

See additional [security applications](https://wiki.archlinux.org/index.php/List_of_applications/Security).

#### Sudo

Add to `/etc/sudoers` (make sure to edit with `sudo visudo /etc/sudoers`)

```
Defaults      editor=/usr/bin/rvim
Defaults      insults
```

[Insults](https://wiki.archlinux.org/index.php/Sudo#Enable_insults) is an optional easter egg.

#### Apparmor

[Set apparmor kernel parameters and enable apparmor service](https://wiki.archlinux.org/index.php/AppArmor#Installation).

Start/enable apparmor [audit](https://wiki.archlinux.org/index.php/Audit_framework) [aa-notify for denied actions](https://wiki.archlinux.org/index.php/AppArmor#Get_desktop_notification_on_DENIED_actions). Install `python-notify2` and `python-psutil` as implicit dependencies of apparmor with `makedep` to make aa-notify work

```
sudo makedep -a python-notify2 --add-as deps apparmor
```

### ClamAV

Start/enable [ClamAV](https://wiki.archlinux.org/index.php/ClamAV)

```
sudo systemctl enable clamav-freshclam.service
sudo systemctl enable clamav-daemon.service
```

Then, test ClamAV with

```
curl https://secure.eicar.org/eicar.com.txt | clamscan -
```

Finally, [setup Fangfrisch](https://wiki.archlinux.org/index.php/ClamAV#Option_#1:_Set_up_Fangfrisch) for additional ClamAV databases.

#### Firejail

[Setup apparmor integration](https://wiki.archlinux.org/index.php/Firejail#Apparmor_integration) with Firejail. Also, add Firejail profiles: [1](https://github.com/chiraag-nataraj/firejail-profiles), [2](https://github.com/nyancat18/fe).

### Network

If you're setting up a server, you might consider [disabling the wireless network](https://wiki.centos.org/HowTos/OS_Protection#Wireless_has_to_go).

[Force public key authentication](https://wiki.archlinux.org/index.php/OpenSSH#Force_public_key_authentication) for SSH connections by changing `/etc/ssh/sshd_config`

```
PasswordAuthentication no
```

#### Additional security

[Restrict access to kernel logs](https://wiki.archlinux.org/index.php/Security#Restricting_access_to_kernel_logs), [restrict access to kernel pointers in proc](https://wiki.archlinux.org/index.php/Security#Restricting_access_to_kernel_pointers_in_the_proc_filesystem), [setup hidepid](https://wiki.archlinux.org/index.php/Security#hidepid)

[Password protect the bios](https://wiki.archlinux.org/index.php/Security#Locking_down_BIOS).

Ensure the CPU [microcode](https://wiki.archlinux.org/index.php/Microcode) is loaded

```
dmesg | grep microcode
```

## Maintenance

[System maintenance](https://wiki.archlinux.org/title/System_maintenance)
