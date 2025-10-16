terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

# Deploy the 3-Node CLOS topology
resource "null_resource" "deploy_clos" {
  provisioner "local-exec" {
    command     = "bash ${path.module}/deploy_containerlab.sh ${path.module}/.."
    working_dir = path.module
  }

  provisioner "local-exec" {
    when        = destroy
    command     = "bash ${path.module}/destroy_containerlab.sh ${path.module}/.."
    working_dir = path.module
  }
}

# Wait for containers to fully initialize
resource "null_resource" "wait_for_lab" {
  depends_on = [null_resource.deploy_clos]
  
  provisioner "local-exec" {
    command = "echo 'Waiting for lab to initialize...' && sleep 30"
  }
}

# Validate the deployment with comprehensive checks
resource "null_resource" "validate_deployment" {
  depends_on = [null_resource.wait_for_lab]
  
  provisioner "local-exec" {
    command     = "bash ${path.module}/validate_connectivity.sh ${path.module}/.."
    working_dir = path.module
  }
}

# Outputs
output "lab_info" {
  value = {
    topology    = "3-node CLOS Fabric with BGP Underlay"
    nodes       = ["spine1", "leaf1", "leaf2", "client1", "client2"]
    topology_file = "clos01.clab.yml"
  }
}

output "management_ips" {
  value = {
    spine1  = "Check with: docker exec clab-clos01-spine1 ip addr"
    leaf1   = "Check with: docker exec clab-clos01-leaf1 ip addr"
    leaf2   = "Check with: docker exec clab-clos01-leaf2 ip addr"
    client1 = "Check with: docker exec clab-clos01-client1 ip addr"
    client2 = "Check with: docker exec clab-clos01-client2 ip addr"
  }
}

output "validation_status" {
  value = "✓ Lab deployed and validated. BGP sessions established. Use 'terraform destroy' to clean up."
  depends_on = [null_resource.validate_deployment]
}

output "quick_commands" {
  value = {
    inspect_lab       = "sudo containerlab inspect -t clos01.clab.yml"
    spine1_bgp        = "docker exec clab-clos01-spine1 sr_cli 'show network-instance default protocols bgp neighbor'"
    leaf1_bgp         = "docker exec clab-clos01-leaf1 sr_cli 'show network-instance default protocols bgp neighbor'"
    test_connectivity = "docker exec clab-clos01-leaf1 sr_cli 'ping 10.1.1.1 -c 3 network-instance default'"
  }
}
