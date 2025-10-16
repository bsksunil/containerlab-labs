# Quick Command Reference - 2-Node Lab

## 🚀 Quick Access Methods

### Method 1: Docker Exec (Recommended for scripting)
```bash
# Run commands without SSH
docker exec clab-srl02-simple-srl1 sr_cli "show interface brief"
docker exec clab-srl02-simple-srl1 sr_cli "show network-instance default protocols ospf neighbor"
```

### Method 2: Interactive SSH
```bash
# SSH into the node (password: NokiaSrl1!)
ssh admin@clab-srl02-simple-srl1

# Once inside, run commands:
show interface brief
show network-instance default protocols ospf neighbor
show network-instance default protocols bgp neighbor
exit
```

---

## ✅ Essential Validation Commands

### 1. Check Lab Status (from host)
```bash
sudo containerlab inspect -t srl02-simple.clab.yml
```

### 2. Quick Health Check (from host)
```bash
# All-in-one validation
docker exec clab-srl02-simple-srl1 sr_cli "show interface ethernet-1/1 brief" && \
docker exec clab-srl02-simple-srl1 sr_cli "show network-instance default protocols ospf neighbor" && \
docker exec clab-srl02-simple-srl1 sr_cli "show network-instance default protocols bgp neighbor" && \
docker exec clab-srl02-simple-srl1 sr_cli "ping 10.0.0.2 -c 3 network-instance default"
```

### 3. Interface Status
```bash
# On srl1
docker exec clab-srl02-simple-srl1 sr_cli "show interface ethernet-1/1 brief"

# On srl2
docker exec clab-srl02-simple-srl2 sr_cli "show interface ethernet-1/1 brief"
```

### 4. OSPF Validation
```bash
# Check OSPF neighbors on srl1
docker exec clab-srl02-simple-srl1 sr_cli "show network-instance default protocols ospf neighbor"

# Check OSPF neighbors on srl2
docker exec clab-srl02-simple-srl2 sr_cli "show network-instance default protocols ospf neighbor"

# Expected: State should be "full"
```

### 5. BGP Validation
```bash
# Check BGP neighbors on srl1
docker exec clab-srl02-simple-srl1 sr_cli "show network-instance default protocols bgp neighbor"

# Check BGP summary on srl1
docker exec clab-srl02-simple-srl1 sr_cli "show network-instance default protocols bgp summary"

# Expected: State should be "established"
```

### 6. Connectivity Test
```bash
# Ping from srl1 to srl2
docker exec clab-srl02-simple-srl1 sr_cli "ping 10.0.0.2 -c 5 network-instance default"

# Ping from srl2 to srl1
docker exec clab-srl02-simple-srl2 sr_cli "ping 10.0.0.1 -c 5 network-instance default"

# Expected: 0% packet loss
```

### 7. Routing Table
```bash
# View routing table on srl1
docker exec clab-srl02-simple-srl1 sr_cli "show network-instance default route-table"

# View routing table on srl2
docker exec clab-srl02-simple-srl2 sr_cli "show network-instance default route-table"
```

### 8. System Information
```bash
# Show version
docker exec clab-srl02-simple-srl1 sr_cli "show version"

# Show system info
docker exec clab-srl02-simple-srl1 sr_cli "show system information"
```

---

## 🔧 Lab Management Commands

### Deploy Lab
```bash
# From terraform directory
cd /home/selima/containerlab-labs/2-node-srl/terraform
terraform apply

# Or manually
cd /home/selima/containerlab-labs/2-node-srl
sudo containerlab deploy -t srl02-simple.clab.yml
```

### Destroy Lab
```bash
# From terraform directory
cd /home/selima/containerlab-labs/2-node-srl/terraform
terraform destroy

# Or manually
cd /home/selima/containerlab-labs/2-node-srl
sudo containerlab destroy -t srl02-simple.clab.yml
```

### Validate Lab
```bash
# Run automated validation
cd /home/selima/containerlab-labs/2-node-srl/terraform
./validate_connectivity.sh /home/selima/containerlab-labs/2-node-srl
```

---

## 🎯 Common Use Cases

### Check if everything is working
```bash
# One command to check all
docker exec clab-srl02-simple-srl1 sr_cli "show interface brief" && \
echo "---OSPF---" && \
docker exec clab-srl02-simple-srl1 sr_cli "show network-instance default protocols ospf neighbor" && \
echo "---BGP---" && \
docker exec clab-srl02-simple-srl1 sr_cli "show network-instance default protocols bgp neighbor"
```

### Monitor connectivity continuously
```bash
# Continuous ping (Ctrl+C to stop)
docker exec clab-srl02-simple-srl1 sr_cli "ping 10.0.0.2 network-instance default"
```

### View logs
```bash
# Docker logs
docker logs clab-srl02-simple-srl1

# System logs inside the node
docker exec clab-srl02-simple-srl1 sr_cli "show system logging buffer"
```

### Check for errors
```bash
# System alarms
docker exec clab-srl02-simple-srl1 sr_cli "show system alarms"

# Interface errors
docker exec clab-srl02-simple-srl1 sr_cli "show interface ethernet-1/1 statistics"
```

---

## 📊 Expected Output Examples

### ✅ OSPF Neighbor (Good)
```
| ethernet-1/1.0  | 2.2.2.2  | full  | 1  | 0  | 34  |
```

### ✅ BGP Neighbor (Good)
```
| default  | 10.0.0.2  | ebgp  | S  | 65002  | established  | 0d:0h:5m:6s  |
```

### ✅ Ping (Good)
```
5 packets transmitted, 5 received, 0% packet loss
```

---

## 💡 Tips

1. **Use docker exec for automation** - No password needed, easier for scripts
2. **Use SSH for interactive sessions** - Better for exploring and learning
3. **Default password**: `NokiaSrl1!` (if prompted)
4. **Tab completion**: Works in the SR Linux CLI for commands
5. **Context-sensitive help**: Type `?` at any point in the CLI
6. **Exit SSH**: Type `exit` or press `Ctrl+D`

---

## 🔗 Useful Links

- Full validation guide: `VALIDATION_COMMANDS.md`
- Terraform configs: `terraform/`
- Node configs: `srl1.cfg`, `srl2.cfg`
- Topology file: `srl02-simple.clab.yml`
