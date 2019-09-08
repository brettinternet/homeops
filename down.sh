#!/bin/bash

CONTAINERS="$@"

# if no arguments, start all services
if [ -z "$CONTAINERS" ]; then
  CONTAINERS=$(ls compose -1 | sed -e 's/\..*$//')
fi

for c in $CONTAINERS; do
  printf "\n### $c down ###\n"
  docker-compose -f "compose/$c.yml" -p $c down
done
