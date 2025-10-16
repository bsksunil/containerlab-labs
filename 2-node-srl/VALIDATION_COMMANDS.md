# 2-Node SR Linux Topology Validation Commands

## Topology Overview
- **srl1**: 10.0.0.1/30, AS 65001, Router-ID 1.1.1.1
- **srl2**: 10.0.0.2/30, AS 65002, Router-ID 2.2.2.2
- **Link**: srl1:e1-1 ↔ srl2:e1-1
- **Protocols**: OSPF (Area 0.0.0.0), eBGP

---

## Quick Validation Script

Run the automated validation script:
```bash
cd /home/selima/containerlab-labs/2-node-srl/terraform
./validate_connectivity.sh /home/selima/containerlab-labs/2-node-srl
```

---

## Manual Validation Commands

### 1. Check Lab Status
```bash
# Check if lab is deployed
sudo containerlab inspect -t srl02-simple.clab.yml

# List all running containers
docker ps | grep srl02-simple
```

### 2. Access Node CLI
```bash
# SSH to srl1
ssh admin@clab-srl02-simple-srl1

# SSH to srl2
ssh admin@clab-srl02-simple-srl2

# Or use docker exec
docker exec -it clab-srl02-simple-srl1 sr_cli
docker exec -it clab-srl02-simple-srl2 sr_cli
```

### 3. Interface Validation

#### Check Interface Status
```bash
# On srl1
docker exec clab-srl02-simple-srl1 sr_cli "show interface ethernet-1/1"
docker exec clab-srl02-simple-srl1 sr_cli "show interface ethernet-1/1 brief"

# On srl2
docker exec clab-srl02-simple-srl2 sr_cli "show interface ethernet-1/1"
docker exec clab-srl02-simple-srl2 sr_cli "show interface ethernet-1/1 brief"
```

#### Check IP Addresses
```bash
# On srl1
docker exec clab-srl02-simple-srl1 sr_cli "show interface ethernet-1/1 subinterface 0"

# On srl2
docker exec clab-srl02-simple-srl2 sr_cli "show interface ethernet-1/1 subinterface 0"
```

#### Check Interface Statistics
```bash
# On srl1
docker exec clab-srl02-simple-srl1 sr_cli "show interface ethernet-1/1 statistics"

# On srl2
docker exec clab-srl02-simple-srl2 sr_cli "show interface ethernet-1/1 statistics"
```

### 4. Network Connectivity

#### Ping Tests
```bash
# Ping from srl1 to srl2
docker exec clab-srl02-simple-srl1 sr_cli "ping 10.0.0.2 network-instance default"

# Ping from srl2 to srl1
docker exec clab-srl02-simple-srl2 sr_cli "ping 10.0.0.1 network-instance default"
```

#### ARP/Neighbor Discovery
```bash
# Check ARP cache on srl1
docker exec clab-srl02-simple-srl1 sr_cli "show arp"

# Check ARP cache on srl2
docker exec clab-srl02-simple-srl2 sr_cli "show arp"
```

### 5. OSPF Validation

#### OSPF Neighbor Status
```bash
# On srl1
docker exec clab-srl02-simple-srl1 sr_cli "show network-instance default protocols ospf neighbor"

# On srl2
docker exec clab-srl02-simple-srl2 sr_cli "show network-instance default protocols ospf neighbor"
```

#### OSPF Interface Status
```bash
# On srl1
docker exec clab-srl02-simple-srl1 sr_cli "show network-instance default protocols ospf interface"

# On srl2
docker exec clab-srl02-simple-srl2 sr_cli "show network-instance default protocols ospf interface"
```

#### OSPF Database
```bash
# On srl1
docker exec clab-srl02-simple-srl1 sr_cli "show network-instance default protocols ospf database"

# On srl2
docker exec clab-srl02-simple-srl2 sr_cli "show network-instance default protocols ospf database"
```

#### Expected OSPF Output:
- Neighbor state should be **Full**
- Interface state should be **Point-to-Point**
- Router-IDs: 1.1.1.1 (srl1) and 2.2.2.2 (srl2)

### 6. BGP Validation

#### BGP Summary
```bash
# On srl1
docker exec clab-srl02-simple-srl1 sr_cli "show network-instance default protocols bgp summary"

# On srl2
docker exec clab-srl02-simple-srl2 sr_cli "show network-instance default protocols bgp summary"
```

#### BGP Neighbor Status
```bash
# On srl1 (check neighbor 10.0.0.2)
docker exec clab-srl02-simple-srl1 sr_cli "show network-instance default protocols bgp neighbor"
docker exec clab-srl02-simple-srl1 sr_cli "show network-instance default protocols bgp neighbor 10.0.0.2"

# On srl2 (check neighbor 10.0.0.1)
docker exec clab-srl02-simple-srl2 sr_cli "show network-instance default protocols bgp neighbor"
docker exec clab-srl02-simple-srl2 sr_cli "show network-instance default protocols bgp neighbor 10.0.0.1"
```

#### BGP Routes
```bash
# On srl1
docker exec clab-srl02-simple-srl1 sr_cli "show network-instance default protocols bgp routes ipv4"

# On srl2
docker exec clab-srl02-simple-srl2 sr_cli "show network-instance default protocols bgp routes ipv4"
```

#### Expected BGP Output:
- Session state should be **Established**
- Peer ASNs: srl1 (AS 65001) ↔ srl2 (AS 65002)
- Router-IDs: 1.1.1.1 (srl1) and 2.2.2.2 (srl2)

### 7. Routing Table

#### Show Routing Table
```bash
# On srl1
docker exec clab-srl02-simple-srl1 sr_cli "show network-instance default route-table"

# On srl2
docker exec clab-srl02-simple-srl2 sr_cli "show network-instance default route-table"
```

#### Show Specific Routes
```bash
# On srl1
docker exec clab-srl02-simple-srl1 sr_cli "show network-instance default route-table ipv4-unicast summary"

# On srl2
docker exec clab-srl02-simple-srl2 sr_cli "show network-instance default route-table ipv4-unicast summary"
```

### 8. System Information

#### Show Version
```bash
# On srl1
docker exec clab-srl02-simple-srl1 sr_cli "show version"

# On srl2
docker exec clab-srl02-simple-srl2 sr_cli "show version"
```

#### Show System Status
```bash
# On srl1
docker exec clab-srl02-simple-srl1 sr_cli "show system information"

# On srl2
docker exec clab-srl02-simple-srl2 sr_cli "show system information"
```

### 9. Configuration Verification

#### Show Running Configuration
```bash
# On srl1
docker exec clab-srl02-simple-srl1 sr_cli "info"

# On srl2
docker exec clab-srl02-simple-srl2 sr_cli "info"
```

#### Show Specific Configuration Sections
```bash
# Show interface config
docker exec clab-srl02-simple-srl1 sr_cli "info interface ethernet-1/1"

# Show network-instance config
docker exec clab-srl02-simple-srl1 sr_cli "info network-instance default"

# Show OSPF config
docker exec clab-srl02-simple-srl1 sr_cli "info network-instance default protocols ospf"

# Show BGP config
docker exec clab-srl02-simple-srl1 sr_cli "info network-instance default protocols bgp"
```

### 10. Troubleshooting Commands

#### Check for Errors
```bash
# Show system alarms
docker exec clab-srl02-simple-srl1 sr_cli "show system alarms"

# Show log messages
docker exec clab-srl02-simple-srl1 sr_cli "show system logging buffer"
```

#### Check Control Plane
```bash
# Show CPU usage
docker exec clab-srl02-simple-srl1 sr_cli "show system cpu"

# Show memory usage
docker exec clab-srl02-simple-srl1 sr_cli "show system memory"
```

#### Clear Counters
```bash
# Clear interface statistics
docker exec clab-srl02-simple-srl1 sr_cli "clear interface ethernet-1/1 statistics"
```

---

## Quick Health Check Script

Create a quick health check:
```bash
#!/bin/bash
echo "=== 2-Node Topology Health Check ==="
echo ""
echo "Lab Status:"
sudo containerlab inspect -t srl02-simple.clab.yml
echo ""
echo "OSPF Neighbors on srl1:"
docker exec clab-srl02-simple-srl1 sr_cli "show network-instance default protocols ospf neighbor" | grep -E "(Neighbor|State)"
echo ""
echo "BGP Neighbors on srl1:"
docker exec clab-srl02-simple-srl1 sr_cli "show network-instance default protocols bgp neighbor" | grep -E "(10.0.0|State|established)"
echo ""
echo "Ping Test (srl1 → srl2):"
docker exec clab-srl02-simple-srl1 sr_cli "ping 10.0.0.2 -c 3 network-instance default" | grep "packets transmitted"
```

---

## Expected Validation Results

### ✅ Successful Deployment Indicators:
1. **Containers Running**: Both srl1 and srl2 containers are healthy
2. **Interfaces UP**: ethernet-1/1 on both nodes is operationally up
3. **IP Connectivity**: Ping succeeds between 10.0.0.1 and 10.0.0.2
4. **OSPF**: Neighbor state is "Full"
5. **BGP**: Session state is "Established"
6. **No Alarms**: System shows no critical alarms

### ❌ Common Issues:
- **Containers not running**: Lab not deployed or crashed
- **Interface down**: Configuration issue or link problem
- **OSPF stuck in "Init" or "ExStart"**: MTU mismatch or authentication issue
- **BGP in "Idle" or "Active"**: Incorrect AS numbers or IP addressing
- **Ping fails**: Layer 2/3 connectivity issue

---

## One-Liner Validation Commands

```bash
# Quick status check
sudo containerlab inspect -t srl02-simple.clab.yml && \
docker exec clab-srl02-simple-srl1 sr_cli "show interface ethernet-1/1 brief" && \
docker exec clab-srl02-simple-srl1 sr_cli "show network-instance default protocols ospf neighbor" && \
docker exec clab-srl02-simple-srl1 sr_cli "show network-instance default protocols bgp neighbor" && \
docker exec clab-srl02-simple-srl1 sr_cli "ping 10.0.0.2 -c 3 network-instance default"
```

---

## Additional Resources

- **SR Linux Documentation**: https://documentation.nokia.com/srlinux/
- **Containerlab Documentation**: https://containerlab.dev/
- **Topology File**: `srl02-simple.clab.yml`
- **Config Files**: `srl1.cfg`, `srl2.cfg`
- **Automated Validation**: `terraform/validate_connectivity.sh`
