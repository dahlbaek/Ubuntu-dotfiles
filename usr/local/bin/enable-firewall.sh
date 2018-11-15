#!/bin/sh

set -euf
IFS=''
PATH='/sbin'

## Clear iptables
iptables -F

## Set default policy DROP
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP

## Allow loopback
iptables -A OUTPUT -o lo -m conntrack --ctstate NEW -j ACCEPT
iptables -A INPUT -i lo -m conntrack --ctstate ESTABLISHED -j ACCEPT

iptables -A INPUT -i lo -m conntrack --ctstate NEW -j ACCEPT
iptables -A OUTPUT -o lo -m conntrack --ctstate ESTABLISHED -j ACCEPT

## Allow NTP - Network Time Protocol
iptables -A OUTPUT -p udp --dport 123 -m conntrack --ctstate NEW -j ACCEPT
iptables -A INPUT -p udp --sport 123 -m conntrack --ctstate ESTABLISHED -j ACCEPT

## Allow DNS - Domain Name System
iptables -A OUTPUT -p udp --dport 53 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -p udp --sport 53 -m conntrack --ctstate ESTABLISHED -j ACCEPT

## Allow imap
iptables -A OUTPUT -p tcp --dport 993 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp --sport 993 -m conntrack --ctstate ESTABLISHED -j ACCEPT

## Allow smtp
iptables -A OUTPUT -p tcp --dport 587 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp --sport 587 -m conntrack --ctstate ESTABLISHED -j ACCEPT

## Allow HTTPS
iptables -A OUTPUT -p tcp -m multiport --dports 443 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp -m multiport --sports 443 -m conntrack --ctstate ESTABLISHED -j ACCEPT

## Log everything that is dropped
iptables -A INPUT -j LOG --log-prefix "INPUT:DROP:" --log-level 6
iptables -A FORWARD -j LOG --log-prefix "FORWARD:DROP:" --log-level 6
iptables -A OUTPUT -j LOG --log-prefix "OUTPUT:DROP:" --log-level 6

## Save rules
iptables-save >/etc/iptables.conf
