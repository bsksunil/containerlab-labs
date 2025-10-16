# Define a variable to specify the path to your Containerlab configuration file
variable "containerlab_config_dir" {
  description = "The relative or absolute path to the directory containing the srl02-simple.clab.yml file."
  type        = string
  default     = ".."
}

# A null_resource acts as a placeholder to run provisioners.
resource "null_resource" "containerlab_2node_srl_deployment" {
  triggers = {
    clab_config_hash         = filemd5("${var.containerlab_config_dir}/srl02-simple.clab.yml")
    containerlab_config_path = abspath(var.containerlab_config_dir)
  }

  # --- Local-Exec Provisioner (Deploy Containerlab Topology) ---
  provisioner "local-exec" {
    command = "${path.module}/deploy_containerlab.sh ${abspath(var.containerlab_config_dir)}"
  }

  # --- Local-Exec Provisioner (Validate Connectivity) ---
  provisioner "local-exec" {
    command = "${path.module}/validate_connectivity.sh ${abspath(var.containerlab_config_dir)}"
  }

  # --- Local-Exec Provisioner (Destroy Containerlab Topology) ---
  provisioner "local-exec" {
    when    = destroy
    command = "${path.module}/destroy_containerlab.sh ${self.triggers.containerlab_config_path}"
  }
}

# An output to confirm the action taken by Terraform.
output "deployment_status" {
  value = "Containerlab 2-node SR Linux topology deployment/destruction managed from: ${var.containerlab_config_dir}. Use 'sudo containerlab inspect' to check status."
}

output "lab_info" {
  value = {
    topology = "2-Node SR Linux with OSPF and BGP"
    nodes    = ["srl1", "srl2"]
    connection = "10.0.0.0/30 interconnect"
    protocols = "OSPF Area 0 + eBGP (AS 65001 <-> AS 65002)"
    inspect_command = "sudo containerlab inspect -t ${var.containerlab_config_dir}/srl02-simple.clab.yml"
    validate_command = "./validate_connectivity.sh ${var.containerlab_config_dir}"
  }
}

output "validation_info" {
  value = {
    connectivity_test = "ICMP ping from srl1 to srl2 (10.0.0.2)"
    ospf_check = "OSPF neighbor adjacency status"
    bgp_check = "BGP session establishment"
    manual_test = "Run: ./validate_connectivity.sh ${var.containerlab_config_dir}"
  }
}
