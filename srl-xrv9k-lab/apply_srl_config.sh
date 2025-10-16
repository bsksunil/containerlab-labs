#!/bin/bash

# Apply SR Linux configuration
echo "Applying SR Linux configuration..."

docker exec clab-srl-xrv9k-srl sr_cli <<EOF
enter candidate
interface ethernet-1/1 admin-state enable
interface ethernet-1/1 subinterface 0 admin-state enable
interface ethernet-1/1 subinterface 0 ipv4 admin-state enable
interface ethernet-1/1 subinterface 0 ipv4 address 192.168.1.1/30
network-instance default interface ethernet-1/1.0
network-instance default protocols bgp admin-state enable
network-instance default protocols bgp autonomous-system 65100
network-instance default protocols bgp router-id 10.0.0.1
network-instance default protocols bgp afi-safi ipv4-unicast admin-state enable
network-instance default protocols bgp group ebgp admin-state enable
network-instance default protocols bgp group ebgp afi-safi ipv4-unicast admin-state enable
network-instance default protocols bgp group ebgp peer-as 65200
network-instance default protocols bgp neighbor 192.168.1.2 peer-group ebgp
commit now
EOF

echo "SR Linux config applied!"
