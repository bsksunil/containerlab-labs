# Multi-vendor Lab - Quick Start Guide

## Lab Topology
```
┌─────────────┐                    ┌─────────────┐
│  SR Linux   │ e1-1 ──────── Gi0  │   XRv9k     │
│  (Nokia)    │ 192.168.1.1/30     │   (Cisco)   │
│  AS 65100   │                    │  AS 65200   │
└─────────────┘                    └─────────────┘
```

## Deployment Workflow

### 1. Deploy Lab (Manual - ~25 minutes for XRv9k boot)
```bash
cd /home/selima/containerlab-labs/srl-xrv9k-lab
sudo containerlab deploy -t srl-xrv9k.clab.yml
```

### 2. Wait for XRv9k to become healthy
```bash
# Monitor status (wait for "healthy")
watch -n 10 'sudo containerlab inspect -t srl-xrv9k.clab.yml'
```
**Note:** XRv9k takes approximately **20-25 minutes** to reach healthy state.

### 3. Apply SR Linux Configuration
```bash
# Interface config
docker exec clab-srl-xrv9k-srl sr_cli -e "interface ethernet-1/1 admin-state enable" -c
docker exec clab-srl-xrv9k-srl sr_cli -e "interface ethernet-1/1 subinterface 0 admin-state enable" -c
docker exec clab-srl-xrv9k-srl sr_cli -e "interface ethernet-1/1 subinterface 0 ipv4 admin-state enable" -c
docker exec clab-srl-xrv9k-srl sr_cli -e "interface ethernet-1/1 subinterface 0 ipv4 address 192.168.1.1/30" -c
docker exec clab-srl-xrv9k-srl sr_cli -e "network-instance default interface ethernet-1/1.0" -c

# BGP config
docker exec clab-srl-xrv9k-srl sr_cli -e "network-instance default protocols bgp admin-state enable autonomous-system 65100 router-id 10.0.0.1 afi-safi ipv4-unicast admin-state enable" -c
docker exec clab-srl-xrv9k-srl sr_cli -e "network-instance default protocols bgp group ebgp peer-as 65200" -c
docker exec clab-srl-xrv9k-srl sr_cli -e "network-instance default protocols bgp group ebgp admin-state enable afi-safi ipv4-unicast admin-state enable" -c
docker exec clab-srl-xrv9k-srl sr_cli -e "network-instance default protocols bgp neighbor 192.168.1.2 peer-group ebgp" -c
```

### 4. Apply XRv9k Configuration
```bash
ssh clab@clab-srl-xrv9k-xrv9k
# Password: clab@123

# Then paste:
configure
interface GigabitEthernet0/0/0/0
 ipv4 address 192.168.1.2 255.255.255.252
 no shutdown
exit
router bgp 65200
 bgp router-id 10.0.0.2
 address-family ipv4 unicast
 exit
 neighbor 192.168.1.1
  remote-as 65100
  address-family ipv4 unicast
  exit
 exit
exit
commit
end
```

### 5. Validate with Terraform
```bash
cd terraform
terraform apply -auto-approve
```

## Quick Validation Commands

### Manual Validation
```bash
# SR Linux
docker exec clab-srl-xrv9k-srl sr_cli "show network-instance default protocols bgp neighbor"

# XRv9k
ssh clab@clab-srl-xrv9k-xrv9k "show bgp summary"
ssh clab@clab-srl-xrv9k-xrv9k "ping 192.168.1.1 count 3"
```

### Terraform Validation
```bash
cd terraform
terraform apply -auto-approve  # Runs all 9 validation checks
```

## Destroy Lab
```bash
sudo containerlab destroy -t srl-xrv9k.clab.yml --cleanup
```

## Credentials
- **SR Linux:** admin / NokiaSrl1!
- **XRv9k:** clab / clab@123

## Expected Results
- ✅ BGP sessions: ESTABLISHED
- ✅ Ping success rate: 100%
- ✅ All 9 validation checks: PASS

## Troubleshooting
- **XRv9k shows "unhealthy":** Wait longer (up to 25 minutes)
- **BGP not establishing:** Check interface status first
- **SSH timeout to XRv9k:** Router may still be booting

## Files Reference
- `srl-xrv9k.clab.yml` - Topology definition
- `srl.cfg` - SR Linux startup config (reference)
- `xrv9k.cfg` - XRv9k startup config (reference)
- `terraform/validate_connectivity.sh` - Validation script
- `terraform/main.tf` - Validation-only Terraform
- `MANUAL_CONFIG.md` - Step-by-step config guide
