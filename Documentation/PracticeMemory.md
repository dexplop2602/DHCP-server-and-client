# TECHNICAL LOG: DHCP Server Configuration (Completed & Debugged)
# -----------------------------------------------------------------

This document details the full procedure, including the environment setup, troubleshooting steps, and final file export for the DHCP practice.

# -----------------------------------------------------------------

## STEP 1: Virtual Environment Setup (Vagrantfile)
The foundation of the practice is the Vagrantfile, which defines the VMs and their networking.
The following configuration was used:

      Vagrant.configure("2") do |config|
         config.vm.box = "ubuntu/focal64"
   
      ### Server DHCP
      config.vm.define "server" do |server|
        server.vm.network "private_network", ip: "192.168.56.10"
        server.vm.network "private_network", ip: "192.168.57.10", virtualbox__intnet: "dhcp-net"
      end
   
      ### Client 1 (IP Dinamic)
      config.vm.define "c1" do |c1|
        c1.vm.network "private_network", virtualbox__intnet: "dhcp-net", type: "dhcp"
      end
   
      ### Client 2 (IP Static for MAC)
      config.vm.define "c2" do |c2|
        c2.vm.network "private_network", virtualbox__intnet: "dhcp-net", type: "dhcp", mac: "080027000002"
      end
    end

#### EXPLANATION:
  - Server: Has two network cards. One for management (192.168.56.10) and one for the internal, isolated network 'dhcp-net' (192.168.57.10) where it will serve IPs.
  - Client c1: Connects to 'dhcp-net' and is configured as a DHCP client.
  - Client c2: Same as c1, but we assign a specific MAC address ('080027000002'). This MAC is the key to assigning it a fixed IP later in the DHCP server configuration.


## STEP 2: Launching the Virtual Environment
With the Vagrantfile in place, the environment was launched.

      vagrant up

## STEP 3: Server Setup and Configuration
Configuration of the 'server' machine.

- Connection via SSH:

        vagrant ssh server

- Identification of the internal network interface ('enp0s9') with:

      ip a

- Installation of the DHCP service:

        sudo apt-get update
        sudo apt-get install -y isc-dhcp-server

- Configuration of the listening interface in '/etc/default/isc-dhcp-server'. The 'INTERFACESv4' directive was set to:
  - INTERFACESv4="enp0s9"

## STEP 4: DHCP Service Configuration
Definition of the DHCP network parameters.

- A backup of the original configuration was created:
  
      sudo cp /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.bak

- The main configuration file '/etc/dhcp/dhcpd.conf' was edited with this content:
  
      subnet 192.168.57.0 netmask 255.255.255.0 {
        range 192.168.57.25 192.168.57.50;
        option domain-name-servers 8.8.8.8, 4.4.4.4;
        option domain-name "micasa.es";
        option routers 192.168.57.10;
        option broadcast-address 192.168.57.255;
        default-lease-time 86400;
        max-lease-time 691200;
      }

- Syntax was checked, and the service was restarted and its status verified.
  
      sudo dhcpd -t
      sudo systemctl restart isc-dhcp-server
      sudo systemctl status isc-dhcp-server

## STEP 5: Client 'c1' Verification
We verified that 'c1' obtained a dynamic IP correctly.

- Server logs confirmed the DHCP transaction (DISCOVER, OFFER, REQUEST, ACK).
  
      vagrant ssh c1
      ip a

- On server: grep dhcpd /var/log/syslog

## STEP 6: Static IP Assignment and Debugging for 'c2'
The static IP assignment was added to '/etc/dhcp/dhcpd.conf' ON THE SERVER.

      host c2 {
        hardware ethernet 08:00:27:00:00:02;
        fixed-address 192.168.57.4;
        option domain-name-servers 1.1.1.1;
        default-lease-time 3600;
        max-lease-time 7200;
      }

The service was restarted on the server. Verification on 'c2' required troubleshooting.
NOTE: The following commands and checks were performed on the 'c2' machine.

- ISSUE 1: Client 'c2' kept its old dynamic IP or had two IPs.
- CAUSE: The client had a valid DHCP lease and did not request a new one automatically.
- SOLUTION: The most effective solution was to restart the VM to force a clean DHCP request.

This command is run from the host machine:
vagrant reload c2

After reloading, verification with 'ip a' on 'c2' showed the correct fixed IP: 192.168.57.4.

- ISSUE 2: '/etc/resolv.conf' showed nameserver 127.0.0.53, not 1.1.1.1.
- CAUSE: Modern Ubuntu uses systemd-resolved, which acts as a local DNS proxy.
- SOLUTION: The correct DNS server was verified using the appropriate command on 'c2'. resolvectl status

This command's output confirmed that the DNS server for the enp0s8 interface was correctly set.

## STEP 7: Exporting Configuration Files
The final step was to copy the configuration files to the host machine.

- ISSUE: The 'vagrant scp' command was not found.
- CAUSE: The command is provided by a plugin, which was not installed.
- SOLUTION: The plugin was installed on the host machine.

      vagrant plugin install vagrant-scp

With the plugin installed, the files were successfully copied.

      vagrant scp server:/etc/dhcp/dhcpd.conf .
      vagrant scp server:/etc/default/isc-dhcp-server .

## STEP 8: Automating Configuration with Vagrant Provisioning
To make the environment fully reproducible and eliminate manual setup, the configuration was automated using Vagrant's provisioning feature.
This ensures that `vagrant up` not only creates the VMs but also configures the DHCP server completely without manual intervention.

### 1. FINAL VAGRANTFILE WITH PROVISIONING:
The Vagrantfile was updated to include a provisioning block for the 'server' VM.

 --- Provisioning Block ---
1. Copy local configuration files to the VM's /tmp/ directory.
   
          server.vm.provision "file", source: "dhcpd.conf", destination: "/tmp/dhcpd.conf"
          server.vm.provision "file", source: "isc-dhcp-server", destination: "/tmp/isc-dhcp-server"
   
3. Execute the external setup script.
   
          server.vm.provision "shell", path: "provision.sh"

### 2. PROVISIONING SCRIPT (provision.sh):
An external script named `provision.sh` was created to contain all the setup commands.
This script is executed automatically inside the server VM after it is created.

      #!/bin/bash
      apt-get update
      apt-get install -y isc-dhcp-server
      
      mv /tmp/dhcpd.conf /etc/dhcp/dhcpd.conf
      mv /tmp/isc-dhcp-server /etc/default/isc-dhcp-server
      chown root:root /etc/dhcp/dhcpd.conf
      chown root:root /etc/default/isc-dhcp-server

      systemctl restart isc-dhcp-server.service

#### EXPLANATION:
  - The `file` provisioner copies the necessary config files from the host to the guest.
  - The `shell` provisioner runs the `provision.sh` script inside the guest VM.
  - This script automates the installation (apt-get), configuration file placement (mv), and service restart (systemctl).
  - The entire manual process from steps 3, 4, and 6 is now codified. The project directory now only needs the `Vagrantfile`, `dhcpd.conf`, `isc-dhcp-server`, and `provision.sh` to recreate the exact environment with a single `vagrant up`.

