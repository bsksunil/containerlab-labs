# 🎯 DEMO CHEAT SHEET - 2-Node Lab
**Keep this visible during your demo!**

---

## 📍 STEP-BY-STEP COMMANDS

### 1️⃣ DEPLOY (from terraform dir)
```bash
cd /home/selima/containerlab-labs/2-node-srl/terraform
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
sudo containerlab inspect -t srl02-simple.clab.yml
```
✅ Look for: **State = running**

---

### 4️⃣ VERIFY OSPF
```bash
docker exec clab-srl02-simple-srl1 sr_cli "show network-instance default protocols ospf neighbor"
```
✅ Look for: **State = full**

---

### 5️⃣ VERIFY BGP
```bash
docker exec clab-srl02-simple-srl1 sr_cli "show network-instance default protocols bgp neighbor"
```
✅ Look for: **State = established**

---

### 6️⃣ TEST PING
```bash
docker exec clab-srl02-simple-srl1 sr_cli "ping 10.0.0.2 -c 5 network-instance default"
```
✅ Look for: **0% packet loss**

---

### 7️⃣ [OPTIONAL] SSH DEMO
```bash
ssh admin@clab-srl02-simple-srl1
```
Password: `NokiaSrl1!`

Inside node:
```
show interface brief
show network-instance default route-table
exit
```

---

### 8️⃣ CLEANUP
```bash
cd terraform
terraform destroy
```
Type: `yes`

---

## ⚡ ONE-COMMAND QUICK CHECK

After `terraform apply`, copy this ENTIRE command (without the ```bash markers):

```
cd /home/selima/containerlab-labs/2-node-srl && sudo containerlab inspect -t srl02-simple.clab.yml && echo "" && echo "=== OSPF ===" && docker exec clab-srl02-simple-srl1 sr_cli "show network-instance default protocols ospf neighbor" | grep full && echo "" && echo "=== BGP ===" && docker exec clab-srl02-simple-srl1 sr_cli "show network-instance default protocols bgp neighbor" | grep established && echo "" && echo "=== PING ===" && docker exec clab-srl02-simple-srl1 sr_cli "ping 10.0.0.2 -c 3 network-instance default" | grep transmitted
```

**IMPORTANT:** Copy the command above WITHOUT the ```bash line!

---

## ✅ SUCCESS INDICATORS

| Check | Success = |
|-------|-----------|
| Containers | **running** |
| OSPF | **full** |
| BGP | **established** |
| Ping | **0% loss** |

---

## 🎤 WHAT TO SAY

**During deploy:**
"Deploying 2 Nokia SR Linux routers with OSPF and BGP using Terraform and Containerlab"

**After deploy:**
"Lab deployed successfully, let's verify the routing protocols"

**Showing OSPF:**
"OSPF neighbor is in FULL state - routing information is being exchanged"

**Showing BGP:**
"eBGP session between AS 65001 and 65002 is ESTABLISHED"

**Showing ping:**
"We have full Layer 3 connectivity - 0% packet loss"

---

## 🆘 IF SOMETHING FAILS

1. Check if lab is running:
```bash
sudo containerlab inspect -t srl02-simple.clab.yml
```

2. Check containers:
```bash
docker ps | grep srl02
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
srl1 ←--ethernet-1/1--→ srl2
10.0.0.1/30           10.0.0.2/30
AS 65001              AS 65002
RID 1.1.1.1           RID 2.2.2.2
```

**Protocols:** OSPF Area 0.0.0.0 + eBGP

---

## ⏱️ TIMING

- Deploy: 1-2 min
- Validate: 3-4 min
- Destroy: 30 sec

**Total: 5-7 minutes**

---

## 💡 COPY-PASTE TIPS

**DON'T copy:**
- The word `bash` before commands
- The ``` backticks around commands
- Just copy the actual command text

**Example - WRONG:**
```bash
cd /home/selima/...
```

**Example - RIGHT:**
```
cd /home/selima/...
```

---

**GOOD LUCK! 🚀**
