#!/bin/sh

export DEBIAN_FRONTEND=noninteractive

# Define ROLE and create or paste a ROLE_SCRIPT
# You can/should define ROLE_PACKAGES as well (e.g. ROLE_PACKAGES="htop nano git")

# Define all Debian/Ubuntu packages used in your ROLE_SCRIPT
ROLE_PACKAGES="git curl wget nano htop jq libcatalyst-perl libcatalyst-devel-perl libcatalyst-authentication-credential-http-perl libcatalyst-plugin-cache-perl libcatalyst-view-json-perl libcatalyst-view-tt-perl libcatalyst-actionrole-requiressl-perl libcatalyst-plugin-authorization-roles-perl libcatalyst-plugin-static-simple-perl libcatalyst-plugin-configloader-perl libcache-memcached-libmemcached-perl libjson-perl libfile-flock-perl libsort-naturally-perl cpanminus memcached starman ntp isc-dhcp-server"

clear
cd /opt/wifiWebUI/deployment

echo "####################################################"
echo "### Auto install for wifi Web UI                 ###"
echo "### version 0.2. stable / 20200310               ###"
echo "####################################################"
echo "\n"
echo "\n"
echo "### Starting auto install in...  (or press ctrl+c)"
sleep 1
echo "### 3 seconds"
sleep 1
echo "### 2"
sleep 1
echo "### 1"
sleep 1
echo "### Installation start: $(date)"

echo "### Updating system"
apt-get update -qy
apt-get upgrade -qy
apt-get dist-upgrade -qy

# START ROLE_SCRIPT
echo "### Installing debian packages via apt: $ROLE_PACKAGES"
apt-get install -qqy $ROLE_PACKAGES

apt-get clean -q
apt-get autoremove
apt-get autoclean

echo "### Installing Perl modules via cpanm"
cpanm -q App::cpanminus
cpanm -q JSON::Parse
cpanm -q Term::Size::Any
cpanm -q Template::Simple
cpanm -q Convert::Base64

echo "### Copying some files"
cp interfaces /etc/network/interfaces
cp rc.local /etc/rc.local
cp router.sh /opt/wifiWebUI/bashScripts/router.sh
chmod +x /opt/wifiWebUI/bashScripts/router.sh
chmod +x /opt/wifiWebUI/bashScripts/reconnectWifi.sh
cp dhcpd.conf /etc/dhcp/dhcpd.conf
cp sysctl.conf /etc/sysctl.conf
cp ntp.conf /etc/ntp.conf
cp isc-dhcp-server /etc/default/isc-dhcp-server

echo "### unblocking default blocked wi-fi."
rfkill unblock all

echo "### Auto install finished."
sleep 3

echo "### Auto reboot in... (or press ctrl+c)"
sleep 1
echo "### 3"
sleep 1
echo "### 2"
sleep 1
echo "### 1"
sleep 1
echo "### Installation end: $(date)"
echo "### rebooting..."
reboot
cd
