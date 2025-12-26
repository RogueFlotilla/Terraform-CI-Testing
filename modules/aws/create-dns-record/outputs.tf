# SUMMARY:
# Defines output variables for the DNS record,
# used for CI/CD automated deployments
# and passing information

// Outputs DNS records
output "records" {
  value = var.records
}
