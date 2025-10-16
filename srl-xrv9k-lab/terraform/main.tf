terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

# Validation-only resource (manual deployment + config)
resource "null_resource" "validate_multivendor" {
  triggers = {
    always_run = "${timestamp()}"
  }
  
  provisioner "local-exec" {
    command     = "bash validate_connectivity.sh"
    working_dir = path.module
  }
}

output "lab_info" {
  value = {
    topology    = "Multi-vendor: Nokia SR Linux + Cisco XRv9k"
    nodes       = ["srl", "xrv9k"]
    credentials = {
      srl   = "admin / NokiaSrl1!"
      xrv9k = "clab / clab@123"
    }
    deployment_notes = "Deploy manually, then run: terraform apply -auto-approve"
  }
}

output "validation_status" {
  value      = "Run 'terraform apply -auto-approve' to validate the lab"
  depends_on = [null_resource.validate_multivendor]
}

output "quick_commands" {
  value = {
    deploy_lab      = "sudo containerlab deploy -t ../srl-xrv9k.clab.yml"
    destroy_lab     = "sudo containerlab destroy -t ../srl-xrv9k.clab.yml --cleanup"
    validate        = "terraform apply -auto-approve"
    manual_validate = "bash validate_connectivity.sh"
  }
}
