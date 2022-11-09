#!/bin/sh

CGIT_VARS='$ROOT_TITLE:$ROOT_DESC:$SECTION_FROM_STARTPATH:$MAX_REPO_COUNT:$ROOT_README:$NOPLAINEMAIL'
envsubst "$CGIT_VARS" < /etc/cgitrc.template > /etc/cgitrc

spawn-fcgi -U nginx -G nginx -M 600 -s /var/run/fcgiwrap.sock /usr/bin/fcgiwrap

nginx -g "daemon off;"
