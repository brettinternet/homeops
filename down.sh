#!/bin/bash

CONTAINERS="$@"

# if no arguments, start all services
if [ -z "$CONTAINERS" ]; then
  CONTAINERS=$(ls compose -I "traefik*" -I "auth*" -1 | sed -e 's/\..*$//')
  CONTAINERS=("${CONTAINERS[@]}" 'auth' 'traefik')
fi

# start each service from yml file in docker-compose detached mode
for c in ${CONTAINERS[@]}; do
  printf "\n### $c down ###\n"
  docker-compose -f "compose/$c.yml" -p $c down
  printf "\n"
done
