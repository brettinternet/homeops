#!/bin/bash

CONTAINERS="$@"
for c in $CONTAINERS
do
  printf "\n### $c down ###\n"
  docker-compose -f "compose/$c.yml" -p $c down
done
