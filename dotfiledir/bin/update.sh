#!/bin/bash

set -euf -o pipefail
IFS=$'\n'

sudo apt-get update
sudo apt-get upgrade
