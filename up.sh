#!/bin/bash

CONTAINERS="$@"

# if no arguments, start all services
if [ -z "$CONTAINERS" ]; then
  CONTAINERS=$(ls compose -1 | sed -e 's/\..*$//')
fi

# start each service from yml file in docker-compose detached mode
for c in $CONTAINERS; do
  printf "\n### $c up ###\n"
  docker-compose -f "compose/$c.yml" -p $c up -d
done
