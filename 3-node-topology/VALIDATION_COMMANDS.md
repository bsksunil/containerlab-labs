# 3-Node CLOS Topology Validation Commands

## Topology Overview
- **spine1**: 10.0.0.100/32, AS 65100, Router-ID 10.0.0.100
- **leaf1**: 10.0.0.1/32, AS 65001, Router-ID 10.0.0.1
- **leaf2**: 10.0.0.2/32, AS 65002, Router-ID 10.0.0.2
- **client1**: Connected to leaf1 (192.168.1.0/24)
- **client2**: Connected to leaf2 (192.168.2.0/24)
- **Design**: BGP-only CLOS fabric
- **Links**: 
  - spine1:e1-1 ↔ leaf1:e1-1 (10.1.1.1/31 ↔ 10.1.1.0/31)
  - spine1:e1-2 ↔ leaf2:e1-1 (10.1.2.1/31 ↔ 10.1.2.0/31)

---

## Quick Validation Script

Run the automated validation:
```bash
cd /home/selima/containerlab-labs/3-node-topology
./manage-lab.sh validate
```

---

## Manual Validation Commands

### 1. Check Lab Status
```bash
# Check if lab is deployed
containerlab inspect -t clos01.clab.yml

# List all running containers
docker ps | grep clos01
```

### 2. Access Node CLI
```bash
# SSH to spine1
ssh admin@clab-clos01-spine1

# SSH to leaf1
ssh admin@clab-clos01-leaf1

# Or use docker exec
docker exec -it clab-clos01-spine1 sr_cli
docker exec -it clab-clos01-leaf1 sr_cli
```

### 3. Interface Validation

#### Check Interface Status on Spine1
```bash
docker exec clab-clos01-spine1 sr_cli "show interface brief"
docker exec clab-clos01-spine1 sr_cli "show interface ethernet-1/1"
docker exec clab-clos01-spine1 sr_cli "show interface ethernet-1/2"
```

#### Check Interface Status on Leaf1
```bash
docker exec clab-clos01-leaf1 sr_cli "show interface brief"
docker exec clab-clos01-leaf1 sr_cli "show interface ethernet-1/1"
docker exec clab-clos01-leaf1 sr_cli "show interface ethernet-1/2"
```

### 4. BGP Validation

#### BGP Summary on Spine1
```bash
docker exec clab-clos01-spine1 sr_cli "show network-instance default protocols bgp summary"
```

**Expected:** 2 neighbors established (10.1.1.0 and 10.1.2.0)

#### BGP Neighbors on Spine1
```bash
docker exec clab-clos01-spine1 sr_cli "show network-instance default protocols bgp neighbor"
docker exec clab-clos01-spine1 sr_cli "show network-instance default protocols bgp neighbor 10.1.1.0"
docker exec clab-clos01-spine1 sr_cli "show network-instance default protocols bgp neighbor 10.1.2.0"
```

#### BGP on Leaf1
```bash
docker exec clab-clos01-leaf1 sr_cli "show network-instance default protocols bgp summary"
docker exec clab-clos01-leaf1 sr_cli "show network-instance default protocols bgp neighbor"
docker exec clab-clos01-leaf1 sr_cli "show network-instance default protocols bgp neighbor 10.1.1.1"
```

**Expected:** 1 neighbor established (10.1.1.1 - spine1)

#### BGP on Leaf2
```bash
docker exec clab-clos01-leaf2 sr_cli "show network-instance default protocols bgp summary"
docker exec clab-clos01-leaf2 sr_cli "show network-instance default protocols bgp neighbor"
docker exec clab-clos01-leaf2 sr_cli "show network-instance default protocols bgp neighbor 10.1.2.1"
```

**Expected:** 1 neighbor established (10.1.2.1 - spine1)

#### BGP Routes
```bash
# Spine1 routes
docker exec clab-clos01-spine1 sr_cli "show network-instance default protocols bgp routes ipv4"

# Leaf1 routes
docker exec clab-clos01-leaf1 sr_cli "show network-instance default protocols bgp routes ipv4"
```

### 5. Network Connectivity

#### Underlay Connectivity Tests
```bash
# Leaf1 to Spine1
docker exec clab-clos01-leaf1 sr_cli "ping 10.1.1.1 network-instance default"

# Leaf2 to Spine1
docker exec clab-clos01-leaf2 sr_cli "ping 10.1.2.1 network-instance default"

# Leaf1 to Leaf2 via system IPs
docker exec clab-clos01-leaf1 sr_cli "ping 10.0.0.2 network-instance default"
```

#### Client Connectivity Tests
```bash
# Client1 to Leaf1 gateway
docker exec clab-clos01-client1 ping -c 3 192.168.1.1

# Client2 to Leaf2 gateway
docker exec clab-clos01-client2 ping -c 3 192.168.2.1

# Check client1 IP address
docker exec clab-clos01-client1 ip addr show eth1

# Check client2 IP address
docker exec clab-clos01-client2 ip addr show eth1
```

### 6. Routing Table

#### Show Routing Table
```bash
# Spine1 routes
docker exec clab-clos01-spine1 sr_cli "show network-instance default route-table"

# Leaf1 routes
docker exec clab-clos01-leaf1 sr_cli "show network-instance default route-table"

# Leaf2 routes
docker exec clab-clos01-leaf2 sr_cli "show network-instance default route-table"
```

### 7. System Information

#### Show Version
```bash
docker exec clab-clos01-spine1 sr_cli "show version"
docker exec clab-clos01-leaf1 sr_cli "show version"
```

#### Show System Status
```bash
docker exec clab-clos01-spine1 sr_cli "show system information"
docker exec clab-clos01-leaf1 sr_cli "show system information"
```

### 8. Configuration Verification

#### Show Running Configuration
```bash
# Spine1
docker exec clab-clos01-spine1 sr_cli "info"

# Leaf1
docker exec clab-clos01-leaf1 sr_cli "info"
```

#### Show Specific Configuration Sections
```bash
# Show BGP config on spine1
docker exec clab-clos01-spine1 sr_cli "info network-instance default protocols bgp"

# Show interface config on leaf1
docker exec clab-clos01-leaf1 sr_cli "info interface ethernet-1/1"
```

### 9. Troubleshooting Commands

#### Check for Errors
```bash
# Show system alarms
docker exec clab-clos01-spine1 sr_cli "show system alarms"

# Show log messages
docker exec clab-clos01-spine1 sr_cli "show system logging buffer"
```

#### Check Control Plane
```bash
# Show CPU usage
docker exec clab-clos01-spine1 sr_cli "show system cpu"

# Show memory usage
docker exec clab-clos01-spine1 sr_cli "show system memory"
```

---

## Quick Health Check Script

Create a quick health check:
```bash
#!/bin/bash
echo "=== 3-Node CLOS Topology Health Check ==="
echo ""
echo "Lab Status:"
containerlab inspect -t clos01.clab.yml
echo ""
echo "Spine1 BGP Neighbors:"
docker exec clab-clos01-spine1 sr_cli "show network-instance default protocols bgp neighbor" | grep -E "(Peer|State|established)"
echo ""
echo "Leaf1 BGP Neighbors:"
docker exec clab-clos01-leaf1 sr_cli "show network-instance default protocols bgp neighbor" | grep -E "(Peer|State|established)"
echo ""
echo "Underlay Ping Test (Leaf1 → Spine1):"
docker exec clab-clos01-leaf1 sr_cli "ping 10.1.1.1 -c 3 network-instance default" | grep "packets transmitted"
echo ""
echo "Client Connectivity (Client1 → Leaf1):"
docker exec clab-clos01-client1 ping -c 3 192.168.1.1 | grep "packets transmitted"
```

---

## Expected Validation Results

### ✅ Successful Deployment Indicators:
1. **Containers Running**: All 5 containers are healthy (spine1, leaf1, leaf2, client1, client2)
2. **Interfaces UP**: ethernet-1/1 and ethernet-1/2 on spine and leafs are operationally up
3. **BGP Sessions**: 
   - Spine1: 2 sessions established
   - Leaf1: 1 session established
   - Leaf2: 1 session established
4. **Underlay Connectivity**: Ping succeeds between all devices
5. **Client Connectivity**: Clients can reach their gateways
6. **No Alarms**: System shows no critical alarms

### ❌ Common Issues:
- **Containers not running**: Lab not deployed or crashed
- **Interface down**: Configuration issue or link problem
- **BGP in "Idle" or "Active"**: Incorrect AS numbers or IP addressing
- **Ping fails**: Layer 2/3 connectivity issue

---

## One-Liner Validation Commands

```bash
# Quick status check
containerlab inspect -t clos01.clab.yml && \
echo "" && echo "=== SPINE1 BGP ===" && \
docker exec clab-clos01-spine1 sr_cli "show network-instance default protocols bgp neighbor" | grep established && \
echo "" && echo "=== LEAF1 BGP ===" && \
docker exec clab-clos01-leaf1 sr_cli "show network-instance default protocols bgp neighbor" | grep established && \
echo "" && echo "=== CONNECTIVITY ===" && \
docker exec clab-clos01-leaf1 sr_cli "ping 10.1.1.1 -c 3 network-instance default" | grep transmitted
```

---

## Additional Resources

- **SR Linux Documentation**: https://documentation.nokia.com/srlinux/
- **Containerlab Documentation**: https://containerlab.dev/
- **Topology File**: `clos01.clab.yml`
- **Config Files**: `spine1.cfg`, `leaf1.cfg`, `leaf2.cfg`
- **Management Script**: `manage-lab.sh`
- **Terraform Configs**: `terraform/`
