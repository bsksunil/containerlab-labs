#!/bin/bash

echo "Creating Terraform directories..."
mkdir -p ~/containerlab-labs/2-node-srl/terraform
mkdir -p ~/containerlab-labs/3-node-topology/terraform
mkdir -p ~/containerlab-labs/srl-xrv9k-lab/terraform

echo "Creating 2-node-srl Terraform configuration..."
cat > ~/containerlab-labs/2-node-srl/terraform/main.tf << 'EOF'
terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

resource "null_resource" "deploy_2node_srl" {
  provisioner "local-exec" {
    command     = "sudo containerlab deploy -t ../srl02-simple.clab.yml"
    working_dir = path.module
  }

  provisioner "local-exec" {
    when    = destroy
    command = "sudo containerlab destroy -t ../srl02-simple.clab.yml --cleanup"
  }
}

resource "null_resource" "wait_for_lab" {
  depends_on = [null_resource.deploy_2node_srl]
  provisioner "local-exec" {
    command = "sleep 20"
  }
}

resource "null_resource" "validate_deployment" {
  depends_on = [null_resource.wait_for_lab]
  provisioner "local-exec" {
    command = "sudo containerlab inspect -t ../srl02-simple.clab.yml"
  }
}

output "lab_info" {
  value = {
    topology = "2-node SR Linux with OSPF and BGP"
    nodes    = ["srl1", "srl2"]
  }
}
EOF

cat > ~/containerlab-labs/2-node-srl/terraform/README.md << 'EOF'
# 2-Node SR Linux Lab - Terraform Module

## Overview
2-node Nokia SR Linux lab with OSPF and BGP routing protocols.

## Usage
terraform init
terraform apply -auto-approve
terraform destroy -auto-approve
EOF

echo "Creating 3-node-topology Terraform configuration..."
cat > ~/containerlab-labs/3-node-topology/terraform/main.tf << 'EOF'
terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

resource "null_resource" "deploy_clos" {
  provisioner "local-exec" {
    command     = "sudo containerlab deploy -t ../clos01.clab.yml"
    working_dir = path.module
  }

  provisioner "local-exec" {
    when    = destroy
    command = "sudo containerlab destroy -t ../clos01.clab.yml --cleanup"
  }
}

resource "null_resource" "wait_for_lab" {
  depends_on = [null_resource.deploy_clos]
  provisioner "local-exec" {
    command = "sleep 30"
  }
}

resource "null_resource" "validate_deployment" {
  depends_on = [null_resource.wait_for_lab]
  provisioner "local-exec" {
    command = "sudo containerlab inspect -t ../clos01.clab.yml"
  }
}

output "lab_info" {
  value = {
    topology = "3-node Clos Fabric with BGP Underlay"
    nodes    = ["leaf1", "leaf2", "spine1", "client1", "client2"]
  }
}
EOF

cat > ~/containerlab-labs/3-node-topology/terraform/README.md << 'EOF'
# 3-Node Clos Fabric - Terraform Module

## Overview
3-node Clos fabric with BGP underlay and client containers.

## Usage
terraform init
terraform apply -auto-approve
terraform destroy -auto-approve
EOF

echo "Creating srl-xrv9k-lab Terraform configuration..."
cat > ~/containerlab-labs/srl-xrv9k-lab/terraform/main.tf << 'EOF'
terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

resource "null_resource" "deploy_multivendor" {
  provisioner "local-exec" {
    command     = "sudo containerlab deploy -t ../srl-xrv9k.clab.yml"
    working_dir = path.module
  }

  provisioner "local-exec" {
    when    = destroy
    command = "sudo containerlab destroy -t ../srl-xrv9k.clab.yml --cleanup"
  }
}

resource "null_resource" "wait_for_lab" {
  depends_on = [null_resource.deploy_multivendor]
  provisioner "local-exec" {
    command = "sleep 120"
  }
}

resource "null_resource" "validate_deployment" {
  depends_on = [null_resource.wait_for_lab]
  provisioner "local-exec" {
    command = "sudo containerlab inspect -t ../srl-xrv9k.clab.yml"
  }
}

output "lab_info" {
  value = {
    topology = "Multi-vendor: Nokia SR Linux + Cisco XRv9k"
    nodes    = ["srl", "xrv9k"]
    credentials = {
      srl = "admin / NokiaSrl1!"
      xrv9k = "clab / clab@123"
    }
  }
}
EOF

cat > ~/containerlab-labs/srl-xrv9k-lab/terraform/README.md << 'EOF'
# Multi-vendor Lab - Terraform Module

## Overview
Multi-vendor lab with Nokia SR Linux and Cisco XRv9k.

## Credentials
- SR Linux: admin / NokiaSrl1!
- XRv9k: clab / clab@123

## Usage
terraform init
terraform apply -auto-approve
terraform destroy -auto-approve
EOF

echo "All Terraform configurations created successfully!"
