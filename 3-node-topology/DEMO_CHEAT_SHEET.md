# 🎯 DEMO CHEAT SHEET - 3-Node CLOS Topology
**Keep this visible during your demo!**

---

## 📍 STEP-BY-STEP COMMANDS

### 1️⃣ DEPLOY (from terraform dir)
```bash
cd /home/selima/containerlab-labs/3-node-topology/terraform
terraform apply
```
Type: `yes`  
⏱️ Wait: 30-60 seconds

---

### 2️⃣ GO TO LAB DIR
```bash
cd ..
```

---

### 3️⃣ CHECK STATUS
```bash
containerlab inspect -t clos01.clab.yml
```
✅ Look for: **State = running** (5 containers: spine1, leaf1, leaf2, client1, client2)

---

### 4️⃣ VERIFY BGP ON SPINE1
```bash
docker exec clab-clos01-spine1 sr_cli "show network-instance default protocols bgp neighbor"
```
✅ Look for: **2 BGP sessions = established** (to leaf1 and leaf2)

---

### 5️⃣ VERIFY BGP ON LEAF1
```bash
docker exec clab-clos01-leaf1 sr_cli "show network-instance default protocols bgp neighbor"
```
✅ Look for: **State = established** (to spine1)

---

### 6️⃣ TEST UNDERLAY CONNECTIVITY
```bash
docker exec clab-clos01-leaf1 sr_cli "ping 10.1.1.1 -c 5 network-instance default"
```
✅ Look for: **0% packet loss** (leaf1 → spine1)

---

### 7️⃣ CONFIGURE CLIENTS (if needed)
```bash
# Client1
docker exec clab-clos01-client1 ip addr add 192.168.1.10/24 dev eth1
docker exec clab-clos01-client1 ip route add default via 192.168.1.1

# Client2
docker exec clab-clos01-client2 ip addr add 192.168.2.10/24 dev eth1
docker exec clab-clos01-client2 ip route add default via 192.168.2.1
```
**Note:** If you get "File exists" error, IPs are already configured - this is fine!

---

### 8️⃣ CHECK CLIENT CONNECTIVITY
```bash
# Client1 to Leaf1
docker exec clab-clos01-client1 ping -c 3 192.168.1.1

# Client2 to Leaf2
docker exec clab-clos01-client2 ping -c 3 192.168.2.1
```
✅ Look for: **0% packet loss** (both clients)

---

### 9️⃣ [OPTIONAL] SSH DEMO
```bash
ssh admin@clab-clos01-spine1
```
Password: `NokiaSrl1!`

Inside node:
```
show interface brief
show network-instance default protocols bgp neighbor
show network-instance default route-table
exit
```

---

### 🔟 CLEANUP
```bash
cd terraform
terraform destroy
```
Type: `yes`

---

## ⚡ ONE-COMMAND QUICK CHECK

After `terraform apply`, copy this ENTIRE command:

```
cd /home/selima/containerlab-labs/3-node-topology && echo "=== TOPOLOGY STATUS ===" && containerlab inspect -t clos01.clab.yml | grep -E "(Name|clab-clos01)" && echo "" && echo "=== SPINE1 BGP ===" && docker exec clab-clos01-spine1 sr_cli "show network-instance default protocols bgp neighbor" | grep -E "(10.1.1.0|10.1.2.0|established)" && echo "" && echo "=== LEAF1 TO SPINE1 PING ===" && docker exec clab-clos01-leaf1 sr_cli "ping 10.1.1.1 -c 3 network-instance default" | grep transmitted && echo "" && echo "=== CLIENT1 TO LEAF1 PING ===" && docker exec clab-clos01-client1 ping -c 3 192.168.1.1 | grep transmitted && echo "" && echo "=== CLIENT2 TO LEAF2 PING ===" && docker exec clab-clos01-client2 ping -c 3 192.168.2.1 | grep transmitted
```

**IMPORTANT:** Copy the command above WITHOUT the ```bash markers!

---

## ✅ SUCCESS INDICATORS

| Check | Success = |
|-------|-----------|
| Containers | **5 running** (spine1, leaf1, leaf2, client1, client2) |
| Spine1 BGP | **2 established** (leaf1, leaf2) |
| Leaf1 BGP | **established** (spine1) |
| Leaf2 BGP | **established** (spine1) |
| Underlay Ping | **0% loss** |
| Client1 Ping | **0% loss** (to 192.168.1.1) |
| Client2 Ping | **0% loss** (to 192.168.2.1) |

---

## 🎤 WHAT TO SAY

**During deploy:**
"Deploying a 3-node CLOS fabric with 1 spine and 2 leaf switches, plus 2 client hosts using Terraform and Containerlab"

**After deploy:**
"Lab deployed successfully. This is a typical datacenter leaf-spine architecture"

**Showing BGP:**
"The spine has 2 BGP sessions established - one to each leaf switch. This is a BGP underlay design"

**Showing underlay:**
"We have full Layer 3 connectivity in the underlay network using /31 point-to-point links"

**Showing clients:**
"Each client is connected to a leaf switch and can reach its default gateway"

---

## 🆘 IF SOMETHING FAILS

1. Check if lab is running:
```bash
containerlab inspect -t clos01.clab.yml
```

2. Check containers:
```bash
docker ps | grep clos01
```

3. Redeploy if needed:
```bash
cd terraform
terraform destroy
terraform apply
```

---

## 📋 TOPOLOGY QUICK REF

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

**Design:** BGP-only CLOS fabric (no OSPF)
**ASNs:** Spine=65100, Leaf1=65001, Leaf2=65002
**Underlay:** /31 point-to-point links
**Client Networks:** 192.168.1.0/24, 192.168.2.0/24

---

## ⏱️ TIMING

- Deploy: 1-2 min
- Validate: 3-5 min
- Destroy: 30 sec

**Total: 5-8 minutes**

---

## 💡 KEY DIFFERENCES FROM 2-NODE LAB

- **More nodes:** 5 containers instead of 2
- **BGP only:** No OSPF in this topology
- **Different ASNs:** Each leaf has unique ASN
- **Clients:** Linux containers for end-to-end testing
- **CLOS design:** Typical datacenter architecture

---

## 🔍 ADVANCED VALIDATION (Optional)

### Check all BGP sessions
```bash
# Spine1
docker exec clab-clos01-spine1 sr_cli "show network-instance default protocols bgp summary"

# Leaf1
docker exec clab-clos01-leaf1 sr_cli "show network-instance default protocols bgp summary"

# Leaf2
docker exec clab-clos01-leaf2 sr_cli "show network-instance default protocols bgp summary"
```

### Check routing tables
```bash
# Spine1 routes
docker exec clab-clos01-spine1 sr_cli "show network-instance default route-table"

# Leaf1 routes
docker exec clab-clos01-leaf1 sr_cli "show network-instance default route-table"
```

### Test client-to-client connectivity (if routes advertised)
```bash
# From client1 to client2's network (if BGP advertises it)
docker exec clab-clos01-client1 ping -c 3 192.168.2.1
```

---

**GOOD LUCK! 🚀**
