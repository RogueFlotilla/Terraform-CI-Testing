# SUMMARY:
# Defines output variables for the teamserver
# instance, used for CI/CD automated deployments
# and passing information

// Outputs the private IP address of the teamserver instance
output "private_ip" {
    value = aws_instance.teamserver.*.private_ip
}

// Outputs theID of the teamserver instance
// Checks handle cases where the instance may not be created
output "teamserver_instance_id" {
  value = aws_instance.teamserver != null ? aws_instance.teamserver.id : null
  description = "The ID of the teamserver instance"
}

output "expslivar"{
  value = var.expslivar
}

output "exphavvar"{
  value = var.exphavvar
}
