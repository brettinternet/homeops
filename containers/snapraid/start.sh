#!/bin/sh

### Validation and Setup

# remove default configuration
if [ ! -L /etc/snapraid.conf ] && [ -f /etc/snapraid.conf ]; then
    rm /etc/snapraid.conf
fi

# Verify user config present
if [ ! -f /config/snapraid.conf ]; then
    echo "No config found. You must configure SnapRAID before running this container."
    exit 1
fi

# Verify user runner config present
if [ ! -f /config/snapraid-runner.conf ]; then
    echo "No config found. You must configure snapraid-runner before running this container"
    exit 1
fi

# Link user config to expected snapraid config location
if [ ! -L /etc/snapraid.conf ]; then
    ln -s /config/snapraid.conf /etc/snapraid.conf
fi

### Declarations

function run_commands {
  COMMANDS=$1
  while IFS= read -r cmd; do echo "$cmd" && eval "$cmd" ; done < <(printf '%s\n' "$COMMANDS")
}

function run_exit_commands {
  set +e
  set +o pipefail
  run_commands "${POST_COMMANDS_EXIT:-}"
}

### Runtime

trap run_exit_commands EXIT

run_commands "${PRE_COMMANDS:-}"

start=$(date +%s)
echo Starting SnapRAID runner at $(date +"%Y-%m-%d %H:%M:%S")

set +e
/usr/bin/python3 /app/snapraid-runner/snapraid-runner.py -c /config/snapraid-runner.conf
RC=$?
set -e

if [ $RC -ne 0 ]; then
  if [ $RC -eq 3 ] && [ -n "${POST_COMMANDS_INCOMPLETE:-}" ]; then
      run_commands "${POST_COMMANDS_INCOMPLETE:-}"
  else
      run_commands "${POST_COMMANDS_FAILURE:-}"
  fi
fi

echo Runner successful

end=$(date +%s)
echo Finished SnapRAID runner at $(date +"%Y-%m-%d %H:%M:%S") after $((end-start)) seconds

[ $RC -ne 0 ] && exit $RC

run_commands "${POST_COMMANDS_SUCCESS:-}"
