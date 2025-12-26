# SUMMARY:
# Defines output variables for creating a VPC,
# used for CI/CD automated deployments
# and passing information

// This exports the whole object
output create-vpc {
  value = aws_vpc.myvpc
}

// This exports a single value ( which I found to be easy to access )
output "vpc_id" {
  value = aws_vpc.myvpc.id
}

// Outputs first subnet ID
output "subnet1_id" {
  value = aws_subnet.subnet1.id
}

// Outputs second subnet ID
output "subnet2_id" {
    value = aws_subnet.subnet2.id
}

