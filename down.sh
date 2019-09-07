#!/bin/bash

CONTAINERS="$@"
for c in $CONTAINERS
do
  echo""
  echo "...$c down..."
  echo""
  docker-compose -f "compose/$c.yml" -p $c down
done
