# 2-Node SR Linux Lab - Demo Ready Guide ✅

**Last Validated**: October 15, 2025  
**Status**: All systems operational ✓

---

## 📋 Lab Overview

### Topology Details
```
srl1 (10.0.0.1/30) ←--ethernet-1/1--→ srl2 (10.0.0.2/30)
  AS 65001                                AS 65002
  RID: 1.1.1.1                            RID: 2.2.2.2
  
Protocols: OSPF Area 0.0.0.0 + eBGP
```

### Container Information
- **srl1**: `clab-srl02-simple-srl1` (172.20.20.2)
- **srl2**: `clab-srl02-simple-srl2` (172.20.20.3)

---

## 🚀 Demo Flow - Quick Start

### Step 1: Verify Lab Status
```bash
sudo containerlab inspect -t srl02-simple.clab.yml
```
**Expected**: Both nodes showing **"running"** state

---

### Step 2: Check Interface Status
```bash
docker exec clab-srl02-simple-srl1 sr_cli "show interface ethernet-1/1 brief"
```
**Expected**: 
- Admin State: **enable**
- Oper State: **up**
- Speed: **25G**

---

### Step 3: Verify OSPF Neighbor
```bash
docker exec clab-srl02-simple-srl1 sr_cli "show network-instance default protocols ospf neighbor"
```
**Expected**: 
- Neighbor: **2.2.2.2**
- State: **full** ✅
- Interface: **ethernet-1/1.0**

---

### Step 4: Verify BGP Session
```bash
docker exec clab-srl02-simple-srl1 sr_cli "show network-instance default protocols bgp neighbor"
```
**Expected**:
- Peer: **10.0.0.2**
- Peer-AS: **65002**
- State: **established** ✅
- Uptime: Shows active time

---

### Step 5: Test Connectivity
```bash
docker exec clab-srl02-simple-srl1 sr_cli "ping 10.0.0.2 -c 5 network-instance default"
```
**Expected**: 
- **0% packet loss** ✅
- RTT: ~3ms

---

## 🎯 One-Command Full Validation

Run all checks in one command:
```bash
echo "=== 2-NODE LAB VALIDATION ===" && \
echo "" && echo "1. Lab Status:" && \
sudo containerlab inspect -t srl02-simple.clab.yml && \
echo "" && echo "2. Interface Status:" && \
docker exec clab-srl02-simple-srl1 sr_cli "show interface ethernet-1/1 brief" && \
echo "" && echo "3. OSPF Neighbor:" && \
docker exec clab-srl02-simple-srl1 sr_cli "show network-instance default protocols ospf neighbor" && \
echo "" && echo "4. BGP Neighbor:" && \
docker exec clab-srl02-simple-srl1 sr_cli "show network-instance default protocols bgp neighbor" && \
echo "" && echo "5. Connectivity Test:" && \
docker exec clab-srl02-simple-srl1 sr_cli "ping 10.0.0.2 -c 3 network-instance default"
```

---

## 🔧 Automated Validation Script

Use the pre-built validation script:
```bash
cd /home/selima/containerlab-labs/2-node-srl/terraform
./validate_connectivity.sh /home/selima/containerlab-labs/2-node-srl
```

---

## 🖥️ Interactive SSH Demo

### Access srl1 Interactively
```bash
ssh admin@clab-srl02-simple-srl1
# Password: NokiaSrl1!
```

### Commands to run inside srl1:
```bash
# View all interfaces
show interface brief

# Check OSPF
show network-instance default protocols ospf neighbor
show network-instance default protocols ospf interface

# Check BGP
show network-instance default protocols bgp neighbor
show network-instance default protocols bgp summary

# View routing table
show network-instance default route-table

# Ping srl2
ping 10.0.0.2 network-instance default

# Show configuration
info

# Exit
exit
```

---

## ✅ Expected Results Summary

| Check | Expected Result | Status |
|-------|----------------|--------|
| **Containers** | Both running | ✅ |
| **Interface e1-1** | Admin: enable, Oper: up | ✅ |
| **OSPF Neighbor** | State: full, Router-ID: 2.2.2.2 | ✅ |
| **BGP Session** | State: established, Peer: 10.0.0.2 | ✅ |
| **Connectivity** | 0% packet loss, ~3ms RTT | ✅ |

---

## 📚 Additional Documentation

- **Detailed Validation**: `VALIDATION_COMMANDS.md`
- **Quick Reference**: `QUICK_COMMANDS.md`
- **Topology File**: `srl02-simple.clab.yml`
- **Node Configs**: `srl1.cfg`, `srl2.cfg`

---

## 🎬 Demo Script Suggestion

### For Live Demo:

1. **Show Topology File** (30 sec)
   ```bash
   cat srl02-simple.clab.yml
   ```

2. **Check Lab Status** (30 sec)
   ```bash
   sudo containerlab inspect -t srl02-simple.clab.yml
   ```

3. **Verify OSPF** (1 min)
   ```bash
   docker exec clab-srl02-simple-srl1 sr_cli "show network-instance default protocols ospf neighbor"
   ```
   - Point out the **"full"** state
   - Explain neighbor relationship

4. **Verify BGP** (1 min)
   ```bash
   docker exec clab-srl02-simple-srl1 sr_cli "show network-instance default protocols bgp neighbor"
   ```
   - Point out the **"established"** state
   - Highlight AS numbers (65001 ↔ 65002)

5. **Live Ping Test** (1 min)
   ```bash
   docker exec clab-srl02-simple-srl1 sr_cli "ping 10.0.0.2 -c 5 network-instance default"
   ```
   - Show 0% packet loss

6. **Optional: SSH into Node** (2 min)
   ```bash
   ssh admin@clab-srl02-simple-srl1
   show interface brief
   show network-instance default route-table
   exit
   ```

**Total Demo Time**: 5-6 minutes

---

## 🛠️ Troubleshooting (Just in Case)

### If Lab is Not Running
```bash
cd /home/selima/containerlab-labs/2-node-srl/terraform
terraform apply
```

### If OSPF Not Full
```bash
# Check interface is up
docker exec clab-srl02-simple-srl1 sr_cli "show interface ethernet-1/1"

# Check OSPF interface
docker exec clab-srl02-simple-srl1 sr_cli "show network-instance default protocols ospf interface"
```

### If BGP Not Established
```bash
# Check BGP configuration
docker exec clab-srl02-simple-srl1 sr_cli "info network-instance default protocols bgp"

# Check logs
docker exec clab-srl02-simple-srl1 sr_cli "show system logging buffer" | grep -i bgp
```

---

## 📊 Quick Status Check (30 seconds)

Copy-paste this for instant status:
```bash
clear && \
echo "╔════════════════════════════════════════════╗" && \
echo "║   2-NODE SR LINUX LAB - STATUS CHECK      ║" && \
echo "╚════════════════════════════════════════════╝" && \
echo "" && \
echo "📦 Containers:" && \
docker ps --filter "name=srl02-simple" --format "table {{.Names}}\t{{.Status}}" && \
echo "" && \
echo "🔗 OSPF Status:" && \
docker exec clab-srl02-simple-srl1 sr_cli "show network-instance default protocols ospf neighbor" | grep -E "(ethernet|full)" && \
echo "" && \
echo "🌐 BGP Status:" && \
docker exec clab-srl02-simple-srl1 sr_cli "show network-instance default protocols bgp neighbor" | grep -E "(10.0.0.2|established)" && \
echo "" && \
echo "📡 Connectivity:" && \
docker exec clab-srl02-simple-srl1 sr_cli "ping 10.0.0.2 -c 3 network-instance default" | grep "transmitted" && \
echo "" && \
echo "✅ Lab is READY for Demo!"
```

---

## 🔗 Resources

- **SR Linux Docs**: https://documentation.nokia.com/srlinux/
- **Containerlab Docs**: https://containerlab.dev/
- **GitHub Copilot**: For questions during demo

---

**Good luck with your demo! 🚀**

All validation commands have been tested and verified working.
