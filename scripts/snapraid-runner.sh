#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Permission denied: Snapraid requires root access."
  exit
fi

: ${HOMELAB_REPO_PATH:="~/homelab"}

APPS_TO_SHUTDOWN=("automators" "espial" "mailserver" "miniflux" "nzbget" "watchtower")

bash $HOMELAB_REPO_PATH/compose.sh -d "${APPS_TO_SHUTDOWN[@]}"

python3 /opt/snapraid-runner/snapraid-runner.py -c /opt/snapraid-runner/snapraid-runner.conf

bash $HOMELAB_REPO_PATH/compose.sh -u "${APPS_TO_SHUTDOWN[@]}"