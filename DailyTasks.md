# PROJECT DAILY LOGS

This log tracks the day-by-day progress of the DHCP practice.

## Day 03/10/25: Project Initialization and Environment Setup
- Created the initial README.md for project documentation.
- Authored the Vagrantfile to define the virtual environment, including:
  - The 'server', 'c1', and 'c2' virtual machines.
  - The required private and internal network configurations.
  - The assignment of a static MAC address to the 'c2' machine.


## Day 06/10/25: Initial Server Configuration
  - Established this technical log (Practice Memory) for progress tracking.
  - Accessed the 'server' VM and installed the 'isc-dhcp-server' package.
  - Configured the service to listen on the correct network interface by modifying the 'INTERFACESv4' directive.

## Day 09/10/25: Full Implementation and Completion
  - Finalized the DHCP practice, completing all steps from the core server configuration.
  - Configured '/etc/dhcp/dhcpd.conf' with both the dynamic range (for 'c1') and the static host assignment (for 'c2').
  - Successfully verified that both clients received their intended IP addresses.
  - Troubleshot and resolved a client lease issue by reloading the 'c2' VM.
  - Confirmed correct DNS settings were applied using 'resolvectl status'.
  - We worked as a team on both tasks. I was the one typing the commands, and my partner was typing the documentation, but we decided on the content for both together.
  - The practice is now 100% complete.