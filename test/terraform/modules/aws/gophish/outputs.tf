# SUMMARY:
# Defines output variables for the Gophish
# instance, used for CI/CD automated deployments
# and passing information

// Outputs gophish host information
output "gophish_host" {
  value = aws_instance.gophish_host
}

// Outputs gophish private IP
output "gophish-private-ip" {
  value = aws_instance.gophish_host.private_ip
}

// Outputs gophish AWS EC2 instance ID
// Checks if the aws_instance.gophish_host resource exist and isn't null
output "gophish_instance_id" {
  value = aws_instance.gophish_host != null ? aws_instance.gophish_host.id : null
  description = "The ID of the gophish instance"
}