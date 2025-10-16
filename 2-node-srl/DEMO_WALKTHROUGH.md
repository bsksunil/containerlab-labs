# 🎬 Live Demo Walkthrough - 2-Node SR Linux Lab

**Duration**: 5-7 minutes  
**Audience**: Technical demo or presentation

---

## 🚀 STEP 1: Deploy the Lab (1-2 min)

### Start from terraform directory:
```bash
cd /home/selima/containerlab-labs/2-node-srl/terraform
terraform apply
# Type 'yes' when prompted
```

**What happens:**
- ✅ Containerlab deploys srl1 and srl2
- ✅ Configurations are applied
- ✅ Automatic validation runs
- ✅ Shows initial status

**While it's running, explain:**
- "We're using Terraform to deploy a containerized network lab"
- "This creates two Nokia SR Linux routers with OSPF and BGP"
- "The deployment includes automatic validation"

---

## ✅ STEP 2: Verify Deployment (30 sec)

### After `terraform apply` completes, show the output:

```bash
# Terraform will show this output automatically:
# - deployment_status
# - lab_info (topology details)
# - validation_info
```

**Point out:**
- Lab deployed successfully
- Validation ran automatically
- Both nodes are running

---

## 🔍 STEP 3: Check Lab Status (30 sec)

### Go back to lab directory and inspect:
```bash
cd ..
sudo containerlab inspect -t srl02-simple.clab.yml
```

**What to show:**
- ✅ Both containers are **running**
- ✅ Each has an IP address (172.20.20.x)
- ✅ Management network is up

**Say:** "Here we can see both SR Linux nodes are operational"

---

## 🌐 STEP 4: Verify OSPF Routing (1 min)

### Check OSPF neighbor on srl1:
```bash
docker exec clab-srl02-simple-srl1 sr_cli "show network-instance default protocols ospf neighbor"
```

**What to highlight:**
- ✅ Neighbor Router-ID: **2.2.2.2** (srl2)
- ✅ State: **full** (fully adjacent)
- ✅ Interface: **ethernet-1/1.0**

**Say:** "OSPF neighbor relationship is in FULL state, meaning routing information is being exchanged"

---

## 🔗 STEP 5: Verify BGP Session (1 min)

### Check BGP neighbor on srl1:
```bash
docker exec clab-srl02-simple-srl1 sr_cli "show network-instance default protocols bgp neighbor"
```

**What to highlight:**
- ✅ Peer: **10.0.0.2** (srl2)
- ✅ Peer-AS: **65002** (different AS = eBGP)
- ✅ State: **established** (session is up)
- ✅ Uptime: Shows how long session has been up

**Say:** "We have an eBGP peering between AS 65001 and AS 65002 in established state"

---

## 📡 STEP 6: Test Connectivity (30 sec)

### Ping from srl1 to srl2:
```bash
docker exec clab-srl02-simple-srl1 sr_cli "ping 10.0.0.2 -c 5 network-instance default"
```

**What to show:**
- ✅ **0% packet loss**
- ✅ RTT around 3ms
- ✅ All 5 packets successful

**Say:** "We have full Layer 3 connectivity between the routers"

---

## 🖥️ STEP 7: Interactive CLI Demo (2 min) [OPTIONAL]

### SSH into srl1:
```bash
ssh admin@clab-srl02-simple-srl1
# Password: NokiaSrl1!
```

### Inside the SR Linux CLI, run:
```bash
# Show all interfaces
show interface brief

# Show routing table
show network-instance default route-table

# Show system info
show version

# Exit
exit
```

**Say:** "This is the modern SR Linux CLI - notice the table-based output and user-friendly interface"

---

## 🧹 STEP 8: Cleanup (30 sec)

### Destroy the lab:
```bash
cd terraform
terraform destroy
# Type 'yes' when prompted
```

**Say:** "With one command, we can tear down the entire lab cleanly"

---

## ⚡ ALTERNATIVE: Super Quick Demo (2-3 min)

If you're short on time, use this ONE command after `terraform apply`:

```bash
cd /home/selima/containerlab-labs/2-node-srl

clear && \
echo "╔════════════════════════════════════════════╗" && \
echo "║   2-NODE SR LINUX LAB - STATUS CHECK      ║" && \
echo "╚════════════════════════════════════════════╝" && \
echo "" && \
echo "📦 Containers:" && \
docker ps --filter "name=srl02-simple" --format "table {{.Names}}\t{{.Status}}" && \
echo "" && \
echo "🔗 OSPF Status:" && \
docker exec clab-srl02-simple-srl1 sr_cli "show network-instance default protocols ospf neighbor" 2>/dev/null | grep -E "(ethernet|full)" && \
echo "" && \
echo "🌐 BGP Status:" && \
docker exec clab-srl02-simple-srl1 sr_cli "show network-instance default protocols bgp neighbor" 2>/dev/null | grep -E "(10.0.0.2|established)" && \
echo "" && \
echo "📡 Connectivity:" && \
docker exec clab-srl02-simple-srl1 sr_cli "ping 10.0.0.2 -c 3 network-instance default" 2>&1 | grep "transmitted" && \
echo "" && \
echo "✅ Lab is fully operational!"
```

This shows everything in one shot!

---

## 📋 Demo Cheat Sheet (Print This!)

### Quick Command Reference:

| Step | Command | What it Shows |
|------|---------|---------------|
| Deploy | `terraform apply` | Lab deployment |
| Status | `sudo containerlab inspect -t srl02-simple.clab.yml` | Container status |
| OSPF | `docker exec clab-srl02-simple-srl1 sr_cli "show network-instance default protocols ospf neighbor"` | OSPF adjacency |
| BGP | `docker exec clab-srl02-simple-srl1 sr_cli "show network-instance default protocols bgp neighbor"` | BGP session |
| Ping | `docker exec clab-srl02-simple-srl1 sr_cli "ping 10.0.0.2 -c 5 network-instance default"` | Connectivity |
| SSH | `ssh admin@clab-srl02-simple-srl1` | Interactive CLI |
| Destroy | `terraform destroy` | Cleanup |

---

## 💡 Tips for a Great Demo

### Before Demo:
1. ✅ Test `terraform apply` once to pull images (first time is slow)
2. ✅ Then run `terraform destroy`
3. ✅ Have this walkthrough open in a browser/terminal
4. ✅ Know your talking points for each step

### During Demo:
1. ✅ Explain WHAT you're doing before each command
2. ✅ Point out SUCCESS indicators (full, established, 0% loss)
3. ✅ Use the time during `terraform apply` to explain the topology
4. ✅ Have backup: If something fails, show the validation docs

### After Demo:
1. ✅ Show the documentation files (README.md, DEMO_READY.md)
2. ✅ Mention this can scale to larger topologies (3-node, CLOS, etc.)
3. ✅ Run `terraform destroy` to clean up

---

## 🎯 Key Points to Emphasize

1. **Infrastructure as Code**: Everything is defined in code, reproducible
2. **Automation**: Deploy, validate, destroy - all automated
3. **Containerization**: Fast, lightweight, no VM overhead
4. **Production-grade**: Nokia SR Linux is real network OS
5. **Protocols**: Real OSPF and BGP, not simulated
6. **Validation**: Automatic testing ensures everything works

---

## ❓ Common Questions & Answers

**Q: How long does deployment take?**  
A: 30-60 seconds (after images are cached)

**Q: Can this scale to larger topologies?**  
A: Yes! We have 3-node CLOS examples in the repo

**Q: Is this using real routing protocols?**  
A: Yes, full OSPF and BGP implementations

**Q: Can I SSH into the routers?**  
A: Yes, via SSH or docker exec

**Q: How do I change configurations?**  
A: Edit the .cfg files and redeploy

---

## 🔗 What to Say During Wait Times

### During `terraform apply` (30-60 sec):
- "We're deploying two Nokia SR Linux containers"
- "Each container is a full network operating system"
- "The topology connects them with a point-to-point link"
- "We're configuring OSPF for IGP and BGP for external routing"
- "Terraform handles the deployment and initial validation"

### During protocol convergence (if needed):
- "OSPF neighbors go through several states: Down, Init, ExStart, Exchange, Full"
- "BGP sessions establish after TCP connection and capability negotiation"
- "In production, convergence times are critical for network reliability"

---

## ✅ Success Criteria Checklist

After `terraform apply`, you should see:

- [ ] No error messages in Terraform output
- [ ] "Apply complete! Resources: 1 added"
- [ ] Validation script shows: "✓ Validation Complete!"
- [ ] Both containers in "running" state
- [ ] OSPF neighbor in "full" state
- [ ] BGP session in "established" state
- [ ] Ping shows "0% packet loss"

If ALL are checked ✅ → Demo is ready!

---

## 🎬 Complete Demo Script (Copy-Paste)

Here's the EXACT sequence for your demo:

```bash
# STEP 1: Navigate and deploy
cd /home/selima/containerlab-labs/2-node-srl/terraform
terraform apply
# (type 'yes')

# STEP 2: Go back to lab directory
cd ..

# STEP 3: Check lab status
sudo containerlab inspect -t srl02-simple.clab.yml

# STEP 4: Check OSPF
docker exec clab-srl02-simple-srl1 sr_cli "show network-instance default protocols ospf neighbor"

# STEP 5: Check BGP
docker exec clab-srl02-simple-srl1 sr_cli "show network-instance default protocols bgp neighbor"

# STEP 6: Test connectivity
docker exec clab-srl02-simple-srl1 sr_cli "ping 10.0.0.2 -c 5 network-instance default"

# STEP 7 (OPTIONAL): SSH demo
ssh admin@clab-srl02-simple-srl1
# Inside: show interface brief
# Inside: show network-instance default route-table
# Inside: exit

# STEP 8: Cleanup
cd terraform
terraform destroy
# (type 'yes')
```

**Done! 🎉**

---

## 📚 Related Documentation

- **Full validation commands**: `VALIDATION_COMMANDS.md`
- **Quick reference**: `QUICK_COMMANDS.md`
- **Complete overview**: `README.md`
- **Demo preparation**: `DEMO_READY.md`

---

**Good luck with your demo! You've got this! 🚀**
