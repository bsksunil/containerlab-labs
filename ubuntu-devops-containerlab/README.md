# Ubuntu DevOps Container with Containerlab

## Complete Step-by-Step Guide

This guide explains how to create and deploy a containerized Ubuntu environment with Python, Ansible, and Terraform using Containerlab.

---

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Method 1: Using Base Ubuntu Image (Slow)](#method-1-using-base-ubuntu-image-slow)
3. [Method 2: Using Custom Docker Image (Fast - Recommended)](#method-2-using-custom-docker-image-fast---recommended)
4. [Accessing the Container](#accessing-the-container)
5. [Useful Commands](#useful-commands)
6. [Troubleshooting](#troubleshooting)

---

## Prerequisites

**Required Software:**
- Containerlab installed and configured
- Docker Desktop or Docker runtime
- macOS/Linux operating system

**Verify Installation:**
```bash
clab version
docker --version
```

---

## Method 1: Using Base Ubuntu Image (Slow)

This method installs tools at deployment time (takes 5+ minutes).

### Step 1: Create Project Directory
```bash
mkdir -p ubuntu-devops-project
cd ubuntu-devops-project
```

### Step 2: Create Installation Script
Create `setup-tools.sh`:
```bash
#!/bin/bash

echo "Starting tool installation..."

# Update package manager
apt-get update -qq

# Install Python3 and pip
echo "Installing Python3..."
apt-get install -y python3 python3-pip >/dev/null 2>&1

# Install Ansible
echo "Installing Ansible..."
apt-get install -y software-properties-common >/dev/null 2>&1
apt-add-repository --yes --update ppa:ansible/ansible >/dev/null 2>&1
apt-get install -y ansible >/dev/null 2>&1

# Install Terraform
echo "Installing Terraform..."
apt-get install -y wget unzip >/dev/null 2>&1
wget -q https://releases.hashicorp.com/terraform/1.13.5/terraform_1.13.5_linux_amd64.zip -O /tmp/terraform.zip
unzip -q /tmp/terraform.zip -d /usr/local/bin/
chmod +x /usr/local/bin/terraform
rm /tmp/terraform.zip

# Clean up
apt-get clean
rm -rf /var/lib/apt/lists/*

# Verify installations
echo "===== Installed Versions ====="
python3 --version
ansible --version | head -1
terraform --version

echo "Setup complete!"
```

### Step 3: Create Workspace Directory
```bash
mkdir -p ubuntu-workspace
```

### Step 4: Create Containerlab Topology File
Create `ubuntu-devops.clab.yml`:
```yaml
name: ubuntu-devops

topology:
  nodes:
    ubuntu-dev:
      kind: linux
      image: ubuntu:22.04
      cmd: bash -c "sleep infinity"
      binds:
        - ./ubuntu-workspace:/workspace
        - ./setup-tools.sh:/setup-tools.sh
      exec:
        - bash /setup-tools.sh
```

### Step 5: Deploy the Lab
```bash
clab deploy -t ubuntu-devops.clab.yml
```

**Note:** This will take 5-6 minutes as it installs all tools.

---

## Method 2: Using Custom Docker Image (Fast - Recommended)

This method pre-builds an image with all tools (deploy in ~5 seconds).

### Step 1: Create Project Directory
```bash
mkdir -p ubuntu-devops-project
cd ubuntu-devops-project
```

### Step 2: Create Dockerfile
Create `Dockerfile`:
```dockerfile
FROM ubuntu:22.04

# Avoid interactive prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Install Python, Ansible, and Terraform in one layer
RUN apt-get update && \
    apt-get install -y \
        python3 \
        python3-pip \
        software-properties-common \
        wget \
        unzip && \
    # Install Ansible from PPA
    apt-add-repository --yes --update ppa:ansible/ansible && \
    apt-get install -y ansible && \
    # Install Terraform
    wget -q https://releases.hashicorp.com/terraform/1.13.5/terraform_1.13.5_linux_amd64.zip -O /tmp/terraform.zip && \
    unzip -q /tmp/terraform.zip -d /usr/local/bin/ && \
    chmod +x /usr/local/bin/terraform && \
    rm /tmp/terraform.zip && \
    # Clean up to reduce image size
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Keep container running
CMD ["bash", "-c", "sleep infinity"]
```

### Step 3: Build Custom Docker Image
```bash
docker build -t ubuntu-devops:latest .
```

**Explanation of the build command:**
- `docker build` - Command to build an image
- `-t ubuntu-devops:latest` - Tag (name) the image as "ubuntu-devops" with tag "latest"
- `.` - Build context (current directory containing Dockerfile)

**This takes ~5 minutes but only needs to be done once.**

### Step 4: Verify the Image
```bash
docker images ubuntu-devops
```

Expected output:
```
REPOSITORY      TAG       IMAGE ID       CREATED         SIZE
ubuntu-devops   latest    4bd0d469281f   X minutes ago   990MB
```

### Step 5: Create Workspace Directory
```bash
mkdir -p ubuntu-workspace
```

### Step 6: Create Simple Containerlab Topology
Create `ubuntu-devops.clab.yml`:
```yaml
name: ubuntu-devops

topology:
  nodes:
    ubuntu-dev:
      kind: linux
      image: ubuntu-devops:latest
      binds:
        - ./ubuntu-workspace:/workspace
```

### Step 7: Deploy the Lab
```bash
clab deploy -t ubuntu-devops.clab.yml
```

**This deploys in ~5 seconds!**

### Step 8: Verify Installation
```bash
docker exec clab-ubuntu-devops-ubuntu-dev bash -c "python3 --version && ansible --version | head -1 && terraform --version | head -1"
```

Expected output:
```
Python 3.10.12
ansible [core 2.17.14]
Terraform v1.13.5
```

---

## Accessing the Container

### Interactive Shell Access
```bash
docker exec -it clab-ubuntu-devops-ubuntu-dev bash
```

### Run a Single Command
```bash
docker exec clab-ubuntu-devops-ubuntu-dev <command>
```

### Examples:
```bash
# Check Python version
docker exec clab-ubuntu-devops-ubuntu-dev python3 --version

# Run Ansible command
docker exec clab-ubuntu-devops-ubuntu-dev ansible --version

# Check Terraform version
docker exec clab-ubuntu-devops-ubuntu-dev terraform --version
```

---

## Workspace Folder

The `ubuntu-workspace` folder on your host is mounted to `/workspace` inside the container.

**What this means:**
- Files created in `ubuntu-workspace/` on your Mac appear in `/workspace/` in the container
- Files created in `/workspace/` in the container appear in `ubuntu-workspace/` on your Mac
- Changes are bidirectional and instant

**Use cases:**
- Edit Ansible playbooks on your Mac with VS Code
- Run them inside the container
- Store Terraform configurations
- Persist data between container restarts

**Example:**
```bash
# On your Mac
echo "Hello from Mac" > ubuntu-workspace/test.txt

# Inside container
docker exec clab-ubuntu-devops-ubuntu-dev cat /workspace/test.txt
# Output: Hello from Mac
```

---

## Useful Commands

### Check Lab Status
```bash
clab inspect --all
```

### Destroy the Lab
```bash
clab destroy -t ubuntu-devops.clab.yml
```

### Redeploy (destroy and deploy)
```bash
clab deploy -t ubuntu-devops.clab.yml --reconfigure
```

### View Container Logs
```bash
docker logs clab-ubuntu-devops-ubuntu-dev
```

### List Running Containers
```bash
docker ps
```

### Remove Custom Image (if needed)
```bash
docker rmi ubuntu-devops:latest
```

---

## Understanding Key Concepts

### What is Containerlab?
Containerlab is a tool for orchestrating and managing container-based networking labs. It's designed for network engineers but works for any containerized environment.

### What is a Docker Image?
A Docker image is a pre-packaged template containing:
- Operating system
- Installed software
- Configuration files
- Everything needed to run a container

Think of it as a "frozen" state that can be started instantly.

### What is a Dockerfile?
A Dockerfile is a text file with instructions to build a Docker image. It's like a recipe:
- `FROM ubuntu:22.04` - Start with Ubuntu
- `RUN apt-get install` - Install software
- `CMD` - What to run when container starts

### Bind Mounts
The `binds` section in the YAML creates a shared folder:
```yaml
binds:
  - ./ubuntu-workspace:/workspace
```
- Left side (`./ubuntu-workspace`) = folder on your Mac
- Right side (`/workspace`) = folder inside container
- Files are synchronized automatically

---

## File Structure

After setup, your project should look like this:

```
ubuntu-devops-project/
├── Dockerfile                  # Instructions to build custom image
├── ubuntu-devops.clab.yml      # Containerlab topology definition
└── ubuntu-workspace/           # Shared folder (host ↔ container)
    └── (your files here)
```

---

## Troubleshooting

### Issue: Container Not Starting
**Solution:** Check if port conflicts exist
```bash
docker ps -a
clab destroy -t ubuntu-devops.clab.yml
clab deploy -t ubuntu-devops.clab.yml
```

### Issue: Tools Not Installed
**Solution:** Rebuild the Docker image
```bash
docker rmi ubuntu-devops:latest
docker build -t ubuntu-devops:latest .
clab deploy -t ubuntu-devops.clab.yml --reconfigure
```

### Issue: Permission Denied for /etc/hosts
**Solution:** This is a warning and can be ignored. The lab still works.

### Issue: Deployment Takes Too Long
**Solution:** Use Method 2 (Custom Docker Image) instead of Method 1.

### Issue: Cannot Access Workspace Files
**Solution:** Ensure the path in binds is relative to the YAML file location:
```yaml
binds:
  - ./ubuntu-workspace:/workspace  # Correct - relative path
```

---

## Version Information

**Software Versions (as of November 2025):**
- Ubuntu: 22.04 LTS
- Python: 3.10.12
- Ansible: 2.17.14
- Terraform: 1.13.5

**To update Terraform version:**
Edit the Dockerfile and change:
```dockerfile
wget -q https://releases.hashicorp.com/terraform/1.13.5/terraform_1.13.5_linux_amd64.zip
```
to the desired version, then rebuild the image.

---

## Summary

**Method 1 (Base Image):**
- ✅ Simple YAML file
- ❌ Slow deployment (5+ minutes)
- ❌ Installation can fail
- 📝 Use for: Testing, one-time deployments

**Method 2 (Custom Image):**
- ✅ Fast deployment (~5 seconds)
- ✅ Reliable - always works
- ✅ Repeatable
- ❌ Requires building image first (one-time, 5 minutes)
- 📝 Use for: Production, frequent use, team sharing

**Recommended:** Use Method 2 (Custom Docker Image) for best results.

---

## Next Steps

1. ✅ Deploy your container
2. ✅ Verify tools are installed
3. 📝 Create Ansible playbooks in `ubuntu-workspace/`
4. 📝 Create Terraform configurations in `ubuntu-workspace/`
5. 🚀 Execute them inside the container

---

## Support

For issues or questions:
- Containerlab Documentation: https://containerlab.dev/
- Docker Documentation: https://docs.docker.com/
- Ansible Documentation: https://docs.ansible.com/
- Terraform Documentation: https://www.terraform.io/docs

---

**Document Version:** 1.0  
**Last Updated:** November 14, 2025  
**Author:** DevOps Team
