# Backup

See [backup programs](https://wiki.archlinux.org/index.php/List_of_applications/Security#Backup_programs)

### Clone drive

1. Download [Clonezilla ISO](https://clonezilla.org/downloads/download.php?branch=stable)
1. Copy image ISO to USB drive `sudo dd bs=4M if=~/Downloads/clonezilla-live-2.7.0-10-amd64.iso of=/dev/sdb conv=fdatasync` ([example](https://www.howtogeek.com/414574/how-to-burn-an-iso-file-to-a-usb-drive-in-linux/))
1. [Follow Clonezilla guide](https://clonezilla.org/show-live-doc-content.php?topic=clonezilla-live/doc/03_Disk_to_disk_clone)

### /etc

Setup [etckeeper](https://wiki.archlinux.org/index.php/Etckeeper) and use HTTP remote with GitHub Personal Access Token for password.
