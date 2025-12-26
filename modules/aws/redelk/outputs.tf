# SUMMARY:
# Defines output variables for the RedElk
# instance, used for CI/CD automated deployments
# and passing information

// Outputs attibutes and metadata of the RedElk server
output redelk-server {
  value = aws_instance.RedELK
}

// Outputs the private IP address of the RedElk server 
output "redelk-private-ip" {
  value = aws_instance.RedELK.private_ip
}
