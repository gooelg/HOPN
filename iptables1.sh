#!/bin/sh
IPTABLES=/sbin/iptables
# Flushing & Setting Default Rules
service iptables stop
$IPTABLES -A INPUT -p icmp -m limit --limit 10/s --limit-burst 1 -j ACCEPT
$IPTABLES -A INPUT -p icmp -j DROP
$IPTABLES -A INPUT -i lo -s 127.0.0.1 -j ACCEPT
$IPTABLES -A INPUT -p tcp --dport 1202 -j ACCEPT
$IPTABLES -A INPUT -p udp -m udp --dport 5060 -s 176.9.51.8 -j ACCEPT
$IPTABLES -A INPUT -p udp -m udp -s 172.100.0.65 -j ACCEPT
$IPTABLES -A INPUT -p udp -m udp -s 172.100.0.81 -j ACCEPT
$IPTABLES -A INPUT -p udp -m udp -s 172.100.0.97 -j ACCEPT
$IPTABLES -A INPUT -p udp -m udp -s 172.100.0.113 -j ACCEPT
$IPTABLES -A INPUT -p udp -m udp -s 172.100.0.129 -j ACCEPT
$IPTABLES -A INPUT -p udp -m udp -s 172.100.0.145 -j ACCEPT
$IPTABLES -A INPUT -p udp -m udp -s 172.100.0.161 -j ACCEPT 206
$IPTABLES -A INPUT -p udp -m udp -s 172.100.0.177 -j ACCEPT 202
$IPTABLES -A INPUT -p udp -m udp -s 172.100.0.193 -j ACCEPT 241
$IPTABLES -A INPUT -p udp -m udp -s 172.100.0.209 -j ACCEPT
$IPTABLES -A INPUT -p udp -m udp -s 172.100.0.225 -j ACCEPT
$IPTABLES -A INPUT -p udp -m udp -s 172.100.0.241 -j ACCEPT


$IPTABLES -A INPUT -p tcp -m tcp -s 172.100.0.65 -j ACCEPT
$IPTABLES -A INPUT -p tcp -m tcp -s 172.100.0.81 -j ACCEPT
$IPTABLES -A INPUT -p tcp -m tcp -s 172.100.0.97 -j ACCEPT
$IPTABLES -A INPUT -p tcp -m tcp -s 172.100.0.113 -j ACCEPT
$IPTABLES -A INPUT -p tcp -m tcp -s 172.100.0.129 -j ACCEPT
$IPTABLES -A INPUT -p tcp -m tcp -s 172.100.0.145 -j ACCEPT
$IPTABLES -A INPUT -p tcp -m tcp -s 172.100.0.161 -j ACCEPT
$IPTABLES -A INPUT -p tcp -m tcp -s 172.100.0.177 -j ACCEPT
$IPTABLES -A INPUT -p tcp -m tcp -s 172.100.0.193 -j ACCEPT
$IPTABLES -A INPUT -p tcp -m tcp -s 172.100.0.209 -j ACCEPT
$IPTABLES -A INPUT -p tcp -m tcp -s 172.100.0.225 -j ACCEPT
$IPTABLES -A INPUT -p tcp -m tcp -s 172.100.0.241 -j ACCEPT
$IPTABLES -A INPUT -p udp -m udp --dport 5060 -j DROP
$IPTABLES -A INPUT -p tcp --dport 3306 -j DROP
$IPTABLES -A INPUT -p tcp --dport 80 -j DROP
service iptables save
service iptables start

