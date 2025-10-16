#!/bin/bash
set -e

# Navigate to the containerlab config directory
cd "$1"

# Destroy the containerlab topology
echo "========================================="
echo "Destroying 3-Node CLOS Topology..."
echo "========================================="
sudo containerlab destroy -t clos01.clab.yml --cleanup 2>/dev/null || echo "Topology already destroyed or not found"

echo ""
echo "✓ Destruction completed successfully!"
