#!/bin/bash

# Zap device disk!
# https://rook.io/docs/rook/latest-release/Getting-Started/ceph-teardown/#zapping-devices

# Run this in the rook ceph tools pod container on each node:

DISK="/dev/sda"; \
  sgdisk --zap-all $DISK; \
  dd if=/dev/zero of="$DISK" bs=1M count=100 oflag=direct,dsync; \
  blkdiscard $DISK; \
  partprobe $DISK

# Then, delete the operator pod to re-run the osd-prepare job pods
