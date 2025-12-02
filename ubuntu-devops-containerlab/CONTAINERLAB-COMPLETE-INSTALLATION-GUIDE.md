# Containerlab Complete Installation Guide

This guide covers Containerlab installation for **Linux**, **macOS**, and **Windows**.

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Linux Installation](#linux-installation)
3. [macOS Installation](#macos-installation)
4. [Windows Installation](#windows-installation)
5. [Building from Source](#building-from-source)
6. [Verification](#verification)
7. [Troubleshooting](#troubleshooting)
8. [Uninstallation](#uninstallation)

---

## Prerequisites

### All Platforms

- **Docker** must be installed and running
  - Docker Desktop (macOS/Windows)
  - Docker Engine (Linux)
- Minimum **2 vCPU** and **4GB RAM** recommended
- **Administrative/sudo privileges** for installation

### Platform-Specific Requirements

| Platform | Requirement |
|----------|-------------|
| **Linux** | Linux kernel with IPv6 enabled |
| **macOS** | macOS 11+ (Intel or Apple Silicon) |
| **Windows** | Windows 10/11 with WSL2 enabled |

---

## Linux Installation

### Method 1: Quick Setup Script (Recommended)

Installs Docker, Containerlab, and GitHub CLI in one command:

```bash
curl -sL https://containerlab.dev/setup | sudo -E bash -s "all"
```

**Supported Linux distributions:**
- Ubuntu 20.04, 22.04, 23.10, 24.04
- Debian 11, 12
- Red Hat Enterprise Linux 9
- CentOS Stream 9
- Fedora Server 40
- Rocky Linux 9.3, 8.8

**After installation:**
```bash
# Enable sudo-less Docker
newgrp docker

# Or logout and log back in
```

---

### Method 2: Install Script Only

Install only Containerlab (requires Docker pre-installed):

```bash
bash -c "$(curl -sL https://get.containerlab.dev)"
```

This installs:
- Binary: `/usr/bin/containerlab`
- Symlink: `/usr/bin/clab` → `/usr/bin/containerlab`

---

### Method 3: Package Manager

#### Debian/Ubuntu (APT)

```bash
# Add repository
echo "deb [trusted=yes] https://netdevops.fury.site/apt/ /" | \
  sudo tee -a /etc/apt/sources.list.d/netdevops.list

# Update and install
sudo apt update && sudo apt install containerlab
```

#### RHEL/CentOS/Fedora (YUM)

```bash
# Add repository
sudo yum-config-manager --add-repo=https://netdevops.fury.site/yum/ \
  --save --setopt=*gpgcheck=0 --setopt=*enabled=1

# Install
sudo yum install containerlab
```

#### DNF (Fedora/RHEL 8+)

```bash
# Add repository
cat <<EOF | sudo tee /etc/yum.repos.d/netdevops.repo
[netdevops]
name=netdevops
baseurl=https://netdevops.fury.site/yum/
enabled=1
gpgcheck=0
EOF

# Install
sudo dnf install containerlab
```

#### Alpine Linux (APK)

```bash
# Add repository
echo "https://netdevops.fury.site/apk/" | \
  sudo tee -a /etc/apk/repositories

# Install
sudo apk add containerlab
```

#### Arch Linux (AUR)

```bash
# Using yay (AUR helper)
yay -S containerlab-bin

# Or using paru
paru -S containerlab-bin

# Manual installation from AUR
git clone https://aur.archlinux.org/containerlab-bin.git
cd containerlab-bin
makepkg -si
```

---

### Method 4: Manual Installation

```bash
# Get latest version
LATEST=$(curl -s https://github.com/srl-labs/containerlab/releases/latest | \
       sed -e 's/.*tag\/v\(.*\)\".*/\1/')

# Download archive
curl -L -o /tmp/clab.tar.gz \
  "https://github.com/srl-labs/containerlab/releases/download/v${LATEST}/containerlab_${LATEST}_Linux_amd64.tar.gz"

# Extract and install
sudo mkdir -p /etc/containerlab
sudo tar -zxvf /tmp/clab.tar.gz -C /etc/containerlab
sudo mv /etc/containerlab/containerlab /usr/bin/
sudo chmod a+x /usr/bin/containerlab

# Create symlink
sudo ln -s /usr/bin/containerlab /usr/bin/clab
```

---

### Linux Post-Installation

#### Enable Sudo-less Operation

Containerlab is installed with SUID bit for sudo-less operation.

**Add user to clab_admins group:**
```bash
sudo usermod -aG clab_admins $USER
newgrp clab_admins
```

**To disable sudo-less operation:**
```bash
sudo chmod u-s $(which containerlab)
```

#### SELinux Configuration (if applicable)

If you get "Segmentation fault" errors with SELinux enforced:

```bash
# Option 1: Allow for Containerlab only
sudo semanage fcontext -a -t textrel_shlib_t $(which containerlab)
sudo restorecon $(which containerlab)

# Option 2: Global setting
sudo setsebool -P selinuxuser_execmod 1
```

---

## macOS Installation

### Prerequisites for macOS

1. **Install Docker Desktop**
   - Download from: https://www.docker.com/products/docker-desktop
   - Supports both Intel and Apple Silicon (M1/M2/M3)
   - Start Docker Desktop and ensure it's running

2. **Verify Docker is running:**
   ```bash
   docker version
   ```

---

### macOS Installation Steps

#### Step 1: Add Containerlab Function

Add the following function to your shell configuration file:

**For zsh (default on macOS):**

```bash
cat >> ~/.zshrc << 'EOF'

# Containerlab function
clab() {
  docker run --rm -it --privileged \
    --network host \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /var/run/netns:/var/run/netns \
    -v /etc/hosts:/etc/hosts \
    -v /var/lib/docker/containers:/var/lib/docker/containers \
    --pid="host" \
    -v $(pwd):$(pwd) \
    -w $(pwd) \
    ghcr.io/srl-labs/clab containerlab "$@"
}

echo "Containerlab function loaded successfully!"
EOF
```

**For bash:**

```bash
cat >> ~/.bash_profile << 'EOF'

# Containerlab function
clab() {
  docker run --rm -it --privileged \
    --network host \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /var/run/netns:/var/run/netns \
    -v /etc/hosts:/etc/hosts \
    -v /var/lib/docker/containers:/var/lib/docker/containers \
    --pid="host" \
    -v $(pwd):$(pwd) \
    -w $(pwd) \
    ghcr.io/srl-labs/clab containerlab "$@"
}

echo "Containerlab function loaded successfully!"
EOF
```

#### Step 2: Reload Shell Configuration

```bash
# For zsh
source ~/.zshrc

# For bash
source ~/.bash_profile
```

#### Step 3: First Run (Auto-downloads Image)

```bash
clab version
```

**Expected output:**
```
Unable to find image 'ghcr.io/srl-labs/clab:latest' locally
latest: Pulling from srl-labs/clab
[downloading...]
Status: Downloaded newer image for ghcr.io/srl-labs/clab:latest

  ____ ___  _   _ _____  _    ___ _   _ _____ ____  _       _     
 / ___/ _ \| \ | |_   _|/ \  |_ _| \ | | ____|  _ \| | __ _| |__  
| |  | | | |  \| | | | / _ \  | ||  \| |  _| | |_) | |/ _` | '_ \ 
| |__| |_| | |\  | | |/ ___ \ | || |\  | |___|  _ <| | (_| | |_) |
 \____\___/|_| \_| |_/_/   \_\___|_| \_|_____|_| \_\_|\__,_|_.__/ 

    version: 0.71.1
```

---

### Why Docker Container Method for macOS?

**Containerlab requires Linux kernel features:**
- Network namespaces
- Linux bridge networking
- iptables/routing

**Docker Desktop on macOS:**
- Runs containers inside a Linux VM
- Containerlab runs inside this VM with full Linux capabilities
- Docker container method is the official approach

---

## Windows Installation

### Prerequisites for Windows

1. **Enable WSL2 (Windows Subsystem for Linux 2)**

   ```powershell
   # Open PowerShell as Administrator
   wsl --install
   
   # Restart computer
   ```

2. **Install a Linux distribution from Microsoft Store**
   - Recommended: Ubuntu 22.04 LTS
   - Launch it and set up username/password

3. **Install Docker Desktop for Windows**
   - Download from: https://www.docker.com/products/docker-desktop
   - During installation, ensure "Use WSL 2 instead of Hyper-V" is selected
   - In Docker Desktop Settings → Resources → WSL Integration:
     - Enable integration with your Linux distro

---

### Windows Installation Methods

#### Method 1: Install Inside WSL2 (Recommended)

**Step 1: Open your WSL2 Linux terminal**

```bash
# From Windows Terminal or PowerShell
wsl
```

**Step 2: Install Containerlab using Linux method**

```bash
# Quick setup (installs Docker if needed)
curl -sL https://containerlab.dev/setup | sudo -E bash -s "all"

# Or install script only
bash -c "$(curl -sL https://get.containerlab.dev)"
```

**Step 3: Enable sudo-less Docker**

```bash
newgrp docker
```

**Step 4: Verify**

```bash
clab version
```

---

#### Method 2: Docker Container Method in WSL2

If you prefer the container method:

**Step 1: Add function to ~/.bashrc in WSL**

```bash
cat >> ~/.bashrc << 'EOF'

# Containerlab function
clab() {
  docker run --rm -it --privileged \
    --network host \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /var/run/netns:/var/run/netns \
    -v /etc/hosts:/etc/hosts \
    -v /var/lib/docker/containers:/var/lib/docker/containers \
    --pid="host" \
    -v $(pwd):$(pwd) \
    -w $(pwd) \
    ghcr.io/srl-labs/clab containerlab "$@"
}
EOF
```

**Step 2: Reload and verify**

```bash
source ~/.bashrc
clab version
```

---

### Accessing WSL Files from Windows

Your lab files in WSL can be accessed from Windows:

```
\\wsl$\Ubuntu-22.04\home\<username>\
```

Or in WSL, access Windows files:

```bash
cd /mnt/c/Users/<WindowsUsername>/
```

---

## Verification

After installation on any platform, verify Containerlab is working:

### Check Version

```bash
clab version
```

**Expected output:**
```
    version: 0.71.1
     commit: a995a3d1e
       date: 2025-11-04T08:52:10Z
```

### Deploy Test Lab

**Create test topology:**

```bash
cat > test-lab.clab.yml << 'EOF'
name: test-lab

topology:
  nodes:
    alpine:
      kind: linux
      image: alpine:latest
EOF
```

**Deploy:**

```bash
clab deploy -t test-lab.clab.yml
```

**Expected output:**
```
INFO[0000] Containerlab v0.71.1 started
INFO[0000] Parsing & checking topology file: test-lab.clab.yml
INFO[0001] Creating lab directory: /path/to/clab-test-lab
INFO[0001] Creating container: "alpine"
INFO[0002] Created link: alpine:eth0 <--> 
INFO[0002] Adding containerlab host entries to /etc/hosts
INFO[0002] 🎉 New containerlab version 0.71.1 is available!
+----+--------------------+------+-------+--------+---------+
| #  |   Name             | Kind | State | IPv4   | IPv6    |
+----+--------------------+------+-------+--------+---------+
| 1  | clab-test-lab-alpine | linux | running | 172.20.20.2/24 | N/A |
+----+--------------------+------+-------+--------+---------+
```

**Inspect lab:**

```bash
clab inspect -t test-lab.clab.yml
```

**Destroy lab:**

```bash
clab destroy -t test-lab.clab.yml
```

---

## Troubleshooting

### Common Issues

#### "command not found: clab"

**Linux:**
```bash
# Check if installed
which containerlab

# If not found, reinstall
bash -c "$(curl -sL https://get.containerlab.dev)"
```

**macOS/Windows (Docker method):**
```bash
# Check shell config
cat ~/.zshrc | grep "clab()"   # macOS zsh
cat ~/.bashrc | grep "clab()"  # WSL/bash

# If missing, re-add function (see installation steps)
```

---

#### "Cannot connect to Docker daemon"

**All platforms:**
```bash
# Check Docker is running
docker ps

# Start Docker
# - Linux: sudo systemctl start docker
# - macOS/Windows: Start Docker Desktop
```

---

#### "Permission denied" errors (Linux)

```bash
# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker

# Or use sudo
sudo clab version
```

---

#### Image pull failures

```bash
# Check internet connection
ping -c 3 ghcr.io

# Manually pull image
docker pull ghcr.io/srl-labs/clab:latest

# Check Docker login (if using private registry)
docker login ghcr.io
```

---

#### SELinux "Segmentation fault" (Linux)

```bash
sudo semanage fcontext -a -t textrel_shlib_t $(which containerlab)
sudo restorecon $(which containerlab)
```

---

#### macOS M1/M2/M3 (ARM) compatibility

**Issue:** Some network OS images are x86_64 only

**Solution:**
- Use ARM-native images (Nokia SR Linux, Arista cEOS)
- Enable Rosetta 2 emulation in Docker Desktop:
  - Settings → Features in development → Enable Rosetta

---

#### WSL2 networking issues (Windows)

```bash
# Restart WSL
wsl --shutdown

# Restart Docker Desktop

# Check WSL integration
docker context ls
```

---

## Building from Source

### Prerequisites for Building

```bash
# Install Go (1.21 or later)
# For Linux:
wget https://go.dev/dl/go1.21.0.linux-amd64.tar.gz
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf go1.21.0.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin

# Verify Go installation
go version
```

---

### Method 1: Build with Go

```bash
# Clone repository
git clone https://github.com/srl-labs/containerlab.git
cd containerlab

# Build binary
go build -o containerlab

# Install binary
sudo mv containerlab /usr/bin/
sudo chmod a+x /usr/bin/containerlab

# Create symlink
sudo ln -s /usr/bin/containerlab /usr/bin/clab

# Verify
clab version
```

---

### Method 2: Build with GoReleaser

```bash
# Install GoReleaser
go install github.com/goreleaser/goreleaser@latest

# Clone repository
git clone https://github.com/srl-labs/containerlab.git
cd containerlab

# Build with GoReleaser
goreleaser build --snapshot --rm-dist --single-target

# Install built binary
sudo cp dist/containerlab_linux_amd64_v1/containerlab /usr/bin/
sudo chmod a+x /usr/bin/containerlab
sudo ln -s /usr/bin/containerlab /usr/bin/clab

# Verify
clab version
```

---

### Build for Different Architectures

```bash
# Build for ARM64
GOARCH=arm64 go build -o containerlab-arm64

# Build for AMD64
GOARCH=amd64 go build -o containerlab-amd64

# Cross-compile for macOS (from Linux)
GOOS=darwin GOARCH=arm64 go build -o containerlab-darwin-arm64
```

---

## Uninstallation

### Linux

#### If installed via package manager:

**Debian/Ubuntu:**
```bash
sudo apt remove containerlab
```

**RHEL/CentOS/Fedora:**
```bash
sudo yum remove containerlab
# or
sudo dnf remove containerlab
```

#### If installed manually:

```bash
sudo rm /usr/bin/containerlab
sudo rm /usr/bin/clab
sudo rm -rf /etc/containerlab
```

---

### macOS

**Remove the shell function:**

```bash
# Edit ~/.zshrc or ~/.bash_profile
# Remove the clab() function section

# Or automated removal
sed -i '' '/^# Containerlab function/,/^}$/d' ~/.zshrc
sed -i '' '/^echo "Containerlab function loaded/d' ~/.zshrc

# Reload shell
source ~/.zshrc
```

**Remove Docker image:**

```bash
docker rmi ghcr.io/srl-labs/clab:latest
```

---

### Windows (WSL2)

**Inside WSL terminal:**

```bash
# If installed via package
sudo apt remove containerlab

# If using Docker container method
# Remove function from ~/.bashrc (same as macOS method)
sed -i '/^# Containerlab function/,/^}$/d' ~/.bashrc
source ~/.bashrc

# Remove image
docker rmi ghcr.io/srl-labs/clab:latest
```

---

## Platform Comparison

| Feature | Linux (Native) | macOS (Docker) | Windows (WSL2) |
|---------|---------------|----------------|----------------|
| Installation Method | Native binary | Docker container | Native in WSL |
| Performance | Excellent | Good | Good |
| Networking | Full support | Full support | Full support |
| ARM Support | Yes | Yes (M1/M2/M3) | Limited |
| Sudo-less operation | Yes | N/A | Yes |
| Updates | Package manager | Docker pull | Package manager |
| File access | Direct | Direct | Via \\wsl$\ |

---

## Additional Resources

- **Official Documentation:** https://containerlab.dev
- **GitHub Repository:** https://github.com/srl-labs/containerlab
- **Discord Community:** https://discord.gg/vAyddtaEV9
- **macOS Detailed Guide:** https://containerlab.dev/macos/
- **Windows Detailed Guide:** https://containerlab.dev/windows/

---

## Quick Reference Commands

```bash
# Version check
clab version

# Deploy lab
clab deploy -t <topology-file>.clab.yml

# Destroy lab
clab destroy -t <topology-file>.clab.yml

# Inspect running labs
clab inspect --all

# View specific lab
clab inspect -t <topology-file>.clab.yml

# Access container
docker exec -it clab-<lab-name>-<node-name> bash

# Upgrade (Linux only)
sudo containerlab version upgrade

# Graph topology
clab graph -t <topology-file>.clab.yml
```

---

**Installation completed!** 🎉

You're now ready to create network labs with Containerlab across any platform.
