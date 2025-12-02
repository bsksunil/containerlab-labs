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
