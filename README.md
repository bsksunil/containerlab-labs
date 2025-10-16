# Containerlab Network Labs

A collection of network topology labs using [Containerlab](https://containerlab.dev/) for network automation, testing, and demonstrations.

## 🎯 Overview

This repository contains various network lab topologies featuring:
- **Nokia SR Linux** configurations
- **Cisco IOS XR** (XRv9k) multi-vendor scenarios
- **BGP routing** setups
- **CLOS/Leaf-Spine** architectures
- **Terraform automation** for deployment and validation

## 📁 Repository Structure

```
containerlab-labs/
├── 2-node-srl/              # Basic 2-node SR Linux topology with Terraform
├── 3-node-topology/         # 3-node CLOS topology (fully automated)
├── srl-xrv9k-lab/          # Multi-vendor: SR Linux + Cisco XRv9k
├── srl-xrd-topology/       # SR Linux + Cisco XRd topology
├── advanced-labs/          # Advanced lab scenarios
├── basic-labs/             # Basic learning labs
├── clos-labs/              # CLOS architecture labs
├── configs/                # Configuration templates
└── scripts/                # Utility scripts
```

## 🚀 Quick Start

### Prerequisites

- **Containerlab** v0.70.2 or later
- **Docker** 20.10 or later
- **Terraform** v1.0+ (for automated deployments)
- **sudo** access (required for containerlab)

### Installation

```bash
# Install Containerlab
sudo bash -c "$(curl -sL https://get.containerlab.dev)"

# Clone this repository
git clone https://wwwin-github.cisco.com/YOUR_USERNAME/containerlab-labs.git
cd containerlab-labs
```

## 📚 Featured Labs

### 1. Three-Node CLOS Topology (Fully Automated)
**Location:** `3-node-topology/`

A production-ready CLOS topology with complete Terraform automation.

**Features:**
- 1 Spine + 2 Leaf switches + 2 client containers
- Full BGP eBGP underlay configuration
- Automated deployment, validation, and teardown
- 11 comprehensive validation checks

**Quick Deploy:**
```bash
cd 3-node-topology/terraform
terraform apply -auto-approve   # Deploy + validate (~1m 33s)
terraform destroy -auto-approve # Clean teardown (~9s)
```

**Validation Checks:**
- ✅ Lab status and container health
- ✅ Interface status (all nodes)
- ✅ BGP session establishment (3 sessions)
- ✅ Underlay connectivity tests
- ✅ Client connectivity tests

### 2. Multi-Vendor Lab (SR Linux + XRv9k)
**Location:** `srl-xrv9k-lab/`

Production multi-vendor topology demonstrating Nokia-Cisco interoperability.

**Features:**
- Nokia SR Linux + Cisco IOS XRv9k
- eBGP peering across vendors
- Automated validation with Terraform
- Comprehensive documentation

**Deployment:**
```bash
cd srl-xrv9k-lab
sudo containerlab deploy -t srl-xrv9k.clab.yml

# Wait for XRv9k to become healthy (~20-25 minutes)
watch -n 10 'sudo containerlab inspect -t srl-xrv9k.clab.yml'

# Apply configurations (see MANUAL_CONFIG.md)
# Then validate:
cd terraform
terraform apply -auto-approve  # 9 validation checks
```

**Note:** XRv9k has a long boot time (~23 minutes). See `QUICK_START.md` for details.

### 3. Two-Node SR Linux Lab
**Location:** `2-node-srl/`

Simple 2-node topology perfect for learning SR Linux basics.

**Quick Deploy:**
```bash
cd 2-node-srl
sudo containerlab deploy -t srl02-simple.clab.yml
```

## 🛠️ Terraform Automation

### 3-Node CLOS (Full Automation)
```bash
cd 3-node-topology/terraform
terraform init
terraform apply -auto-approve    # Deploy + validate
terraform destroy -auto-approve  # Teardown
```

### Multi-Vendor (Validation Only)
```bash
cd srl-xrv9k-lab/terraform
terraform init
terraform apply -auto-approve  # Validate existing deployment
```

## 📖 Documentation

Each lab directory contains:
- `README.md` - Lab-specific overview
- `*.clab.yml` - Containerlab topology definition
- `*.cfg` - Device startup configurations
- `terraform/` - Terraform automation (where applicable)
- `QUICK_START.md` - Quick reference guide
- `DEMO_CHEAT_SHEET.md` - Demo walkthrough

## 🔍 Validation

All labs include validation scripts to verify:
- Container health and status
- Interface operational state
- Routing protocol sessions (BGP)
- End-to-end connectivity
- Configuration compliance

## 🎓 Learning Path

**Beginner:**
1. Start with `2-node-srl/` - Basic SR Linux topology
2. Explore `basic-labs/` - Fundamental concepts

**Intermediate:**
3. Deploy `3-node-topology/` - CLOS architecture
4. Study `clos-labs/` - Advanced CLOS scenarios

**Advanced:**
5. Multi-vendor `srl-xrv9k-lab/` - Vendor interoperability
6. Explore `advanced-labs/` - Complex scenarios

## 🤝 Contributing

Contributions welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Test your changes thoroughly
4. Submit a pull request

## 📝 License

[Add your license here]

## 🔗 Resources

- [Containerlab Documentation](https://containerlab.dev/)
- [Nokia SR Linux](https://learn.srlinux.dev/)
- [Terraform](https://www.terraform.io/)

## 👤 Author

Selima - Cisco Systems

## 📊 Lab Statistics

- **Total Labs:** 7+
- **Vendors:** Nokia (SR Linux), Cisco (IOS XR)
- **Automation:** Terraform, Bash scripts
- **Validation Checks:** 20+ automated tests
- **Deployment Time:** ~1-30 minutes (depending on lab)

---

**Note:** Some labs require vendor-specific container images. Refer to individual lab READMEs for image requirements.
