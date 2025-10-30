#!/bin/bash
# Minastir
echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf
sysctl -p
sysctl -w net.ipv4.ip_forward=1

iptables -F
iptables -t nat -F
iptables -t mangle -F
iptables -X

iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

iptables -A FORWARD -i eth1 -o eth0 -j ACCEPT
iptables -A FORWARD -i eth0 -o eth1 -m state --state ESTABLISHED,RELATED -j ACCEPT

iptables -A OUTPUT -o eth0 -s 192.222.0.0/16 -j DROP
iptables -A OUTPUT -o eth0 -s 192.222.3.95 -j ACCEPT   # IP Durin, dikecualikan

