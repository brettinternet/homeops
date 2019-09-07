#!/bin/bash

CONTAINERS="$@"
for c in $CONTAINERS
do
  printf "\n...$c up...\n"
  docker-compose -f "compose/$c.yml" -p $c up -d
done
