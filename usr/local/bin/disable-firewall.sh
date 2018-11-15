#!/bin/sh

set -euf
IFS=''
PATH='/sbin'

## Clear iptables
iptables -F

## Set default policy DROP
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT
