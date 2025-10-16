# 3-Node CLOS Topology - Terraform Deployment

## 🚀 Quick Start

### Deploy the Lab (with automatic validation)
```bash
cd /home/selima/containerlab-labs/3-node-topology/terraform
terraform init
terraform apply -auto-approve
```

### Destroy the Lab
```bash
terraform destroy -auto-approve
```

## 📋 What Terraform Does

### On `terraform apply`:
1. **Deploys** the 3-node CLOS topology using containerlab
2. **Waits** 30 seconds for containers to initialize
3. **Validates** the deployment:
   - ✅ All 5 containers running (spine1, leaf1, leaf2, client1, client2)
   - ✅ Interface status checks
   - ✅ Underlay connectivity (Leaf1↔Spine1, Leaf2↔Spine1)
   - ✅ BGP session status (3 sessions total)
   - ✅ Client connectivity tests

### On `terraform destroy`:
- Cleanly destroys the topology and removes all containers

## 🛠️ Components

- **main.tf**: Terraform configuration with deployment and validation
- **deploy_containerlab.sh**: Script to deploy the lab with --reconfigure support
- **validate_connectivity.sh**: Comprehensive validation (11 checks)
- **destroy_containerlab.sh**: Clean teardown script

## 📊 Validation Checks

The automated validation performs:
1. Lab running check
2. Container health (5 containers)
3. Interface status (ethernet-1/1, ethernet-1/2)
4. BGP convergence wait (20 seconds)
5. Leaf1 → Spine1 ping test
6. Leaf2 → Spine1 ping test
7. Spine1 BGP sessions (2 neighbors)
8. Leaf1 BGP session status
9. Leaf2 BGP session status
10. Client1 connectivity test
11. Client2 connectivity test

## 📝 Expected Output

After `terraform apply`, you should see:
```
✓ Deployment completed successfully!
✓ All 5 containers are healthy
✓ ethernet-1/1 is UP
✓ ethernet-1/2 is UP
✓ Leaf1 -> Spine1 (10.1.1.1): 0% loss
✓ Leaf2 -> Spine1 (10.1.2.1): 0% loss
✓ BGP session Spine1 <-> Leaf1 is ESTABLISHED
✓ BGP session Spine1 <-> Leaf2 is ESTABLISHED
✓ BGP session Leaf1 <-> Spine1 is ESTABLISHED
✓ BGP session Leaf2 <-> Spine1 is ESTABLISHED
✓ Validation Complete!
```

## 🎯 Topology Details

```
         Spine1 (AS 65100)
         10.1.1.1/31  10.1.2.1/31
              |            |
    +---------+            +---------+
    |                               |
10.1.1.0/31                    10.1.2.0/31
  Leaf1                           Leaf2
 (AS 65001)                      (AS 65002)
    |                               |
  Client1                         Client2
192.168.1.10/24                 192.168.2.10/24
```

## 🔍 Post-Deployment Commands

After successful deployment, you can use these commands (from terraform outputs):

```bash
# Inspect the lab
sudo containerlab inspect -t clos01.clab.yml

# Check BGP on Spine1
docker exec clab-clos01-spine1 sr_cli 'show network-instance default protocols bgp neighbor'

# Check BGP on Leaf1
docker exec clab-clos01-leaf1 sr_cli 'show network-instance default protocols bgp neighbor'

# Test connectivity
docker exec clab-clos01-leaf1 sr_cli 'ping 10.1.1.1 -c 3 network-instance default'
```

## 🔧 Manual Validation

If you want to run validation manually:
```bash
./validate_connectivity.sh ..
```

## ⚠️ Requirements

- Terraform >= 1.0
- Docker
- Containerlab
- sudo privileges
- Nokia SR Linux container image

## 📖 Related Files

- `../clos01.clab.yml`: Topology definition
- `../DEMO_CHEAT_SHEET.md`: Demo commands
- `../VALIDATION_COMMANDS.md`: Manual validation guide
