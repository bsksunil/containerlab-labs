#!/bin/bash

set -e

TOPOLOGY_FILE="../srl-xrv9k.clab.yml"
LAB_NAME="srl-xrv9k"

echo "========================================="
echo "Deploying Multi-vendor Lab"
echo "Topology: Nokia SR Linux + Cisco XRv9k"
echo "========================================="

# Check if lab already exists
if sudo containerlab inspect -t ${TOPOLOGY_FILE} &>/dev/null; then
    echo "Lab already exists. Redeploying with --reconfigure..."
    sudo containerlab deploy -t ${TOPOLOGY_FILE} --reconfigure
else
    echo "Deploying fresh lab..."
    sudo containerlab deploy -t ${TOPOLOGY_FILE}
fi

echo ""
echo "⏳ Waiting for XRv9k to become healthy (this may take 5-10 minutes)..."
echo ""

# Wait for XRv9k to reach healthy state
MAX_WAIT=600  # 10 minutes
ELAPSED=0
while [ $ELAPSED -lt $MAX_WAIT ]; do
    HEALTH_STATUS=$(docker inspect --format='{{.State.Health.Status}}' clab-${LAB_NAME}-xrv9k 2>/dev/null || echo "unknown")
    
    if [ "$HEALTH_STATUS" = "healthy" ]; then
        echo "✓ XRv9k is healthy after ${ELAPSED} seconds"
        break
    fi
    
    if [ $((ELAPSED % 30)) -eq 0 ]; then
        echo "   Still waiting... (${ELAPSED}s elapsed, status: ${HEALTH_STATUS})"
    fi
    
    sleep 5
    ELAPSED=$((ELAPSED + 5))
done

if [ $ELAPSED -ge $MAX_WAIT ]; then
    echo "⚠ Warning: XRv9k did not become healthy within ${MAX_WAIT} seconds"
    echo "   Current status: $HEALTH_STATUS"
    echo "   You may need to wait longer before validation"
fi

echo ""
echo "✓ Lab deployment complete!"
echo ""
echo "Lab Details:"
echo "  - SR Linux:  ssh admin@clab-${LAB_NAME}-srl  (password: NokiaSrl1!)"
echo "  - XRv9k:     ssh clab@clab-${LAB_NAME}-xrv9k (password: clab@123)"
echo ""
