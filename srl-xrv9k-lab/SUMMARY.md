# Multi-vendor Lab - Project Summary

## Overview
Multi-vendor network lab featuring Nokia SR Linux and Cisco XRv9k with BGP peering and automated validation.

## Architecture
- **Topology:** 2-node point-to-point
- **Vendors:** Nokia SR Linux + Cisco XRv9k  
- **Protocol:** eBGP (AS 65100 ↔ AS 65200)
- **Addressing:** 192.168.1.0/30 (/31 equivalent)

## Deployment Method
**Current Approach: Manual Deploy + Config, Terraform for Validation**

### Why Manual Configuration?
1. **XRv9k boot time:** 20-25 minutes to reach healthy state
2. **Startup-config issues:** Config errors during automated deployment prevented interface from coming up
3. **Demo reliability:** Manual approach ensures configs are verified before validation

### Future Enhancement
After demo, investigate:
- XRv9k healthcheck timing/reliability
- Proper startup-config syntax for both vendors
- Automated post-boot configuration scripts

## Files Created

### Configuration Files
- `srl.cfg` - SR Linux config (interface + BGP with address-family)
- `xrv9k.cfg` - XRv9k config (interface + BGP)
- `srl-xrv9k.clab.yml` - Topology definition (no startup-config refs)

### Automation Scripts
- `terraform/validate_connectivity.sh` - 9-check validation script
- `terraform/main.tf` - Validation-only Terraform (triggers on every apply)
- `apply_srl_config.sh` - SR Linux config script (for reference)
- `apply_xrv9k_config.sh` - XRv9k config script (for reference)

### Documentation
- `QUICK_START.md` - Complete deployment guide
- `MANUAL_CONFIG.md` - Step-by-step config instructions
- `SUMMARY.md` - This file

## Validation Checks (9 total)
1. ✅ Lab status (containerlab inspect)
2. ✅ Container health (SR Linux: running, XRv9k: healthy)
3. ✅ SR Linux interface status (ethernet-1/1 up)
4. ✅ XRv9k interface status (Gi0/0/0/0 up)
5. ✅ BGP convergence wait (30 seconds)
6. ✅ SR Linux BGP neighbor (session ESTABLISHED)
7. ✅ XRv9k BGP neighbor (session ESTABLISHED)
8. ✅ SR Linux → XRv9k ping (0% loss, ~4ms RTT)
9. ✅ XRv9k → SR Linux ping (0% loss)

## Key Learnings

### SR Linux
- BGP requires explicit `afi-safi ipv4-unicast admin-state enable`
- Both at global BGP level and per-group level
- Config applied via `sr_cli -e "command" -c` format
- Commit happens automatically with `-c` flag

### XRv9k  
- Very long boot time (~20-25 minutes to healthy)
- Healthcheck remains "starting" for extended period
- SSH not responsive until fully booted
- BGP requires explicit `address-family ipv4 unicast` activation
- Warning about route-policy (!) is cosmetic - BGP works

### Containerlab
- Startup-config feature is vendor-specific
- Health checks vary by container type
- Manual config is more reliable for complex multivendor setups

## Deployment Timeline
- **Containerlab deploy:** ~30 seconds
- **XRv9k boot to healthy:** ~20-25 minutes
- **SR Linux config apply:** ~1 minute
- **XRv9k config apply:** ~2 minutes (manual SSH)
- **Validation run:** ~50 seconds (includes 30s BGP wait)
- **Total:** ~25-30 minutes end-to-end

## Demo Workflow
```bash
# 1. Pre-demo: Deploy and wait for healthy
sudo containerlab deploy -t srl-xrv9k.clab.yml
watch -n 10 'sudo containerlab inspect -t srl-xrv9k.clab.yml'

# 2. Demo starts: Show unconfigured state
ssh admin@clab-srl-xrv9k-srl
ssh clab@clab-srl-xrv9k-xrv9k

# 3. Apply configs (can be done beforehand)
# Use MANUAL_CONFIG.md or QUICK_START.md

# 4. Show validation
cd terraform
terraform apply -auto-approve

# 5. Show BGP sessions
docker exec clab-srl-xrv9k-srl sr_cli "show network-instance default protocols bgp neighbor"
ssh clab@clab-srl-xrv9k-xrv9k "show bgp summary"
```

## Success Criteria - All Met! ✅
- [x] Lab deploys successfully
- [x] XRv9k reaches healthy state
- [x] BGP sessions establish bidirectionally
- [x] Ping works both directions with 0% loss
- [x] Terraform validation runs and passes all checks
- [x] Documentation complete for demos

## Next Steps (Post-Demo)
1. Investigate automated config application
2. Test startup-config with corrected syntax
3. Add more validation checks (route exchange, etc.)
4. Create multi-node multivendor topology
5. Add automation for config save/restore

## Related Labs
- `/home/selima/containerlab-labs/2-node-srl/` - Basic 2-node SR Linux
- `/home/selima/containerlab-labs/3-node-topology/` - 3-node CLOS with full Terraform automation
- `/home/selima/containerlab-labs/srl-xrd-topology/` - SR Linux + XRd (simpler alternative)
