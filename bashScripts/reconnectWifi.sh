#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
/bin/kill -9 `pidof wpa_supplicant`
systemctl daemon-reload
rfkill unblock all
ip link set wlan0 up
echo "rebooting system to setup new wifi connection..."
reboot
exit
