# Terraform Validation - Quick Reference

## One-Command Validation
```bash
cd /home/selima/containerlab-labs/srl-xrv9k-lab/terraform
terraform apply -auto-approve
```

## What It Does
- Runs comprehensive validation script
- Checks all 9 validation points
- Always runs (uses timestamp trigger)
- No deployment/destroy - validation only

## Expected Output
```
Outputs:

lab_info = {
  "credentials" = {
    "srl" = "admin / NokiaSrl1!"
    "xrv9k" = "clab / clab@123"
  }
  "deployment_notes" = "Deploy manually, then run: terraform apply -auto-approve"
  "nodes" = ["srl", "xrv9k"]
  "topology" = "Multi-vendor: Nokia SR Linux + Cisco XRv9k"
}

quick_commands = {
  "deploy_lab" = "sudo containerlab deploy -t ../srl-xrv9k.clab.yml"
  "destroy_lab" = "sudo containerlab destroy -t ../srl-xrv9k.clab.yml --cleanup"
  "manual_validate" = "bash validate_connectivity.sh"
  "validate" = "terraform apply -auto-approve"
}

validation_status = "Run 'terraform apply -auto-approve' to validate the lab"
```

## Validation Checks (9 total)
1. Lab deployed and running
2. Container health (both running + healthy)
3. SR Linux interface up
4. XRv9k interface up
5. 30-second BGP convergence wait
6. SR Linux BGP session ESTABLISHED
7. XRv9k BGP session ESTABLISHED
8. SR Linux → XRv9k ping (0% loss)
9. XRv9k → SR Linux ping (0% loss)

## Manual Script Execution
```bash
# If you want to run validation without Terraform
cd /home/selima/containerlab-labs/srl-xrv9k-lab/terraform
bash validate_connectivity.sh
```

## Comparison with 3-node CLOS Lab

### 3-node CLOS (Fully Automated)
```bash
terraform apply -auto-approve    # Deploy + validate (~1m 33s)
terraform destroy -auto-approve  # Clean teardown (~9s)
```

### Multi-vendor (Manual + Validation)
```bash
# Deploy (manual)
sudo containerlab deploy -t ../srl-xrv9k.clab.yml  # ~25 mins for XRv9k

# Configure (manual - see MANUAL_CONFIG.md)
# ... apply configs to both devices

# Validate (automated)
terraform apply -auto-approve  # ~50s
```

## Why Different Approaches?

**3-node CLOS:** Same vendor (all SR Linux)
- Startup-config works reliably
- Fast boot times (~20-30 seconds)
- Predictable behavior
- → Full automation possible

**Multi-vendor:** Different vendors (Nokia + Cisco)
- XRv9k has very long boot time (20-25 mins)
- Healthcheck reliability issues  
- Config syntax differences
- → Manual approach more reliable for demos

## Future Automation Goals
After demo, investigate:
- Scripted config application post-boot
- Better healthcheck handling for XRv9k
- Automated wait-for-ready logic
- Startup-config troubleshooting
