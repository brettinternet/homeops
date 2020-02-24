#!/bin/bash

HELP="$(basename "$0") [-h] [-u] [-d] [args] -- program to start docker-compose yml files in compose directory

where:
    -h    show this help text
    -u    docker-compose up -d (default)
    -d    docker-compose down
    args  service groups in compose directory to act on"


# Reset in case getopts has been used previously in the shell.
OPTIND=1

COMPOSE_ARGS=""

while getopts "h?ud" opt; do
    case "$opt" in
    h|\?)
        echo "$HELP"
        exit 0
        ;;
    u)
        COMPOSE_ARGS="up -d"
        ;;
    d)
        COMPOSE_ARGS="down"
        ;;
    *)
        echo "$HELP"
        exit 0
        ;;
    esac
done

# Change working directory to the directory of the script
# source: https://stackoverflow.com/a/3355423/6817437
cd "$(dirname "$0")"

# reset positional parameters
# source: https://unix.stackexchange.com/a/214151/224048
shift "$((OPTIND-1))"

CONTAINERS="$@"

REVERSE_PROXY="traefik"
AUTH="auth"

# if no arguments, start all services
if [ -z "$CONTAINERS" ]; then
  CONTAINERS=$(ls compose -I "$REVERSE_PROXY*" -I "$AUTH*" -1 | sed -e 's/\..*$//')

  if [ "$COMPOSE_ARGS" = "down" ]; then
    # reverse
    CONTAINERS=("${CONTAINERS[@]}" "$AUTH" "$REVERSE_PROXY")
  else
    # start proxy & proxy network first
    CONTAINERS=("$REVERSE_PROXY" "$AUTH" "${CONTAINERS[@]}")
  fi
fi

COMMAND="/usr/local/bin/docker-compose"

# start each service from yml file in docker-compose detached mode
for c in ${CONTAINERS[@]}; do
  printf "\n### $c $COMPOSE_ARGS ###\n"
  $COMMAND -f "compose/$c.yml" -p $c $COMPOSE_ARGS
  printf "\n"
done
