# SUMMARY:
# This Terraform file manages DNS records in AWS
# route 53

// Locked in Terraform version
terraform {
  required_version = ">= 1.1.5"
}

// Creates DNS records for AWS route 53
// Retrieves info on existing route 53
# data "aws_route53_zone" "selected" {
#   name  = var.domain
# }


// Defines DNS record in route 53 hosted zone
# resource "aws_route53_record" "record" {
#   allow_overwrite = true // Allows route 53 to be overwritten if existing
#   count = var.hosts // Used to create multiple records
#   zone_id = data.aws_route53_zone.selected.zone_id
#   name = element(keys(var.records), count.index) // Defines DNS record name
#   type = var.type
#   ttl = var.ttl
#   records = lookup(var.records, element(keys(var.records), count.index)) // Sets value for DNS record
# }
