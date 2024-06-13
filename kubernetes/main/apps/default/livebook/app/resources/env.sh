#!/usr/bin/env bash

export LIVEBOOK_IP="${POD_IP:-$(hostname -i)}"
export LIVEBOOK_NODE="livebook@$LIVEBOOK_IP"
