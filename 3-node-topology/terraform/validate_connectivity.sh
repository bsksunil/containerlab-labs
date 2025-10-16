#!/bin/bash
set -e

echo "========================================="
echo "Validating 3-Node CLOS Connectivity"
echo "========================================="

CLAB_FILE="$1/clos01.clab.yml"

# Check if lab is running
echo "1. Checking if lab is running..."
if ! sudo containerlab inspect -t "$CLAB_FILE" &>/dev/null; then
    echo "❌ ERROR: Lab is not running!"
    exit 1
fi
echo "✓ Lab is running"

# Get container names
SPINE1="clab-clos01-spine1"
LEAF1="clab-clos01-leaf1"
LEAF2="clab-clos01-leaf2"
CLIENT1="clab-clos01-client1"
CLIENT2="clab-clos01-client2"

echo ""
echo "2. Checking container health..."
for CONTAINER in "$SPINE1" "$LEAF1" "$LEAF2" "$CLIENT1" "$CLIENT2"; do
    if ! docker ps --filter "name=$CONTAINER" --filter "status=running" | grep -q "$CONTAINER"; then
        echo "❌ ERROR: $CONTAINER is not running!"
        exit 1
    fi
done
echo "✓ All 5 containers are healthy"

echo ""
echo "3. Checking interface status on spine1..."
INT1_STATUS=$(docker exec "$SPINE1" sr_cli "show interface ethernet-1/1 brief" 2>/dev/null | grep ethernet-1/1 || echo "")
INT2_STATUS=$(docker exec "$SPINE1" sr_cli "show interface ethernet-1/2 brief" 2>/dev/null | grep ethernet-1/2 || echo "")
if [ -n "$INT1_STATUS" ] && echo "$INT1_STATUS" | grep -q "up"; then
    echo "✓ ethernet-1/1 is UP"
fi
if [ -n "$INT2_STATUS" ] && echo "$INT2_STATUS" | grep -q "up"; then
    echo "✓ ethernet-1/2 is UP"
fi

echo ""
echo "4. Waiting for BGP to converge (20 seconds)..."
sleep 20

echo ""
echo "5. Testing underlay connectivity (Leaf1 -> Spine1)..."
PING1=$(docker exec "$LEAF1" sr_cli "ping 10.1.1.1 -c 3 network-instance default" 2>/dev/null || echo "failed")
if echo "$PING1" | grep -q "3 packets transmitted, 3 received"; then
    echo "✓ Leaf1 -> Spine1 (10.1.1.1): 0% loss"
    echo "$PING1" | grep "rtt" || true
else
    echo "❌ Leaf1 -> Spine1 connectivity failed"
    exit 1
fi

echo ""
echo "6. Testing underlay connectivity (Leaf2 -> Spine1)..."
PING2=$(docker exec "$LEAF2" sr_cli "ping 10.1.2.1 -c 3 network-instance default" 2>/dev/null || echo "failed")
if echo "$PING2" | grep -q "3 packets transmitted, 3 received"; then
    echo "✓ Leaf2 -> Spine1 (10.1.2.1): 0% loss"
    echo "$PING2" | grep "rtt" || true
else
    echo "❌ Leaf2 -> Spine1 connectivity failed"
    exit 1
fi

echo ""
echo "7. Checking BGP session status on Spine1..."
BGP_SPINE=$(docker exec "$SPINE1" sr_cli "show network-instance default protocols bgp neighbor" 2>/dev/null || echo "")
LEAF1_BGP=$(echo "$BGP_SPINE" | grep "10.1.1.0" | grep -o "established" || echo "")
LEAF2_BGP=$(echo "$BGP_SPINE" | grep "10.1.2.0" | grep -o "established" || echo "")

if [ "$LEAF1_BGP" = "established" ]; then
    echo "✓ BGP session Spine1 <-> Leaf1 is ESTABLISHED"
else
    echo "❌ BGP session Spine1 <-> Leaf1 is NOT established"
    exit 1
fi

if [ "$LEAF2_BGP" = "established" ]; then
    echo "✓ BGP session Spine1 <-> Leaf2 is ESTABLISHED"
else
    echo "❌ BGP session Spine1 <-> Leaf2 is NOT established"
    exit 1
fi

echo ""
echo "8. Checking BGP session on Leaf1..."
BGP_LEAF1=$(docker exec "$LEAF1" sr_cli "show network-instance default protocols bgp neighbor" 2>/dev/null || echo "")
if echo "$BGP_LEAF1" | grep "10.1.1.1" | grep -q "established"; then
    echo "✓ BGP session Leaf1 <-> Spine1 is ESTABLISHED"
else
    echo "❌ BGP session Leaf1 <-> Spine1 is NOT established"
    exit 1
fi

echo ""
echo "9. Checking BGP session on Leaf2..."
BGP_LEAF2=$(docker exec "$LEAF2" sr_cli "show network-instance default protocols bgp neighbor" 2>/dev/null || echo "")
if echo "$BGP_LEAF2" | grep "10.1.2.1" | grep -q "established"; then
    echo "✓ BGP session Leaf2 <-> Spine1 is ESTABLISHED"
else
    echo "❌ BGP session Leaf2 <-> Spine1 is NOT established"
    exit 1
fi

echo ""
echo "10. Testing client connectivity (Client1 -> Gateway)..."
CLIENT1_PING=$(docker exec "$CLIENT1" ping -c 3 192.168.1.1 2>/dev/null || echo "failed")
if echo "$CLIENT1_PING" | grep -q "3 packets transmitted, 3.*received"; then
    echo "✓ Client1 -> Gateway (192.168.1.1): 0% loss"
    echo "$CLIENT1_PING" | grep "rtt" || true
else
    echo "❌ Client1 -> Gateway connectivity FAILED"
    exit 1
fi

echo ""
echo "11. Testing client connectivity (Client2 -> Gateway)..."
CLIENT2_PING=$(docker exec "$CLIENT2" ping -c 3 192.168.2.1 2>/dev/null || echo "failed")
if echo "$CLIENT2_PING" | grep -q "3 packets transmitted, 3.*received"; then
    echo "✓ Client2 -> Gateway (192.168.2.1): 0% loss"
    echo "$CLIENT2_PING" | grep "rtt" || true
else
    echo "❌ Client2 -> Gateway connectivity FAILED"
    exit 1
fi

echo ""
echo "========================================="
echo "✓ Validation Complete!"
echo "========================================="
echo ""
echo "Summary:"
echo "  - All 5 containers running"
echo "  - Underlay connectivity: WORKING"
echo "  - BGP sessions (3 total): ALL ESTABLISHED"
echo "  - Client connectivity: TESTED"
echo ""
sudo containerlab inspect -t "$CLAB_FILE"
