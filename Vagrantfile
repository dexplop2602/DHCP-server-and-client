#DHCP-SERVER-AND-CLIENT (David Expósito López)
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/focal64"

  # Server DHCP
  config.vm.define "server" do |server|
    server.vm.network "private_network", ip: "192.168.56.10"
    server.vm.network "private_network", ip: "192.168.57.10", virtualbox__intnet: "dhcp-net"
  end

  # Client 1 (IP Dinamic)
  config.vm.define "c1" do |c1|
    c1.vm.network "private_network", virtualbox__intnet: "dhcp-net", type: "dhcp"
  end

  # Client 2 (IP Static for MAC)
  config.vm.define "c2" do |c2|
    c2.vm.network "private_network", virtualbox__intnet: "dhcp-net", type: "dhcp", mac: "080027000002"
  end
end