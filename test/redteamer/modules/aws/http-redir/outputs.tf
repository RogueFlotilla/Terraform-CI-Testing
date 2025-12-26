# SUMMARY:
# Defines output variables for HTTP redirector
# instance, used for CI/CD automated deployments
# and passing information

// Outputs HTTP redir resource information
output "httpredir-host" {
  value = aws_instance.httpredir-host
}

// Outputs HTTP redir private IP
output "httpredir-private-ip" {
  value = concat(aws_instance.httpredir-host.*.private_ip)
}

// Outputs HTTP redit public IP
output "httpredir-public-ip" {
  value = concat(aws_instance.httpredir-host.*.public_ip)
}