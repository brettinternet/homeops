#!/bin/sh

# Verify user config present
if [ ! -f /etc/snapraid.conf ]; then
    echo "No config found. You must configure SnapRAID before running this script."
    exit 1
fi

# Verify user runner config present
if [ ! -f /etc/snapraid-runner.conf ]; then
    echo "No config found. You must configure snapraid-runner before running this script."
    exit 1
fi

function run_commands {
  COMMANDS=$1
  while IFS= read -r cmd; do echo "$cmd" && eval "$cmd" ; done < <(printf '%s\n' "$COMMANDS")
}

function run_exit_commands {
  set +e
  set +o pipefail
  run_commands "${POST_COMMANDS_EXIT:-}"
}

trap run_exit_commands EXIT

run_commands "${PRE_COMMANDS:-}"

start=$(date +%s)
echo Starting SnapRAID runner at $(date +"%Y-%m-%d %H:%M:%S")

set +e
/usr/local/bin/snapraid-runner -c /etc/snapraid-runner.conf
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
