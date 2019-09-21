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
    u)  COMPOSE_ARGS="up -d"
        ;;
    d)  COMPOSE_ARGS="down"
        ;;
    *)  COMPOSE_ARGS="up -d"
        ;;
    esac
done

shift $((OPTIND-1))

CONTAINERS="$@"

REVERSE_PROXY="traefik"
AUTH="auth"

# if no arguments, start all services
if [ -z "$CONTAINERS" ]; then
  CONTAINERS=$(ls compose -I "$REVERSE_PROXY*" -I "$AUTH*" -1 | sed -e 's/\..*$//')

  if [ "$COMPOSE_ARGS" = "down" ]; then
    # start proxy & proxy network first
    CONTAINERS=("$REVERSE_PROXY" "$AUTH" "${CONTAINERS[@]}")
  else
    # reverse
    CONTAINERS=("${CONTAINERS[@]}" "$AUTH" "$REVERSE_PROXY")
  fi
fi

# start each service from yml file in docker-compose detached mode
for c in ${CONTAINERS[@]}; do
  printf "\n### $c $COMPOSE_ARGS ###\n"
  docker-compose -f "compose/$c.yml" -p $c $COMPOSE_ARGS
  printf "\n"
done
