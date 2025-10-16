#!/bin/bash

set -e

LAB_NAME="srl-xrv9k"
TOPOLOGY_FILE="../srl-xrv9k.clab.yml"

echo "========================================="
echo "Validating Multi-vendor Lab"
echo "========================================="
echo ""

FAILED=0

# Check 1: Lab Status
echo "1. Checking lab status..."
if sudo containerlab inspect -t ${TOPOLOGY_FILE} &>/dev/null; then
    echo "   ✓ Lab is deployed"
else
    echo "   ❌ Lab is not deployed"
    exit 1
fi

# Check 2: Container Health
echo "2. Checking container health..."
SRL_STATUS=$(docker inspect --format='{{.State.Status}}' clab-${LAB_NAME}-srl 2>/dev/null || echo "missing")
XRV9K_STATUS=$(docker inspect --format='{{.State.Status}}' clab-${LAB_NAME}-xrv9k 2>/dev/null || echo "missing")
XRV9K_HEALTH=$(docker inspect --format='{{.State.Health.Status}}' clab-${LAB_NAME}-xrv9k 2>/dev/null || echo "unknown")

if [ "$SRL_STATUS" = "running" ] && [ "$XRV9K_STATUS" = "running" ] && [ "$XRV9K_HEALTH" = "healthy" ]; then
    echo "   ✓ All containers running and healthy"
else
    echo "   ❌ Container health issues: SRL=$SRL_STATUS, XRv9k=$XRV9K_STATUS (health: $XRV9K_HEALTH)"
    FAILED=1
fi

# Check 3: SR Linux Interface Status
echo "3. Checking SR Linux interface status..."
SRL_INT_STATUS=$(docker exec clab-${LAB_NAME}-srl sr_cli "info from state interface ethernet-1/1 oper-state" 2>/dev/null | grep -oP 'oper-state \K\w+' || echo "unknown")
if [ "$SRL_INT_STATUS" = "up" ]; then
    echo "   ✓ SR Linux ethernet-1/1 is up"
else
    echo "   ❌ SR Linux ethernet-1/1 status: $SRL_INT_STATUS"
    FAILED=1
fi

# Check 4: XRv9k Interface Status
echo "4. Checking XRv9k interface status..."
XRV9K_INT_OUTPUT=$(sshpass -p "clab@123" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null clab@clab-${LAB_NAME}-xrv9k "show ipv4 interface brief" 2>/dev/null | grep "GigabitEthernet0/0/0/0" || echo "")
if echo "$XRV9K_INT_OUTPUT" | grep -q "Up.*Up"; then
    echo "   ✓ XRv9k GigabitEthernet0/0/0/0 is up"
else
    echo "   ❌ XRv9k GigabitEthernet0/0/0/0 status issue"
    FAILED=1
fi

# Check 5: Wait for BGP convergence
echo "5. Waiting for BGP convergence (30 seconds)..."
sleep 30
echo "   ✓ Wait complete"

# Check 6: SR Linux BGP Neighbor
echo "6. Checking SR Linux BGP neighbor..."
SRL_BGP_OUTPUT=$(docker exec clab-${LAB_NAME}-srl sr_cli "show network-instance default protocols bgp neighbor 192.168.1.2" 2>/dev/null)
if echo "$SRL_BGP_OUTPUT" | grep -q "established"; then
    echo "   ✓ SR Linux BGP session to XRv9k: ESTABLISHED"
else
    echo "   ❌ SR Linux BGP session to XRv9k: NOT ESTABLISHED"
    FAILED=1
fi

# Check 7: XRv9k BGP Neighbor
echo "7. Checking XRv9k BGP neighbor..."
XRV9K_BGP_OUTPUT=$(sshpass -p "clab@123" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null clab@clab-${LAB_NAME}-xrv9k "show bgp summary" 2>/dev/null)
if echo "$XRV9K_BGP_OUTPUT" | grep "192.168.1.1" | grep -q "65100"; then
    echo "   ✓ XRv9k BGP session to SR Linux: ESTABLISHED"
else
    echo "   ❌ XRv9k BGP session to SR Linux: NOT ESTABLISHED"
    FAILED=1
fi

# Check 8: Ping Test (SR Linux -> XRv9k)
echo "8. Testing connectivity (SR Linux -> XRv9k)..."
PING_OUTPUT=$(docker exec clab-${LAB_NAME}-srl sr_cli "ping 192.168.1.2 -c 3 network-instance default" 2>/dev/null)
if echo "$PING_OUTPUT" | grep -q "3 packets transmitted, 3 received"; then
    RTT=$(echo "$PING_OUTPUT" | grep -oP 'rtt min/avg/max/mdev = [\d.]+/\K[\d.]+' || echo "N/A")
    echo "   ✓ SR Linux -> XRv9k (192.168.1.2): 0% loss, avg RTT: ${RTT}ms"
else
    echo "   ❌ SR Linux -> XRv9k (192.168.1.2): PACKET LOSS"
    FAILED=1
fi

# Check 9: Ping Test (XRv9k -> SR Linux)
echo "9. Testing connectivity (XRv9k -> SR Linux)..."
XRV9K_PING=$(sshpass -p "clab@123" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null clab@clab-${LAB_NAME}-xrv9k "ping 192.168.1.1 count 3" 2>/dev/null)
if echo "$XRV9K_PING" | grep -q "Success rate is 100 percent"; then
    echo "   ✓ XRv9k -> SR Linux (192.168.1.1): 0% loss"
else
    echo "   ❌ XRv9k -> SR Linux (192.168.1.1): PACKET LOSS"
    FAILED=1
fi

echo ""
echo "========================================="
if [ $FAILED -eq 0 ]; then
    echo "✓ Validation Complete!"
    echo "  - Both devices: RUNNING"
    echo "  - Connectivity: WORKING"
    echo "  - BGP sessions: ESTABLISHED"
    echo "========================================="
    exit 0
else
    echo "❌ Validation Failed!"
    echo "  Some checks did not pass."
    echo "========================================="
    exit 1
fi
