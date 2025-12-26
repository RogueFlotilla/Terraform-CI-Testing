# SUMMARY:
# Defines output variables for the Evilginx
# instance, used for CI/CD automated deployments
# and passing information

// Outputs information regarding the Evilginx host
output "evilginx_host" {
  value = aws_instance.evilginx_host
}

// Outputs Evilginx private ip
output "evilginx-private-ip" {
  value = aws_instance.evilginx_host.private_ip
}

// Outputs Evilginx public ip
output "evilginx-public-ip" {
  value = aws_instance.evilginx_host.public_ip
}

// Outputs Evilginx instance ID, checks if null
output "evilginx_instance_id" {
  value = aws_instance.evilginx_host != null ? aws_instance.evilginx_host.id : null
  description = "The ID of the evilginx instance"
}