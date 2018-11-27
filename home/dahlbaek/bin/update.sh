#!/bin/sh

set -euf
IFS=''
PATH='/usr/bin'

sudo -- /usr/bin/apt-get -- update
sudo -- /usr/bin/apt-get -- upgrade
