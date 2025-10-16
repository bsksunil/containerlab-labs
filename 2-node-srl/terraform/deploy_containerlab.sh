#!/bin/bash
set -e

# Navigate to the containerlab config directory
cd "$1"

# Deploy the containerlab topology
echo "========================================="
echo "Deploying 2-Node SR Linux Topology..."
echo "========================================="

# Check if lab already exists
if sudo containerlab inspect -t srl02-simple.clab.yml &>/dev/null; then
    echo "Lab already exists. Redeploying with --reconfigure..."
    sudo containerlab deploy -t srl02-simple.clab.yml --reconfigure
else
    echo "Deploying fresh lab..."
    sudo containerlab deploy -t srl02-simple.clab.yml
fi

echo ""
echo "✓ Deployment completed successfully!"
echo ""
echo "Lab Details:"
sudo containerlab inspect -t srl02-simple.clab.yml
