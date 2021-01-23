#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Permission denied: Snapraid requires root access."
  exit
fi

: ${HOMELAB_REPO_PATH:="~/homelab"}

APPS_TO_SHUTDOWN=("automators" "espial" "mailserver" "miniflux" "nzbget" "watchtower")

bash $HOMELAB_REPO_PATH/compose.sh -d "${APPS_TO_SHUTDOWN[@]}"


/usr/bin/python3 /opt/snapraid-runner/snapraid-runner.py -c /opt/snapraid-runner/snapraid-runner.conf -q
if [ $? -eq 0 ]; then
    echo "SUCCESS"
    # curl -fsS --retry 3 https://hc-ping.com/{{ snapraid_healthcheck_io_uuid }} > /dev/null
else
    echo "ERROR: Unable to run snapraid-runner.py"
fi

bash $HOMELAB_REPO_PATH/compose.sh -u "${APPS_TO_SHUTDOWN[@]}"
