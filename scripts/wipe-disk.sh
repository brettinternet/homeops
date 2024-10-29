#!/bin/bash

# Zap device disk!
# https://rook.io/docs/rook/latest-release/Getting-Started/ceph-teardown/#zapping-devices

# Run this in the rook ceph tools pod container on each node:

# One liner for the rook ceph tools pod container:
# You may also need to remove LVM and device mapper data:
FDISK_BEFORE=$(fdisk -l); \
  DISK="/dev/sda"; \
  sgdisk --zap-all $DISK; \
  dd if=/dev/zero of="$DISK" bs=1M count=100 oflag=direct,dsync; \
  blkdiscard $DISK; \
  partprobe $DISK; \
  ls /dev/mapper/ceph-* | xargs -I% -- dmsetup remove %; \
  rm -rf /dev/ceph-*; \
  rm -rf /dev/mapper/ceph--*; \
  diff <(echo "$FDISK_BEFORE") <(fdisk -l)

# Then, delete the operator pod to re-run the osd-prepare job pods
