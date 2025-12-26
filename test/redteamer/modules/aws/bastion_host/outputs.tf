# # SUMMARY:
# # Defines output variables for the bastion host
# # instance, used for CI/CD automated deployments
# # and passing information

// Outputs bastion public IP
output "bastion_public_ip" {
    description = "Public IP address of the bastion host instance"
    value       = aws_instance.bastion_host.public_ip
}

// Outputs bastion private IP
output "bastion_private_ip" {
    description = "Private IP address of the bastion host instance"
    value       = aws_instance.bastion_host.private_ip
}

// Indicates which C2 server has been installed
output "installed_c2_server" {
    description = "The installed C2 server on the bastion host (Havoc, or Sliver)"
    value = (
        var.exphavvar ? "Havoc" :
        var.expslivar ? "Sliver" :
        "None"
    )
}

output "expredvar" {
  value = var.expredvar
}

output "exphavvar" {
  value = var.exphavvar
}

output "expslivar" {
  value = var.expslivar
}


// Indicates whether RedELK is installed
output "install_redelk" {
    description = "Indicates if RedELK SIEM is installed"
    value       = var.expredvar
}

// Indicates whether Havoc is installed
output "install_havoc" {
    description = "Indicates if Havoc C2 server is installed"
    value       = var.exphavvar
}

// Indicates whether Sliver is installed
output "install_sliver" {
    description = "Indicates if Sliver C2 server is installed"
    value       = var.expslivar
}
