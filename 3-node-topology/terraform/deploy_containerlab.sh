#!/bin/bash
set -e

# Navigate to the containerlab config directory
cd "$1"

# Deploy the containerlab topology
echo "========================================="
echo "Deploying 3-Node CLOS Topology..."
echo "========================================="

# Check if lab already exists
if sudo containerlab inspect -t clos01.clab.yml &>/dev/null; then
    echo "Lab already exists. Redeploying with --reconfigure..."
    sudo containerlab deploy -t clos01.clab.yml --reconfigure
else
    echo "Deploying fresh lab..."
    sudo containerlab deploy -t clos01.clab.yml
fi

echo ""
echo "✓ Deployment completed successfully!"
echo ""

# Configure client IPs automatically
echo "Configuring client IP addresses..."
sleep 2  # Give clients a moment to fully start

# Client1 configuration
docker exec clab-clos01-client1 ip addr add 192.168.1.10/24 dev eth1 2>/dev/null || echo "Client1 IP already configured"
docker exec clab-clos01-client1 ip route add default via 192.168.1.1 2>/dev/null || echo "Client1 route already configured"

# Client2 configuration
docker exec clab-clos01-client2 ip addr add 192.168.2.10/24 dev eth1 2>/dev/null || echo "Client2 IP already configured"
docker exec clab-clos01-client2 ip route add default via 192.168.2.1 2>/dev/null || echo "Client2 route already configured"

echo "✓ Client configuration completed!"
echo ""
echo "Lab Details:"
sudo containerlab inspect -t clos01.clab.yml
