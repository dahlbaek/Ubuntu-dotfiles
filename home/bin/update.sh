#!/bin/sh

set -euf
IFS=''

sudo /usr/bin/apt-get update
sudo /usr/bin/apt-get upgrade
