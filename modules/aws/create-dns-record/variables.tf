# SUMMARY:
# Defines input variables that are used
# throughout the DNS record infrastructure

variable "domain" {}

variable "type" {}

variable "key_name" {}

variable "hosts" {
  default = 1
}

// Time to live is 120 seconds
variable "ttl" {
  default = 120
}

// Holds a map of records with name and value with any data type
variable "records" {
  type = map(any)
}
