#!/usr/bin/dumb-init /bin/sh

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
echo Starting job at $(date +"%Y-%m-%d %H:%M:%S")

set +e
$@
RC=$?
set -e

if [ $RC -ne 0 ]; then
  if [ $RC -eq 3 ] && [ -n "${POST_COMMANDS_INCOMPLETE:-}" ]; then
      run_commands "${POST_COMMANDS_INCOMPLETE:-}"
  else
      run_commands "${POST_COMMANDS_FAILURE:-}"
  fi
fi

echo Job successful

end=$(date +%s)
echo Finished job at $(date +"%Y-%m-%d %H:%M:%S") after $((end-start)) seconds

[ $RC -ne 0 ] && exit $RC

run_commands "${POST_COMMANDS_SUCCESS:-}"
