#!/bin/bash
set -e

echo "========================================="
echo "Validating 2-Node SR Linux Connectivity"
echo "========================================="

CLAB_FILE="$1/srl02-simple.clab.yml"

# Check if lab is running
echo "1. Checking if lab is running..."
if ! sudo containerlab inspect -t "$CLAB_FILE" &>/dev/null; then
    echo "❌ ERROR: Lab is not running!"
    exit 1
fi
echo "✓ Lab is running"

# Get container names
SRL1="clab-srl02-simple-srl1"
SRL2="clab-srl02-simple-srl2"

echo ""
echo "2. Checking container health..."
if ! docker ps --filter "name=$SRL1" --filter "status=running" | grep -q "$SRL1"; then
    echo "❌ ERROR: srl1 container is not running!"
    exit 1
fi
if ! docker ps --filter "name=$SRL2" --filter "status=running" | grep -q "$SRL2"; then
    echo "❌ ERROR: srl2 container is not running!"
    exit 1
fi
echo "✓ Both containers are healthy"

echo ""
echo "3. Checking interface status on srl1..."
INT_STATUS=$(docker exec "$SRL1" sr_cli "show interface ethernet-1/1 brief" 2>/dev/null | grep ethernet-1/1 || echo "")
if [ -z "$INT_STATUS" ]; then
    echo "⚠ Warning: Could not verify interface status"
else
    echo "$INT_STATUS"
    if echo "$INT_STATUS" | grep -q "up"; then
        echo "✓ Interface is UP"
    fi
fi

echo ""
echo "4. Waiting for protocols to converge (15 seconds)..."
sleep 15

echo ""
echo "5. Testing ICMP connectivity from srl1 to srl2 (10.0.0.2)..."
# Test ping from srl1 to srl2 with correct syntax
PING_RESULT=$(docker exec "$SRL1" sr_cli "ping 10.0.0.2 -c 5 network-instance default" 2>/dev/null || echo "failed")

if echo "$PING_RESULT" | grep -q "5 packets transmitted, 5 received"; then
    echo "✓ Ping successful: 100% packet delivery"
    echo "$PING_RESULT" | grep "packets transmitted"
    echo "$PING_RESULT" | grep "rtt"
elif echo "$PING_RESULT" | grep -q "packets transmitted"; then
    # Some packets received
    echo "⚠ Partial connectivity detected"
    echo "$PING_RESULT" | grep "packets transmitted"
else
    echo "❌ Ping failed - connectivity issue detected"
    exit 1
fi

echo ""
echo "6. Checking OSPF neighbor status..."
OSPF_STATUS=$(docker exec "$SRL1" sr_cli "show network-instance default protocols ospf neighbor" 2>/dev/null || echo "")
if echo "$OSPF_STATUS" | grep -q "full"; then
    echo "✓ OSPF neighbor is in Full state"
    echo "$OSPF_STATUS" | grep -i "full"
else
    echo "⚠ OSPF neighbor not in Full state"
fi

echo ""
echo "7. Checking BGP session status..."
BGP_STATUS=$(docker exec "$SRL1" sr_cli "show network-instance default protocols bgp neighbor" 2>/dev/null || echo "")
if echo "$BGP_STATUS" | grep -q "established"; then
    echo "✓ BGP session is established"
    echo "$BGP_STATUS" | grep -E "(10.0.0.2|established)" | head -2
else
    echo "⚠ BGP session not yet established"
fi

echo ""
echo "========================================="
echo "✓ Validation Complete!"
echo "========================================="
echo ""
echo "Summary:"
sudo containerlab inspect -t "$CLAB_FILE"
