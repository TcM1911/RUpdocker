#!/bin/bash

DIST=`cat /etc/os-release | grep NAME= -m 1 | cut -d "=" -f 2 | cut -d '"' -f 2`

if [ "$DIST" = "Ubuntu" ]; then
	echo "Debian based"
	sh /tmp/docker-update/debian.sh

else
	echo "Distribution not supported."
fi