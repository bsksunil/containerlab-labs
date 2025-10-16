# 3-Node CLOS Topology - Complete Documentation

## 📁 Documentation Files Overview

### 🎬 For Demo/Presentation
**→ START HERE: [`DEMO_CHEAT_SHEET.md`](DEMO_CHEAT_SHEET.md)**
- Quick validation steps (5-8 min demo flow)
- One-command status check
- Expected results with checkmarks
- **Perfect for live demonstrations**

### 📚 For Detailed Validation
**[`VALIDATION_COMMANDS.md`](VALIDATION_COMMANDS.md)**
- Comprehensive command list
- All validation scenarios
- Detailed explanations
- Troubleshooting guide

---

## 🏗️ Lab Architecture

```
                  ┌────────────┐
                  │   spine1   │
                  │ AS 65100   │
                  │ 10.0.0.100 │
                  └─────┬──┬───┘
              10.1.1.1/31│  │10.1.2.1/31
        ┌────────────────┘  └────────────────┐
        │                                    │
  ┌─────┴─────┐                        ┌─────┴─────┐
  │   leaf1   │                        │   leaf2   │
  │ AS 65001  │                        │ AS 65002  │
  │ 10.0.0.1  │                        │ 10.0.0.2  │
  └─────┬─────┘                        └─────┬─────┘
192.168.1.1/24                    192.168.2.1/24
        │                                    │
  ┌─────┴─────┐                        ┌─────┴─────┐
  │  client1  │                        │  client2  │
  └───────────┘                        └───────────┘
```

### Network Details
- **Design**: BGP-only CLOS fabric (typical datacenter)
- **Underlay**: /31 point-to-point links
- **ASNs**: Spine=65100, Leaf1=65001, Leaf2=65002
- **Client Networks**: 192.168.1.0/24, 192.168.2.0/24

---

## 🚀 Quick Start

### 1. Deploy Lab (via Terraform)
```bash
cd terraform
terraform apply
```

### 2. Validate Lab
```bash
containerlab inspect -t clos01.clab.yml
```

### 3. Quick Validation
```bash
./manage-lab.sh validate
```

---

## 📦 Files in This Directory

### Configuration Files
- `clos01.clab.yml` - Containerlab topology definition
- `spine1.cfg` - SR Linux configuration for spine1
- `leaf1.cfg` - SR Linux configuration for leaf1
- `leaf2.cfg` - SR Linux configuration for leaf2

### Scripts
- `manage-lab.sh` - Lab management script (deploy, destroy, validate)

### Documentation
- `README.md` - This file (overview)
- `DEMO_CHEAT_SHEET.md` - Demo/presentation guide ⭐
- `VALIDATION_COMMANDS.md` - Detailed validation

### Terraform Directory
- `terraform/main.tf` - Terraform configuration
- `terraform/README.md` - Terraform documentation

---

## ✅ Lab Status Indicators

When validating, look for these success indicators:

| Component | Success Indicator |
|-----------|-------------------|
| Containers | 5 **running** (spine1, leaf1, leaf2, client1, client2) |
| Spine1 BGP | 2 sessions **established** |
| Leaf1 BGP | 1 session **established** |
| Leaf2 BGP | 1 session **established** |
| Underlay Ping | **0% packet loss** |
| Client Ping | **0% packet loss** |

---

## 🎯 Use Cases

### For Learning
- Understand CLOS/Leaf-Spine architecture
- Explore BGP-only datacenter design
- Practice SR Linux CLI commands
- Learn multi-tier network deployment

### For Testing
- Validate BGP configurations
- Test underlay connectivity
- Experiment with routing policies
- Debug multi-node topologies

### For Demos
- Show datacenter network automation
- Demonstrate Infrastructure as Code
- Present modern datacenter architecture
- Explain BGP in the datacenter

---

## 🔧 Common Operations

### Check Lab Status
```bash
containerlab inspect -t clos01.clab.yml
```

### Access Node CLI
```bash
# Method 1: Docker exec (no password)
docker exec -it clab-clos01-spine1 sr_cli

# Method 2: SSH (password: NokiaSrl1!)
ssh admin@clab-clos01-spine1
```

### Run Commands Remotely
```bash
docker exec clab-clos01-spine1 sr_cli "show interface brief"
docker exec clab-clos01-spine1 sr_cli "show network-instance default protocols bgp neighbor"
```

### Deploy Lab
```bash
# Via Terraform (recommended)
cd terraform && terraform apply

# Or directly with containerlab
containerlab deploy -t clos01.clab.yml

# Or using the management script
./manage-lab.sh deploy
```

### Destroy Lab
```bash
# Via Terraform (recommended)
cd terraform && terraform destroy

# Or directly with containerlab
containerlab destroy -t clos01.clab.yml

# Or using the management script
./manage-lab.sh destroy
```

---

## 📊 Quick Validation (30 seconds)

```bash
# All-in-one status check
containerlab inspect -t clos01.clab.yml && \
echo "" && echo "=== SPINE1 BGP ===" && \
docker exec clab-clos01-spine1 sr_cli "show network-instance default protocols bgp neighbor" | grep established && \
echo "" && echo "=== UNDERLAY PING ===" && \
docker exec clab-clos01-leaf1 sr_cli "ping 10.1.1.1 -c 3 network-instance default" | grep transmitted
```

---

## 🎓 Learning Resources

- **SR Linux Documentation**: https://documentation.nokia.com/srlinux/
- **Containerlab Documentation**: https://containerlab.dev/
- **SR Linux Learn**: https://learn.srlinux.dev/
- **BGP in Datacenter**: RFC 7938
- **CLOS Networks**: Understanding Leaf-Spine Architecture

---

## 🆘 Troubleshooting

### Lab Won't Deploy
1. Check Docker is running: `docker ps`
2. Check containerlab version: `containerlab version`
3. Check disk space: `df -h`

### BGP Not Establishing
1. Check IP connectivity: `ping` tests
2. Check BGP config: `info network-instance default protocols bgp`
3. Check for errors: `show system logging buffer | grep bgp`

### Client Can't Ping Gateway
1. Check client IP: `docker exec clab-clos01-client1 ip addr`
2. Check leaf interface: `show interface ethernet-1/2`
3. Check routing: `show network-instance default route-table`

---

## 📞 Support

For issues or questions:
1. Check the documentation files in this directory
2. Review containerlab documentation
3. Check SR Linux documentation
4. Review the topology and config files

---

## 🎉 Summary

You have **2 documentation files** ready for your demo:

1. **DEMO_CHEAT_SHEET.md** → For presentations and live demos ⭐
2. **VALIDATION_COMMANDS.md** → For detailed testing

**Key Differences from 2-Node Lab:**
- 5 containers vs 2
- CLOS architecture vs point-to-point
- BGP only (no OSPF)
- Client hosts for end-to-end testing
- Multi-tier design

**Your 3-node CLOS lab is ready for demo!** 🚀
