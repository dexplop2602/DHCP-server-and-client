# -*- mode: ruby -*-
# vi: set ft=ruby :

#
# DHCP-SERVER-AND-CLIENT (David Expósito López)
#

Vagrant.configure("2") do |config|

  config.vm.box = "ubuntu/focal64"

  # Máquina Virtual: Servidor DHCP
  config.vm.define "server" do |server|
    server.vm.network "private_network", ip: "192.168.56.10"
    server.vm.network "private_network", ip: "192.168.57.10", virtualbox__intnet: "dhcp-net"
    server.vm.provision "file", source: "dhcpd.conf", destination: "/tmp/dhcpd.conf"
    server.vm.provision "file", source: "isc-dhcp-server", destination: "/tmp/isc-dhcp-server"
    server.vm.provision "shell", path: "provision.sh"
  end

  # Máquina Virtual: Cliente 1 (obtiene IP dinámica)
  config.vm.define "c1" do |c1|
    c1.vm.network "private_network", type: "dhcp", virtualbox__intnet: "dhcp-net"
  end

  # Máquina Virtual: Cliente 2 (obtiene IP fija por MAC)
  config.vm.define "c2" do |c2|
    c2.vm.network "private_network", type: "dhcp", virtualbox__intnet: "dhcp-net", mac: "080027000002"
  end

end