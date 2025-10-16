#!/bin/bash

set -e

TOPOLOGY_FILE="../srl-xrv9k.clab.yml"

echo "========================================="
echo "Destroying Multi-vendor Lab"
echo "========================================="

sudo containerlab destroy -t ${TOPOLOGY_FILE} --cleanup

echo ""
echo "✓ Lab destroyed and cleaned up!"
echo ""
