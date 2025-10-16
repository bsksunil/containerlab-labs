#!/bin/bash

# Apply XRv9k configuration
echo "Applying XRv9k configuration..."

sshpass -p "clab@123" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null clab@clab-srl-xrv9k-xrv9k <<EOF
configure
hostname xrv9k
interface MgmtEth0/RP0/CPU0/0
 ipv4 address dhcp
exit
interface GigabitEthernet0/0/0/0
 ipv4 address 192.168.1.2 255.255.255.252
 no shutdown
exit
router bgp 65200
 bgp router-id 10.0.0.2
 address-family ipv4 unicast
 exit
 neighbor 192.168.1.1
  remote-as 65100
  address-family ipv4 unicast
  exit
 exit
exit
commit
end
EOF

echo "XRv9k config applied!"
