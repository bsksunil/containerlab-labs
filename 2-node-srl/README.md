# 2-Node SR Linux Topology - Complete Documentation

## 📁 Documentation Files Overview

### 🎬 For Demo/Presentation
**→ START HERE: [`DEMO_READY.md`](DEMO_READY.md)**
- Quick validation steps (5-6 min demo flow)
- One-command status check
- Expected results with checkmarks
- Troubleshooting tips
- **Perfect for live demonstrations**

### ⚡ For Quick Reference
**[`QUICK_COMMANDS.md`](QUICK_COMMANDS.md)**
- Essential commands only
- Copy-paste ready
- No-password docker exec commands
- SSH interactive commands
- **Use this for daily operations**

### 📚 For Detailed Validation
**[`VALIDATION_COMMANDS.md`](VALIDATION_COMMANDS.md)**
- Comprehensive command list
- All validation scenarios
- Detailed explanations
- Troubleshooting guide
- **Use this for thorough testing**

---

## 🚀 Quick Start

### 1. Deploy Lab (via Terraform)
```bash
cd terraform
terraform apply
```

### 2. Validate Lab
```bash
./terraform/validate_connectivity.sh .
```

### 3. Quick Status Check
```bash
sudo containerlab inspect -t srl02-simple.clab.yml
```

---

## 🏗️ Lab Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    2-Node SR Linux Lab                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   ┌──────────────┐              ┌──────────────┐          │
│   │    srl1      │  ethernet-1/1 │    srl2      │          │
│   │ 10.0.0.1/30  │◄─────────────►│ 10.0.0.2/30  │          │
│   │ AS 65001     │               │ AS 65002     │          │
│   │ RID 1.1.1.1  │               │ RID 2.2.2.2  │          │
│   └──────────────┘               └──────────────┘          │
│                                                             │
│   Protocols: OSPF Area 0.0.0.0 + eBGP                      │
│   Management: 172.20.20.0/24 (Docker network)              │
└─────────────────────────────────────────────────────────────┘
```

---

## 📦 Files in This Directory

### Configuration Files
- `srl02-simple.clab.yml` - Containerlab topology definition
- `srl1.cfg` - SR Linux configuration for srl1
- `srl2.cfg` - SR Linux configuration for srl2

### Documentation
- `README.md` - This file (overview)
- `DEMO_READY.md` - Demo/presentation guide ⭐
- `QUICK_COMMANDS.md` - Quick reference
- `VALIDATION_COMMANDS.md` - Detailed validation

### Terraform Directory
- `terraform/main.tf` - Terraform configuration
- `terraform/deploy_containerlab.sh` - Deployment script
- `terraform/destroy_containerlab.sh` - Cleanup script
- `terraform/validate_connectivity.sh` - Validation script
- `terraform/README.md` - Terraform documentation

---

## ✅ Lab Status Indicators

When validating, look for these success indicators:

| Component | Success Indicator |
|-----------|-------------------|
| Containers | State: **running** |
| Interface | Oper State: **up** |
| OSPF | Neighbor State: **full** |
| BGP | Session State: **established** |
| Connectivity | Packet Loss: **0%** |

---

## 🎯 Use Cases

### For Learning
- Understand OSPF neighbor relationships
- Explore eBGP peering between different ASes
- Practice SR Linux CLI commands
- Learn containerlab deployment

### For Testing
- Validate network protocols
- Test routing configurations
- Experiment with network changes
- Debug connectivity issues

### For Demos
- Show automated network deployment
- Demonstrate Infrastructure as Code (Terraform)
- Present containerized network labs
- Explain routing protocols

---

## 🔧 Common Operations

### Check Lab Status
```bash
sudo containerlab inspect -t srl02-simple.clab.yml
```

### Access Node CLI
```bash
# Method 1: Docker exec (no password)
docker exec -it clab-srl02-simple-srl1 sr_cli

# Method 2: SSH (password: NokiaSrl1!)
ssh admin@clab-srl02-simple-srl1
```

### Run Commands Remotely
```bash
docker exec clab-srl02-simple-srl1 sr_cli "show interface brief"
```

### Deploy Lab
```bash
# Via Terraform (recommended)
cd terraform && terraform apply

# Or directly with containerlab
sudo containerlab deploy -t srl02-simple.clab.yml
```

### Destroy Lab
```bash
# Via Terraform (recommended)
cd terraform && terraform destroy

# Or directly with containerlab
sudo containerlab destroy -t srl02-simple.clab.yml
```

---

## 📊 Quick Validation (30 seconds)

```bash
# All-in-one status check
echo "=== LAB STATUS ===" && \
sudo containerlab inspect -t srl02-simple.clab.yml && \
echo "" && echo "=== OSPF ===" && \
docker exec clab-srl02-simple-srl1 sr_cli "show network-instance default protocols ospf neighbor" | grep full && \
echo "" && echo "=== BGP ===" && \
docker exec clab-srl02-simple-srl1 sr_cli "show network-instance default protocols bgp neighbor" | grep established && \
echo "" && echo "=== CONNECTIVITY ===" && \
docker exec clab-srl02-simple-srl1 sr_cli "ping 10.0.0.2 -c 3 network-instance default" | grep transmitted
```

---

## 🎓 Learning Resources

- **SR Linux Documentation**: https://documentation.nokia.com/srlinux/
- **Containerlab Documentation**: https://containerlab.dev/
- **SR Linux Learn**: https://learn.srlinux.dev/
- **OSPF Basics**: RFC 2328
- **BGP Basics**: RFC 4271

---

## 🆘 Troubleshooting

### Lab Won't Deploy
1. Check Docker is running: `docker ps`
2. Check containerlab version: `containerlab version`
3. Check disk space: `df -h`

### OSPF Not Forming
1. Check interface is up: `show interface ethernet-1/1`
2. Check OSPF config: `info network-instance default protocols ospf`
3. Check OSPF interface: `show network-instance default protocols ospf interface`

### BGP Not Establishing
1. Check IP connectivity: `ping 10.0.0.2 network-instance default`
2. Check BGP config: `info network-instance default protocols bgp`
3. Check for errors: `show system logging buffer | grep bgp`

### Ping Fails
1. Check interface status: `show interface brief`
2. Check routing table: `show network-instance default route-table`
3. Check ARP: `show arp`

---

## 📞 Support

For issues or questions:
1. Check the documentation files in this directory
2. Review containerlab documentation
3. Check SR Linux documentation
4. Review the topology and config files

---

## 🎉 Summary

You have **3 documentation files** ready for your demo:

1. **DEMO_READY.md** → For presentations and live demos
2. **QUICK_COMMANDS.md** → For daily operations
3. **VALIDATION_COMMANDS.md** → For detailed testing

All commands have been **tested and verified** working! ✅

**Your lab is 100% ready for demo!** 🚀
