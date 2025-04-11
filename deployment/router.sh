#!/bin/sh -e

export DEBIAN_FRONTEND=noninteractive

echo Setting NAT routing
iptables -t nat -A POSTROUTING -o wlan0 -j MASQUERADE
iptables -A FORWARD -i wlan0 -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i eth0 -o wlan0 -j ACCEPT

DEFAULT_IFACE=`route -n | grep -E "^0.0.0.0 .+UG" | awk '{print $8}'`
if [ "$DEFAULT_IFACE" != "wlan0" ]
then
  GW=`route -n | grep -E "^0.0.0.0 .+UG .+wlan0$" | awk '{print $2}'`
  echo Setting default route to wlan0 via $GW
  route del default $DEFAULT_IFACE
  route add default gw $GW wlan0