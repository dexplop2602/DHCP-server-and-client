#!/bin/bash
set -eux

apt-get update
apt-get install -y isc-dhcp-server

mv /tmp/dhcpd.conf /etc/dhcp/dhcpd.conf
mv /tmp/isc-dhcp-server /etc/default/isc-dhcp-server


chown root:root /etc/dhcp/dhcpd.conf
chown root:root /etc/default/isc-dhcp-server

systemctl restart isc-dhcp-server.service